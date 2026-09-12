from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.models import Event, User
from app.models.schemas import EventResponse, EventCreateRequest

router = APIRouter(prefix="/events", tags=["Events"])

@router.get("/active", response_model=List[EventResponse])
def get_active_events(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    events = db.query(Event).filter(Event.is_active == True).all()
    return events

@router.post("/", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
def create_event(
    request: EventCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    existing = db.query(Event).filter(Event.code == request.code).first()
    if existing:
        raise HTTPException(status_code=400, detail="Event with this code already exists.")

    event = Event(
        name=request.name,
        code=request.code,
        description=request.description,
        location_name=request.location_name,
        latitude=request.latitude,
        longitude=request.longitude,
        radius_meters=request.radius_meters,
        is_geofenced=request.is_geofenced,
        start_time=request.start_time,
        end_time=request.end_time,
        is_active=True
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event
