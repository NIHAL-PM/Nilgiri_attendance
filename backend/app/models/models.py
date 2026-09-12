import uuid
import json
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    email = Column(String(255), unique=True, index=True, nullable=False)
    student_id = Column(String(100), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(50), default="student")
    
    # Biometrics
    # Storing normalized 512-float vector as JSON string for cross-database portability
    face_embedding = Column(Text, nullable=True)
    is_face_registered = Column(Boolean, default=False)
    face_registered_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    attendances = relationship("Attendance", back_populates="user")

    def get_embedding_list(self):
        if not self.face_embedding:
            return None
        return json.loads(self.face_embedding)

    def set_embedding_list(self, embedding: list):
        self.face_embedding = json.dumps(embedding)
        self.is_face_registered = True
        self.face_registered_at = datetime.now(timezone.utc)

class Event(Base):
    __tablename__ = "events"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False)
    code = Column(String(50), unique=True, index=True, nullable=False) # e.g. EVT-9021
    description = Column(Text, nullable=True)
    location_name = Column(String(255), nullable=False, default="Main Auditorium")
    
    # Geofence Coordinates
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    radius_meters = Column(Float, default=50.0)
    is_geofenced = Column(Boolean, default=False)
    
    # Timing
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    attendances = relationship("Attendance", back_populates="event")

class Attendance(Base):
    __tablename__ = "attendances"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    event_id = Column(String(36), ForeignKey("events.id"), nullable=False)
    
    similarity_score = Column(Float, nullable=False)
    status = Column(String(50), default="PRESENT") # PRESENT, REJECTED
    verification_time = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    
    # Location recorded at verification
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    distance_meters = Column(Float, nullable=True)

    user = relationship("User", back_populates="attendances")
    event = relationship("Event", back_populates="attendances")
