import secrets
from datetime import datetime, timedelta, timezone
import jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from config import settings
from database import AsyncSessionLocal

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class AuthService:
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password, hashed_password)

    @staticmethod
    def get_password_hash(password: str) -> str:
        return pwd_context.hash(password)

    @staticmethod
    def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.now(timezone.utc) + expires_delta
        else:
            expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        return encoded_jwt

    @staticmethod
    def decode_access_token(token: str) -> dict | None:
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            return payload
        except jwt.PyJWTError:
            return None

    @staticmethod
    def generate_reset_token() -> tuple[str, datetime]:
        """Generates a secure random 32-byte hexadecimal token valid for 1 hour"""
        token = secrets.token_hex(32)
        expires = datetime.utcnow() + timedelta(hours=1)
        return token, expires

    @staticmethod
    async def seed_initial_admin():
        """Seeds default initial Admin: admin@nilgiricollege.ac.in / nuamansir123"""
        from models.user import User
        async with AsyncSessionLocal() as db:
            result = await db.execute(select(User).where(User.email == "admin@nilgiricollege.ac.in"))
            admin = result.scalar_one_or_none()
            if not admin:
                hashed_pwd = AuthService.get_password_hash("nuamansir123")
                admin = User(
                    email="admin@nilgiricollege.ac.in",
                    name="System Administrator (Nuaman Sir)",
                    hashed_password=hashed_pwd,
                    role="admin",
                    class_name="Admin",
                    is_verified=True,
                )
                db.add(admin)
                await db.commit()
