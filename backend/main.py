import os
import json
import random
from fastapi import FastAPI, Depends, UploadFile, File, Form, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from . import models, schemas, database
from .database import engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="CleanCity AI API")

# Mount uploads directory to serve images locally
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Seed initial user if not exists
def seed_user(db: Session):
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if not user:
        user = models.User(name="Yogi", is_me=1, points=250, streak=3, badges=json.dumps(['Eco Warrior', 'City Saver']))
        db.add(user)
        # Add some mock users for leaderboard
        db.add(models.User(name="Sarah M.", is_me=0, points=1250, streak=12, badges=json.dumps(['Eco Warrior'])))
        db.add(models.User(name="David K.", is_me=0, points=840, streak=5, badges=json.dumps(['City Saver'])))
        db.add(models.User(name="Emma W.", is_me=0, points=620, streak=2, badges=json.dumps(['Scout'])))
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

    # Simulated AI Detection
    ai_insights_options = [
        ("Plastic waste detected - High priority", "High"),
        ("Organic/Paper waste detected - Medium priority", "Medium"),
        ("Hazardous material detected - Critical", "High"),
        ("Low severity debris", "Low")
    ]
    insight, severity = random.choice(ai_insights_options)

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
    return db_report

@app.put("/api/reports/{id}/claim")
def claim_task(id: int, db: Session = Depends(database.get_db)):
    report = db.query(models.Report).filter(models.Report.id == id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    report.status = "In Progress"
    
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if user:
        user.points += 10
    
    db.commit()
    return {"status": "success"}

@app.put("/api/reports/{id}/complete")
def complete_task(id: int, db: Session = Depends(database.get_db)):
    report = db.query(models.Report).filter(models.Report.id == id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    report.status = "Cleaned"
    
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if user:
        user.points += 50
    
    db.commit()
    return {"status": "success"}

@app.get("/api/user/stats", response_model=schemas.UserStats)
def get_user_stats(db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.is_me == 1).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    badges = json.loads(user.badges)
    return schemas.UserStats(name=user.name, points=user.points, streak=user.streak, badges=badges)

@app.get("/api/leaderboard", response_model=list[schemas.UserLeaderboard])
def get_leaderboard(db: Session = Depends(database.get_db)):
    users = db.query(models.User).order_by(models.User.points.desc()).all()
    leaderboard = []
    for u in users:
        badges = json.loads(u.badges)
        badge = badges[0] if badges else "Novice"
        leaderboard.append(schemas.UserLeaderboard(name=u.name, points=u.points, badge=badge, isMe=bool(u.is_me)))
    return leaderboard
