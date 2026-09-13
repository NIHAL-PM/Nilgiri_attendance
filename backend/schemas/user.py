from pydantic import BaseModel, EmailStr, ConfigDict

class UserRead(BaseModel):
    id: str
    name: str
    email: EmailStr
    avatar_url: str
    role: str
    class_name: str | None = "CS-2026"
    totp_enabled: bool = False
    is_verified: bool
    accuracy_score: float
    total_events: int
    present_count: int
    current_streak: int

    model_config = ConfigDict(from_attributes=True)

class UserBaselineUpload(BaseModel):
    embedding_vector: list[float]
