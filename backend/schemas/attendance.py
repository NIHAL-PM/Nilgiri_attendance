from datetime import datetime
from pydantic import BaseModel, ConfigDict

class AttendanceMarkRequest(BaseModel):
    event_id: str
    face_embedding: list[float]  # Probe vector captured by scanner
    latitude: float
    longitude: float

class AttendanceRead(BaseModel):
    id: str
    event_id: str
    event_title: str
    event_venue: str
    timestamp: datetime
    similarity_score: float
    distance_meters: float
    is_present: bool

    model_config = ConfigDict(from_attributes=True)
