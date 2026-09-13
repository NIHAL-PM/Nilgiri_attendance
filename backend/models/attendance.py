import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from database import Base

class Attendance(Base):
    __tablename__ = "attendances"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    event_id: Mapped[str] = mapped_column(String(36), ForeignKey("events.id"), nullable=False, index=True)
    
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    similarity_score: Mapped[float] = mapped_column(Float, nullable=False)
    distance_meters: Mapped[float] = mapped_column(Float, nullable=False)
    is_present: Mapped[bool] = mapped_column(Boolean, default=True)

    user: Mapped["User"] = relationship("User", back_populates="attendances")
    event: Mapped["Event"] = relationship("Event", back_populates="attendances")
