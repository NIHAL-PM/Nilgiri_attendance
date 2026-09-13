from datetime import datetime
from pydantic import BaseModel, ConfigDict

class EventRead(BaseModel):
    id: str
    title: str
    venue: str
    start_time: datetime
    end_time: datetime
    is_active: bool
    image_tag: str
    target_class: str = "All"
    created_by_id: str | None = None
    latitude: float
    longitude: float
    radius_meters: float

    model_config = ConfigDict(from_attributes=True)

class EventCreate(BaseModel):
    title: str
    venue: str
    start_time: datetime
    end_time: datetime
    is_active: bool = True
    image_tag: str = "cyan"
    target_class: str = "All"
    latitude: float = 11.0168
    longitude: float = 76.9558
    radius_meters: float = 50.0
