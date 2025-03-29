from datetime import datetime
from sqlalchemy import Column, String, Float, Integer, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class WeatherData(BaseModel):
    """WeatherData model for storing beach weather information"""
    beach_id = Column(Integer, ForeignKey("beach.id"), nullable=False, index=True)
    timestamp = Column(DateTime, nullable=False, index=True)
    source = Column(String(50), nullable=False, default="stormglass")
    
    # Wave data
    wave_height = Column(Float, nullable=True)
    wave_direction = Column(Float, nullable=True)
    wave_period = Column(Float, nullable=True)
    
    # Swell data
    swell_height = Column(Float, nullable=True)
    swell_direction = Column(Float, nullable=True)
    swell_period = Column(Float, nullable=True)
    
    # Wind data
    wind_speed = Column(Float, nullable=True)
    wind_direction = Column(Float, nullable=True)
    wind_gust = Column(Float, nullable=True)
    
    # Temperature data
    water_temperature = Column(Float, nullable=True)
    air_temperature = Column(Float, nullable=True)
    
    # Current data
    current_speed = Column(Float, nullable=True)
    current_direction = Column(Float, nullable=True)
    
    # Marine bio data
    chlorophyll = Column(Float, nullable=True)
    salinity = Column(Float, nullable=True)
    ph = Column(Float, nullable=True)
    oxygen = Column(Float, nullable=True)
    
    # Additional data stored as JSON
    additional_data = Column(JSON, nullable=True)
    
    # Suitability scores
    safety_score = Column(Integer, nullable=True)  # 0-100 score
    suitability_level = Column(String(20), nullable=True)  # "safe", "warning", "danger"
    
    # Relationships
    beach = relationship("Beach", back_populates="weather_data")
    
    def __repr__(self):
        return f"<WeatherData for beach_id={self.beach_id} at {self.timestamp}>" 