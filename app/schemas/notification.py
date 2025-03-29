from typing import Optional
from datetime import datetime
from pydantic import BaseModel


class NotificationBase(BaseModel):
    title: str
    content: str
    notification_type: str = "safety_alert"
    beach_id: Optional[int] = None


class NotificationCreate(NotificationBase):
    user_id: int


class NotificationUpdate(BaseModel):
    is_read: bool = True


class NotificationInDBBase(NotificationBase):
    id: int
    user_id: int
    is_read: bool
    read_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class Notification(NotificationInDBBase):
    """Notification model returned to client"""
    pass 