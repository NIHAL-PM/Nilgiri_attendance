import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "PulseAttend / VeriFace"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day
    
    # Biometrics & Matching
    SIMILARITY_THRESHOLD: float = 0.75  # Cosine similarity threshold (>= 0.75 passes)
    VECTOR_DIMENSION: int = 512
    
    # Geofencing
    DEFAULT_GEOFENCE_RADIUS_METERS: float = 50.0
    
    # Database (Defaults to SQLite for instant local run, supports PostgreSQL/pgvector)
    DATABASE_URL: str = "sqlite:///./pulse_attend.db"

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
