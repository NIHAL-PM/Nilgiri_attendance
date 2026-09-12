from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

# --- Auth Schemas ---
class StudentRegisterRequest(BaseModel):
    email: EmailStr
    student_id: str = Field(..., example="STU_1042")
    full_name: str = Field(..., example="Alex Johnson")
    password: str = Field(..., min_length=6)

class LoginRequest(BaseModel):
    email_or_id: str
    password: str

class UserProfileResponse(BaseModel):
    id: str
    email: str
    student_id: str
    full_name: str
    role: str
    is_face_registered: bool
    face_registered_at: Optional[datetime] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserProfileResponse

# --- Biometric Schemas ---
class BiometricRegisterRequest(BaseModel):
    embedding: List[float] = Field(..., description="512-float MobileFaceNet facial vector array")

class BiometricRegisterResponse(BaseModel):
    status: str = "success"
    message: str
    is_face_registered: bool

# --- Event Schemas ---
class EventResponse(BaseModel):
    id: str
    code: str
    name: str
    description: Optional[str] = None
    location_name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    radius_meters: float
    is_geofenced: bool
    start_time: datetime
    end_time: datetime
    is_active: bool

class EventCreateRequest(BaseModel):
    name: str
    code: str
    description: Optional[str] = None
    location_name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    radius_meters: float = 50.0
    is_geofenced: bool = False
    start_time: datetime
    end_time: datetime

# --- Attendance Schemas ---
class AttendanceVerifyRequest(BaseModel):
    event_id: str
    embedding: List[float] = Field(..., description="512-float vector captured live")
    timestamp: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class AttendanceVerifyResponse(BaseModel):
    status: str # 'verified' or 'failed'
    student_name: str
    similarity_score: float
    message: str
    timestamp: datetime
    geofence_verified: bool = True
    attendance_id: Optional[str] = None
