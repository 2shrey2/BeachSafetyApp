from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class UserFavorite(BaseModel):
    """UserFavorite model for storing user's favorite beaches"""
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False, index=True)
    beach_id = Column(Integer, ForeignKey("beach.id"), nullable=False, index=True)
    
    # Relationships
    user = relationship("User", back_populates="favorites")
    beach = relationship("Beach")
    
    def __repr__(self):
        return f"<UserFavorite user_id={self.user_id}, beach_id={self.beach_id}>" 