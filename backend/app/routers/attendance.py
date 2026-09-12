from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.models import User, Event, Attendance
from app.models.schemas import AttendanceVerifyRequest, AttendanceVerifyResponse
from app.services.biometric_math import compute_cosine_similarity, haversine_distance_meters

router = APIRouter(prefix="/attendance", tags=["Attendance Verification"])

@router.post("/verify", response_model=AttendanceVerifyResponse)
def verify_attendance(
    request: AttendanceVerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. Verify face registration baseline exists
    if not current_user.is_face_registered or not current_user.face_embedding:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Facial biometric registration required before marking attendance."
        )

    # 2. Check Event existence and active state
    event = db.query(Event).filter(
        (Event.id == request.event_id) | (Event.code == request.event_id)
    ).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found.")
    if not event.is_active:
        raise HTTPException(status_code=400, detail="Event is not currently active for attendance.")

    # 3. Optional Geofence validation (checked first before any state is recorded)
    distance = None
    geofence_passed = True
    if event.is_geofenced and event.latitude is not None and event.longitude is not None:
        if request.latitude is None or request.longitude is None:
            raise HTTPException(
                status_code=400,
                detail="Geofenced event requires GPS coordinates to be submitted."
            )
        distance = haversine_distance_meters(
            request.latitude, request.longitude,
            event.latitude, event.longitude
        )
        if distance > event.radius_meters:
            geofence_passed = False
            raise HTTPException(
                status_code=403,
                detail=f"Out of event boundary. You are {distance:.1f}m away (maximum allowed: {event.radius_meters}m)."
            )

    # 4. Check duplicate attendance (only return existing if geofence passed or not geofenced)
    existing_attendance = db.query(Attendance).filter(
        Attendance.user_id == current_user.id,
        Attendance.event_id == event.id,
        Attendance.status == "PRESENT"
    ).first()
    if existing_attendance:
        return AttendanceVerifyResponse(
            status="verified",
            student_name=current_user.full_name,
            similarity_score=existing_attendance.similarity_score,
            message="Attendance already recorded for this event.",
            timestamp=existing_attendance.verification_time,
            geofence_verified=True,
            attendance_id=existing_attendance.id
        )

    # 5. Biometric Cosine Similarity Matching
    master_vector = current_user.get_embedding_list()
    similarity = compute_cosine_similarity(request.embedding, master_vector)

    if similarity < settings.SIMILARITY_THRESHOLD:
        # Record failed attempt
        failed_log = Attendance(
            user_id=current_user.id,
            event_id=event.id,
            similarity_score=similarity,
            status="REJECTED",
            latitude=request.latitude,
            longitude=request.longitude,
            distance_meters=distance
        )
        db.add(failed_log)
        db.commit()

        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Verification Failed: Face does not match registered account (Score: {similarity:.2f}, Required: >={settings.SIMILARITY_THRESHOLD})."
        )

    # 6. Biometric passed! Log attendance
    attendance = Attendance(
        user_id=current_user.id,
        event_id=event.id,
        similarity_score=similarity,
        status="PRESENT",
        latitude=request.latitude,
        longitude=request.longitude,
        distance_meters=distance,
        verification_time=datetime.now(timezone.utc)
    )
    db.add(attendance)
    db.commit()
    db.refresh(attendance)

    return AttendanceVerifyResponse(
        status="verified",
        student_name=current_user.full_name,
        similarity_score=similarity,
        message="Attendance recorded successfully.",
        timestamp=attendance.verification_time,
        geofence_verified=geofence_passed,
        attendance_id=attendance.id
    )
