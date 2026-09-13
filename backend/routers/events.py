from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from models.event import Event
from schemas.event import EventRead, EventCreate
from utils.dependencies import get_db, get_current_user
from models.user import User

router = APIRouter(prefix="/events", tags=["Events Management"])

@router.get("/", response_model=list[EventRead])
async def list_all_events(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """List all events (active & past) for event management"""
    result = await db.execute(select(Event).order_by(Event.start_time.desc()))
    return result.scalars().all()

@router.get("/active", response_model=EventRead | None)
async def get_active_event(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(Event).where(Event.is_active == True).limit(1))
    event = result.scalar_one_or_none()
    
    # Seed default active event if DB is empty
    if not event:
        now = datetime.utcnow()
        event = Event(
            title="Annual Tech Symposium 2026",
            venue="Main Auditorium, Block C",
            start_time=now - timedelta(minutes=15),
            end_time=now + timedelta(hours=3),
            is_active=True,
            image_tag="cyan",
            latitude=11.0168,
            longitude=76.9558,
            radius_meters=50.0
        )
        db.add(event)
        await db.commit()
        await db.refresh(event)
        
    return event

@router.get("/upcoming", response_model=list[EventRead])
async def get_upcoming_events(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(Event).where(Event.is_active == False).order_by(Event.start_time.asc()))
    events = result.scalars().all()
    
    # Seed default upcoming events if none exist
    if not events:
        now = datetime.utcnow()
        demo_upcoming = [
            Event(
                title="AI & Neural Net Workshop",
                venue="Lab 4, Innovation Wing",
                start_time=now + timedelta(days=1),
                end_time=now + timedelta(days=1, hours=3),
                is_active=False,
                image_tag="green"
            ),
            Event(
                title="Cybersecurity Hackathon",
                venue="Central Seminar Hall",
                start_time=now + timedelta(days=5),
                end_time=now + timedelta(days=5, hours=12),
                is_active=False,
                image_tag="red"
            )
        ]
        db.add_all(demo_upcoming)
        await db.commit()
        for e in demo_upcoming:
            await db.refresh(e)
        return demo_upcoming
        
    return events

@router.post("/", response_model=EventRead, status_code=status.HTTP_201_CREATED)
async def create_event(
    req: EventCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new event (Admins & Teachers)"""
    new_event = Event(**req.model_dump())
    db.add(new_event)
    await db.commit()
    await db.refresh(new_event)
    return new_event

@router.put("/{event_id}", response_model=EventRead)
async def update_event(
    event_id: str,
    req: EventCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update an existing event or activate/deactivate it"""
    result = await db.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        
    for key, value in req.model_dump().items():
        setattr(event, key, value)
        
    await db.commit()
    await db.refresh(event)
    return event

@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event(
    event_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete an event"""
    result = await db.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        
    await db.delete(event)
    await db.commit()
