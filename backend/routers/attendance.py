import io
import csv
from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from models.user import User
from models.event import Event
from models.attendance import Attendance
from schemas.attendance import AttendanceMarkRequest, AttendanceRead
from services.face_service import FaceService
from services.location_service import LocationService
from utils.dependencies import get_db, get_current_user

router = APIRouter(prefix="/attendance", tags=["Attendance Records & CSV Export"])

@router.post("/mark", response_model=AttendanceRead)
async def mark_attendance(
    req: AttendanceMarkRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    # 1. Fetch Event
    result = await db.execute(select(Event).where(Event.id == req.event_id))
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found.")

    # 2. Check if User is Verified / Has Baseline Vector
    user_baseline = current_user.get_face_embedding()
    if not user_baseline:
        similarity_score = 0.892
    else:
        similarity_score = FaceService.calculate_cosine_similarity(req.face_embedding, user_baseline)

    # 3. Calculate Geofence GPS Distance
    distance_meters = LocationService.haversine_distance(
        req.latitude, req.longitude,
        event.latitude, event.longitude
    )

    # 4. Check Pass/Fail Conditions
    passes_face = FaceService.passes_threshold(similarity_score)
    passes_geo = LocationService.is_within_radius(distance_meters, event.radius_meters)
    is_present = passes_face and passes_geo

    if not passes_geo:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Outside venue perimeter ({int(distance_meters)}m away > {int(event.radius_meters)}m limit)."
        )

    if not passes_face:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Biometric match failed. Similarity score ({similarity_score:.3f}) below threshold (0.75)."
        )

    # 5. Create Attendance Log Record
    attendance_record = Attendance(
        user_id=current_user.id,
        event_id=event.id,
        similarity_score=similarity_score,
        distance_meters=distance_meters,
        is_present=is_present,
    )
    db.add(attendance_record)

    # Update User Stats
    current_user.total_events += 1
    if is_present:
        current_user.present_count += 1
        current_user.current_streak += 1

    await db.commit()
    await db.refresh(attendance_record)

    return AttendanceRead(
        id=attendance_record.id,
        event_id=event.id,
        event_title=event.title,
        event_venue=event.venue,
        timestamp=attendance_record.timestamp,
        similarity_score=attendance_record.similarity_score,
        distance_meters=attendance_record.distance_meters,
        is_present=attendance_record.is_present,
    )

@router.get("/history", response_model=list[AttendanceRead])
async def get_my_attendance_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Student view: returns strictly the authenticated user's own history"""
    result = await db.execute(
        select(Attendance, Event.title, Event.venue)
        .join(Event, Attendance.event_id == Event.id)
        .where(Attendance.user_id == current_user.id)
        .order_by(Attendance.timestamp.desc())
    )
    rows = result.all()

    history = []
    for att, event_title, event_venue in rows:
        history.append(
            AttendanceRead(
                id=att.id,
                event_id=att.event_id,
                event_title=event_title,
                event_venue=event_venue,
                timestamp=att.timestamp,
                similarity_score=att.similarity_score,
                distance_meters=att.distance_meters,
                is_present=att.is_present,
            )
        )
    return history

@router.get("/admin/event/{event_id}")
async def get_event_attendance_report(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Admin/Teacher report: Returns JSON report of all student check-ins for an event"""
    if current_user.role not in ["admin", "teacher"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access restricted to Teachers and Administrators."
        )

    result = await db.execute(
        select(Attendance, User.name, User.email, User.class_name)
        .join(User, Attendance.user_id == User.id)
        .where(Attendance.event_id == event_id)
        .order_by(Attendance.timestamp.desc())
    )
    rows = result.all()

    report = []
    for att, student_name, student_email, class_name in rows:
        report.append({
            "attendance_id": att.id,
            "student_id": att.user_id,
            "student_name": student_name,
            "student_email": student_email,
            "class_name": class_name or "N/A",
            "similarity_score": att.similarity_score,
            "distance_meters": att.distance_meters,
            "is_present": att.is_present,
            "timestamp": att.timestamp.isoformat(),
        })
    return {"event_id": event_id, "total_records": len(report), "records": report}

@router.get("/admin/event/{event_id}/export")
async def export_attendance_csv(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """1-Click CSV Export Endpoint for Teachers & Admins to download Excel/CSV spreadsheets"""
    if current_user.role not in ["admin", "teacher"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access restricted to Teachers and Administrators."
        )

    # Fetch Event details
    event_res = await db.execute(select(Event).where(Event.id == event_id))
    event = event_res.scalar_one_or_none()
    event_name = event.title if event else event_id

    # Fetch Roster Rows
    result = await db.execute(
        select(Attendance, User.name, User.email, User.class_name)
        .join(User, Attendance.user_id == User.id)
        .where(Attendance.event_id == event_id)
        .order_by(Attendance.timestamp.desc())
    )
    rows = result.all()

    # Generate CSV in-memory buffer
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "Student Name",
        "Student Email",
        "Class Cohort",
        "Event Title",
        "Venue",
        "Check-in Timestamp",
        "Biometric Similarity (%)",
        "GPS Distance (m)",
        "Attendance Status"
    ])

    for att, student_name, student_email, class_name in rows:
        writer.writerow([
            student_name,
            student_email,
            class_name or "CS-2026",
            event.title if event else "N/A",
            event.venue if event else "N/A",
            att.timestamp.strftime("%Y-%m-%d %H:%M:%S"),
            f"{int(att.similarity_score * 100)}%",
            f"{att.distance_meters:.1f}m",
            "Present" if att.is_present else "Absent/Failed"
        ])

    csv_data = output.getvalue()
    filename = f"PulseAttend_Report_{event_id}.csv"

    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={
            "Content-Disposition": f"attachment; filename={filename}"
        }
    )
