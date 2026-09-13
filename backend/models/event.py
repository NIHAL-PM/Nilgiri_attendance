import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from database import Base

class Event(Base):
    __tablename__ = "events"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    venue: Mapped[str] = mapped_column(String(255), nullable=False)
    
    start_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    end_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    image_tag: Mapped[str] = mapped_column(String(50), default="cyan")
    
    # Class Cohort Target (e.g. 'CS-2026', 'ECE-A', or 'All')
    target_class: Mapped[str] = mapped_column(String(100), default="All", nullable=False)
    
    # Teacher/Admin Creator
    created_by_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    
    # Geofence Coordinates (Default: Nilgiri College main auditorium)
    latitude: Mapped[float] = mapped_column(Float, default=11.0168)
    longitude: Mapped[float] = mapped_column(Float, default=76.9558)
    radius_meters: Mapped[float] = mapped_column(Float, default=50.0)

    attendances: Mapped[list["Attendance"]] = relationship("Attendance", back_populates="event", cascade="all, delete-orphan")
