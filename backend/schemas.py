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
    after_img: Optional[str] = None
    claimed_by_name: Optional[str] = None

class ReportResponse(ReportBase):
    id: int
    class Config:
        from_attributes = True

class UserStats(BaseModel):
    name: str
    points: int
    streak: int
    badges: List[str]
    trust_score: int
    total_cleanups: int

class UserLeaderboard(BaseModel):
    name: str
    points: int
    badge: str
    isMe: bool
    trust_score: int
    total_cleanups: int
