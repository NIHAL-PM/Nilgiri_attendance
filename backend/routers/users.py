from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from models.user import User
from schemas.user import UserRead, UserBaselineUpload
from utils.dependencies import get_db, get_current_user

router = APIRouter(prefix="/users", tags=["Users & Biometrics"])

@router.post("/baseline", response_model=UserRead)
async def upload_baseline(
    req: UserBaselineUpload,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if not req.embedding_vector or len(req.embedding_vector) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Embedding vector cannot be empty."
        )
        
    current_user.set_face_embedding(req.embedding_vector)
    await db.commit()
    await db.refresh(current_user)
    return current_user
