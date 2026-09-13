import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "PulseAttend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # JWT Settings
    SECRET_KEY: str = "pulseattend_super_secret_jwt_key_change_in_production_2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Database Settings (Defaults to SQLite for instant local dev, asyncpg for PostgreSQL)
    DATABASE_URL: str = "sqlite+aiosqlite:///./pulseattend.db"

    # Biometric & Geofence Defaults
    SIMILARITY_THRESHOLD: float = 0.75
    DEFAULT_GEOFENCE_RADIUS_METERS: float = 50.0

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
