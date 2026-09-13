import uuid
import json
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Text, Float, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    avatar_url: Mapped[str] = mapped_column(String(512), default="https://i.pravatar.cc/150?img=33")
    
    # Role-Based Access Control: 'student' (default), 'teacher', 'admin'
    role: Mapped[str] = mapped_column(String(50), default="student", nullable=False)
    
    # Biometric Enrollment
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    face_embedding_json: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON-encoded 512 float array
    accuracy_score: Mapped[float] = mapped_column(Float, default=0.912)
    
    # Stats
    total_events: Mapped[int] = mapped_column(Integer, default=0)
    present_count: Mapped[int] = mapped_column(Integer, default=0)
    current_streak: Mapped[int] = mapped_column(Integer, default=0)
    
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    attendances: Mapped[list["Attendance"]] = relationship("Attendance", back_populates="user", cascade="all, delete-orphan")

    def get_face_embedding(self) -> list[float] | None:
        if self.face_embedding_json:
            return json.loads(self.face_embedding_json)
        return None

    def set_face_embedding(self, vector: list[float]):
        self.face_embedding_json = json.dumps(vector)
        self.is_verified = True
