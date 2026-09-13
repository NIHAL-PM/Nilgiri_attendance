import logging
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from database import AsyncSessionLocal
from models.user import User
from schemas.auth import Token, LoginRequest, RegisterRequest
from schemas.admin import ForgotPasswordRequest, ResetPasswordRequest
from schemas.user import UserRead
from services.auth_service import AuthService
from utils.dependencies import get_db, get_current_user

logger = logging.getLogger("pulseattend.auth")
router = APIRouter(prefix="/auth", tags=["Authentication & Password Reset"])

@router.post("/register", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email address already registered."
        )
        
    hashed_pwd = AuthService.get_password_hash(req.password)
    new_user = User(
        email=req.email,
        name=req.name,
        hashed_password=hashed_pwd,
        role=req.role,
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalar_one_or_none()
    
    if not user or not AuthService.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    access_token = AuthService.create_access_token(data={"sub": user.id, "email": user.email, "role": user.role})
    return Token(access_token=access_token, token_type="bearer")

@router.post("/login/json", response_model=Token)
async def login_json(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()
    
    if not user or not AuthService.verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
        
    access_token = AuthService.create_access_token(data={"sub": user.id, "email": user.email, "role": user.role})
    return Token(access_token=access_token, token_type="bearer")

@router.get("/me", response_model=UserRead)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/forgot-password")
async def forgot_password(req: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    """
    SECURE PASSWORD RESET REQUEST:
    - Never returns the reset_token in the API response (prevents unauthorized account takeovers).
    - Logs token strictly to internal secure server log for administrator out-of-band delivery.
    - Always returns identical generic response to prevent user enumeration attacks.
    """
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()
    
    if user:
        token, expires = AuthService.generate_reset_token()
        user.reset_token = token
        user.reset_token_expires = expires
        await db.commit()
        
        # Log to secure server console/logs ONLY (never expose via HTTP JSON)
        logger.info(f"SECURE LOG [Password Reset Token for {user.email}]: {token} (Expires: {expires})")
        print(f"🔒 [SECURITY LOG] Password Reset Token generated for {user.email}: {token}")

    # Standard generic response (prevents account enumeration & token leakage)
    return {
        "message": "If an account exists with this email address, a password reset token has been dispatched."
    }

@router.post("/reset-password")
async def reset_password(req: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    """
    RESETS PASSWORD USING SECURE DISPATCHED TOKEN:
    - Requires valid non-expired reset token.
    - Immediately invalidates token upon password update.
    """
    if not req.reset_token or len(req.reset_token) < 16:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password reset token format."
        )

    result = await db.execute(
        select(User).where(User.reset_token == req.reset_token)
    )
    user = result.scalar_one_or_none()
    
    if not user or not user.reset_token_expires or user.reset_token_expires < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired password reset token."
        )
        
    user.hashed_password = AuthService.get_password_hash(req.new_password)
    user.reset_token = None
    user.reset_token_expires = None
    await db.commit()
    
    return {"message": "Password reset successful. You can now log in with your new password."}
