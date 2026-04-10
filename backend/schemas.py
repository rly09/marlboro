from pydantic import BaseModel
from typing import Optional, List

class ReportBase(BaseModel):
    lat: float
    lng: float
    severity: str
    status: str = "Pending"
    img: str
    description: str
    aiInsight: Optional[str] = None

class ReportResponse(ReportBase):
    id: int
    class Config:
        from_attributes = True

class UserStats(BaseModel):
    name: str
    points: int
    streak: int
    badges: List[str]

class UserLeaderboard(BaseModel):
    name: str
    points: int
    badge: str
    isMe: bool
