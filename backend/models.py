from sqlalchemy import Column, Integer, String, Float, Text, Enum
from .database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))
    is_me = Column(Integer, default=0) # 1 if it's the current user, 0 otherwise
    points = Column(Integer, default=0)
    streak = Column(Integer, default=0)
    badges = Column(String(255), default="[]") # simple JSON list string

class Report(Base):
    __tablename__ = "reports"
    id = Column(Integer, primary_key=True, index=True)
    lat = Column(Float)
    lng = Column(Float)
    severity = Column(String(50))
    status = Column(String(50), default="Pending")
    img = Column(String(255))
    description = Column(Text)
    aiInsight = Column(String(255), nullable=True)
