import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "PulseAttend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # JWT Settings
    SECRET_KEY: str = os.getenv("SECRET_KEY", "pulseattend_super_secret_jwt_key_change_in_production_2026")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Render dynamic PORT binding
    PORT: int = int(os.getenv("PORT", 8000))
    
    # Database Settings (Defaults to SQLite for instant local dev, asyncpg for PostgreSQL)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./pulseattend.db")

    # Biometric & Geofence Defaults
    SIMILARITY_THRESHOLD: float = 0.75
    DEFAULT_GEOFENCE_RADIUS_METERS: float = 50.0

    @property
    def async_database_url(self) -> str:
        url = self.DATABASE_URL
        # Render PostgreSQL connections start with postgres:// or postgresql://
        # SQLAlchemy 2.0 async requires postgresql+asyncpg://
        if url.startswith("postgres://"):
            return url.replace("postgres://", "postgresql+asyncpg://", 1)
        if url.startswith("postgresql://") and not url.startswith("postgresql+asyncpg://"):
            return url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
