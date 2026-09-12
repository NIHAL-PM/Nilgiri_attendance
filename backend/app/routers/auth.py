from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token
from app.models.models import User
from app.models.schemas import StudentRegisterRequest, LoginRequest, TokenResponse, UserProfileResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register-student", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register_student(request: StudentRegisterRequest, db: Session = Depends(get_db)):
    # Check if student email or ID already exists
    if db.query(User).filter(User.email == request.email).first():
        raise HTTPException(status_code=400, detail="A student with this email already exists.")
    if db.query(User).filter(User.student_id == request.student_id).first():
        raise HTTPException(status_code=400, detail="A student with this Student ID already exists.")
    
    user = User(
        email=request.email,
        student_id=request.student_id,
        full_name=request.full_name,
        hashed_password=get_password_hash(request.password),
        role="student",
        is_face_registered=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserProfileResponse(
            id=user.id,
            email=user.email,
            student_id=user.student_id,
            full_name=user.full_name,
            role=user.role,
            is_face_registered=user.is_face_registered,
            face_registered_at=user.face_registered_at
        )
    )

@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    # Search by email or student_id
    user = db.query(User).filter(
        (User.email == request.email_or_id) | (User.student_id == request.email_or_id)
    ).first()

    if not user or not verify_password(request.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials. Check your email/ID and password."
        )

    token = create_access_token(user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserProfileResponse(
            id=user.id,
            email=user.email,
            student_id=user.student_id,
            full_name=user.full_name,
            role=user.role,
            is_face_registered=user.is_face_registered,
            face_registered_at=user.face_registered_at
        )
    )
