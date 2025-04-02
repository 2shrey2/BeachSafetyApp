from sqlalchemy import Column, String, Float, Text, Boolean, Integer
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class Beach(BaseModel):
    """Beach model for storing beach information"""
    name = Column(String(100), nullable=False, index=True)
    description = Column(Text, nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    state = Column(String(50), nullable=False, index=True)
    city = Column(String(50), nullable=False)
    is_active = Column(Boolean, default=True)
    image_url = Column(String(255), nullable=True)
    
    # New fields
    is_favorite = Column(Boolean, default=False)
    rating = Column(Float, nullable=True)
    view_count = Column(Integer, default=0)
    location = Column(String(100), nullable=True)
    
    # Relationships
    weather_data = relationship("WeatherData", back_populates="beach", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Beach {self.name} ({self.city}, {self.state})>" 