from pydantic import BaseModel, EmailStr

class AdminCreateUserRequest(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str = "teacher"  # 'teacher' or 'student'
    class_name: str = "CS-2026"

class TOTPVerifyRequest(BaseModel):
    totp_code: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: str
