import os
import json
import random
from fastapi import FastAPI, Depends, UploadFile, File, Form, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from sqlalchemy.orm import Session
from . import models, schemas, database
from .database import engine
from dotenv import load_dotenv
from cerebras.cloud.sdk import Cerebras
from ultralytics import YOLO

load_dotenv()

models.Base.metadata.create_all(bind=engine)

# Initialize YOLOv8 and Cerebras Client
try:
    yolo_model = YOLO("yolov8n.pt")
except Exception as e:
    print(f"Warning: YOLO failed to load: {e}")
    yolo_model = None

cerebras_client = None
if os.getenv("CEREBRAS_API_KEY"):
    cerebras_client = Cerebras(api_key=os.getenv("CEREBRAS_API_KEY"))

app = FastAPI(title="CleanCity AI API")

# Mount uploads directory to serve images locally
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/api/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                pass

ws_manager = ConnectionManager()

@app.websocket("/api/ws")
async def websocket_endpoint(websocket: WebSocket):
    await ws_manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        ws_manager.disconnect(websocket)


# Seed initial user if not exists
def seed_user(db: Session):
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if not user:
        user = models.User(name="Yogi", is_me=1, points=250, streak=3, badges=json.dumps(['Eco Warrior', 'City Saver']), trust_score=100, total_cleanups=5)
        db.add(user)
        # Add some mock users for leaderboard
        db.add(models.User(name="Sarah M.", is_me=0, points=1250, streak=12, badges=json.dumps(['Eco Warrior']), trust_score=110, total_cleanups=30))
        db.add(models.User(name="David K.", is_me=0, points=840, streak=5, badges=json.dumps(['City Saver']), trust_score=95, total_cleanups=15))
        db.add(models.User(name="Emma W.", is_me=0, points=620, streak=2, badges=json.dumps(['Scout']), trust_score=100, total_cleanups=8))
        db.commit()
        
    # Seed reports — coordinates around SRM University, Kattankulathur
    if db.query(models.Report).count() == 0:
        # Keep only a few "high quality" examples for initial WOW factor
        dummy_reports = [
            models.Report(lat=12.8231, lng=80.0442, severity="High", img="https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?auto=format&fit=crop&w=400&q=80", description="Overflowing garbage bin at SRM main gate - identified by Cerebras AI.", aiInsight="Mixed waste detected. High priority for sanitary clearance.", status="Pending"),
            models.Report(lat=12.8218, lng=80.0455, severity="Medium", img="https://images.unsplash.com/photo-1621451537084-482c73073e0f?auto=format&fit=crop&w=400&q=80", description="Industrial waste accumulation near tech park site.", aiInsight="Cardboard and plastic scrap detected.", status="Pending"),
        ]
        for r in dummy_reports:
            db.add(r)
        db.commit()

@app.on_event("startup")
def startup_event():
    db = database.SessionLocal()
    seed_user(db)
    db.close()

@app.get("/api/reports", response_model=list[schemas.ReportResponse])
def get_reports(db: Session = Depends(database.get_db)):
    return db.query(models.Report).all()

@app.post("/api/reports", response_model=schemas.ReportResponse)
async def create_report(
    lat: float = Form(...),
    lng: float = Form(...),
    description: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(database.get_db)
):
    # Save Image
    filename = f"{random.randint(1000, 9999)}_{file.filename}"
    filepath = os.path.join(UPLOAD_DIR, filename)
    with open(filepath, "wb") as f:
        content = await file.read()
        f.write(content)

    img_url = f"/api/uploads/{filename}"

    # --- STEP 1: Vision analysis using local YOLO ---
    detections = []
    if yolo_model:
        results = yolo_model(filepath)
        for r in results:
            for box in r.boxes:
                cls = int(box.cls[0])
                name = yolo_model.names[cls]
                detections.append(name)
    
    detection_summary = ", ".join(set(detections)) if detections else "general waste items"

    # --- STEP 2: Reasoning using Cerebras ---
    insight = "Garbage detected. Pending verification."
    
    # Rule-based fallback for severity (prevents everything being 'Medium')
    object_count = len(detections)
    if object_count > 5:
        severity = "High"
    elif object_count == 0 and not description:
        severity = "Low"
    else:
        severity = "Medium"

    if cerebras_client:
        try:
            prompt = f"""
            Analyze this civic garbage report and provide a JSON response.
            Detected objects: {detection_summary}
            User description: {description}
            
            Guidelines:
            - HIGH: Hazardous, huge pile, blocking road, medical waste, or foul smell.
            - MEDIUM: General household waste, overflowing bin, scattered litter.
            - LOW: Single small item, non-hazardous plastic, dry waste.

            Response format:
            {{
                "severity": "Low" | "Medium" | "High",
                "insight": "Short professional assessment (max 12 words)"
            }}
            """
            response = cerebras_client.chat.completions.create(
                messages=[{"role": "user", "content": prompt}],
                model="llama3.1-70b",
                response_format={ "type": "json_object" }
            )
            res_data = json.loads(response.choices[0].message.content)
            severity = res_data.get("severity", severity) # Use fallback if not provided
            insight = res_data.get("insight", "AI analyzed waste detected.")
        except Exception as e:
            print(f"Cerebras Error: {e}")
            insight = f"Analysis complete: {detection_summary} detected."
    else:
        insight = f"Detected: {detection_summary}. (Enable Cerebras for deep insights)"
        # Keep the heuristic severity if Cerebras is off

    db_report = models.Report(
        lat=lat,
        lng=lng,
        severity=severity,
        img=img_url,
        description=description,
        aiInsight=insight,
        status="Pending"
    )
    db.add(db_report)
    db.commit()
    db.refresh(db_report)
    
    # Broadcast new report
    import asyncio
    asyncio.create_task(ws_manager.broadcast({
        "event": "report_new",
        "data": schemas.ReportResponse.from_orm(db_report).dict()
    }))
    
    return db_report

@app.put("/api/reports/{id}/claim")
async def claim_task(id: int, db: Session = Depends(database.get_db)):
    report = db.query(models.Report).filter(models.Report.id == id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    report.status = "In Progress"
    
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if user:
        user.points += 10
        report.claimed_by_name = user.name
    
    db.commit()
    db.refresh(report)

    await ws_manager.broadcast({
        "event": "report_updated",
        "data": schemas.ReportResponse.from_orm(report).dict()
    })
    await ws_manager.broadcast({"event": "leaderboard_updated"})

    return {"status": "success"}

@app.post("/api/reports/{id}/complete")
async def complete_task(
    id: int, 
    file: UploadFile = File(...), 
    db: Session = Depends(database.get_db)
):
    report = db.query(models.Report).filter(models.Report.id == id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    # Save After Image
    if file:
        filename = f"after_{random.randint(1000, 9999)}_{file.filename}"
        filepath = os.path.join(UPLOAD_DIR, filename)
        with open(filepath, "wb") as f:
            content = await file.read()
            f.write(content)
        report.after_img = f"/api/uploads/{filename}"
    
    report.status = "Cleaned"
    
    # Advanced Gamification Logic
    points_to_add = 10
    if report.severity == "High":
        points_to_add = 50
    elif report.severity == "Medium":
        points_to_add = 25
        
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if user:
        user.points += points_to_add
        user.total_cleanups += 1
        user.trust_score = min(200, user.trust_score + 2) # small trust bump upon proof
    
    db.commit()
    db.refresh(report)
    
    await ws_manager.broadcast({
        "event": "report_updated",
        "data": schemas.ReportResponse.from_orm(report).dict()
    })
    await ws_manager.broadcast({"event": "leaderboard_updated"})
    
    return {"status": "success"}

@app.get("/api/user/stats", response_model=schemas.UserStats)
def get_user_stats(db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    badges = json.loads(user.badges)
    return schemas.UserStats(
        name=user.name, 
        points=user.points, 
        streak=user.streak, 
        badges=badges, 
        trust_score=user.trust_score, 
        total_cleanups=user.total_cleanups
    )

@app.get("/api/leaderboard", response_model=list[schemas.UserLeaderboard])
def get_leaderboard(db: Session = Depends(database.get_db)):
    users = db.query(models.User).order_by(models.User.points.desc()).all()
    leaderboard = []
    for u in users:
        badges = json.loads(u.badges)
        badge = badges[0] if badges else "Novice"
        leaderboard.append(schemas.UserLeaderboard(
            name=u.name, 
            points=u.points, 
            badge=badge, 
            isMe=bool(u.is_me),
            trust_score=u.trust_score,
            total_cleanups=u.total_cleanups
        ))
    return leaderboard
