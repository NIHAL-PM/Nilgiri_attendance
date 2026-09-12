from datetime import datetime, timedelta, timezone
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import Base, engine, SessionLocal
from app.core.security import get_password_hash
from app.models.models import User, Event
from app.routers import auth, biometrics, events, attendance

def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # Seed test student if not exists
        demo_student = db.query(User).filter(User.email == "student@nilgiri.edu").first()
        if not demo_student:
            demo_student = User(
                email="student@nilgiri.edu",
                student_id="STU_9981",
                full_name="Alex Rivera",
                hashed_password=get_password_hash("Student@123"),
                role="student",
                is_face_registered=False
            )
            db.add(demo_student)

        # Seed sample active event
        sample_event = db.query(Event).filter(Event.code == "EVT-9021").first()
        if not sample_event:
            sample_event = Event(
                name="AI & Computer Vision Symposium 2026",
                code="EVT-9021",
                description="Annual keynote on on-device machine learning & biometric intelligence.",
                location_name="Nilgiri Convention Hall A",
                latitude=10.8505,
                longitude=76.2711,
                radius_meters=100.0,
                is_geofenced=True,
                start_time=datetime.now(timezone.utc) - timedelta(hours=1),
                end_time=datetime.now(timezone.utc) + timedelta(hours=4),
                is_active=True
            )
            db.add(sample_event)

        db.commit()
    finally:
        db.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Biometric on-device face attendance verification engine with Cosine similarity matching.",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(biometrics.router, prefix=settings.API_V1_STR)
app.include_router(events.router, prefix=settings.API_V1_STR)
app.include_router(attendance.router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "operational",
        "docs": "/docs"
    }
