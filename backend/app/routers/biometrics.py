from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.models import User
from app.models.schemas import BiometricRegisterRequest, BiometricRegisterResponse
from app.core.config import settings

router = APIRouter(prefix="/biometrics", tags=["Biometrics"])

@router.post("/register", response_model=BiometricRegisterResponse)
def register_face_biometrics(
    request: BiometricRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Validate vector dimensionality
    if len(request.embedding) != settings.VECTOR_DIMENSION:
        raise HTTPException(
            status_code=400,
            detail=f"Expected {settings.VECTOR_DIMENSION}-float embedding vector, received {len(request.embedding)}"
        )

    # Save registered master vector
    current_user.set_embedding_list(request.embedding)
    db.commit()
    db.refresh(current_user)

    return BiometricRegisterResponse(
        status="success",
        message="Facial biometric vector master profile registered successfully.",
        is_face_registered=True
    )
