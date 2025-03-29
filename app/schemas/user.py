from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


# Shared properties
class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    is_active: Optional[bool] = True
    is_admin: bool = False
    email_notifications: bool = True
    push_notifications: bool = True
    notification_radius_km: float = 10.0


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str] = None
    current_latitude: Optional[float] = None
    current_longitude: Optional[float] = None


# Properties shared by models stored in DB
class UserInDBBase(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# Additional properties to return via API
class User(UserInDBBase):
    pass


# Additional properties stored in DB
class UserInDB(UserInDBBase):
    hashed_password: str


# Properties for login
class UserLogin(BaseModel):
    email: EmailStr
    password: str


# Properties for token generation
class Token(BaseModel):
    access_token: str
    token_type: str


class TokenPayload(BaseModel):
    sub: Optional[int] = None


# User location update
class UserLocationUpdate(BaseModel):
    latitude: float
    longitude: float 