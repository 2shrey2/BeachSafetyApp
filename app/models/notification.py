from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from app.models.base import BaseModel


class Notification(BaseModel):
    """Notification model for storing user notifications"""
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False, index=True)
    beach_id = Column(Integer, ForeignKey("beach.id"), nullable=True, index=True)
    
    title = Column(String(100), nullable=False)
    content = Column(Text, nullable=False)
    notification_type = Column(String(50), nullable=False, default="safety_alert")  # safety_alert, info, custom
    
    # Notification status
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="notifications")
    beach = relationship("Beach")
    
    def __repr__(self):
        return f"<Notification {self.id} for user_id={self.user_id}>"
        
    def mark_as_read(self):
        """Mark notification as read"""
        self.is_read = True
        self.read_at = datetime.utcnow() 