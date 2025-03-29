from typing import Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field


# Shared properties
class WeatherDataBase(BaseModel):
    beach_id: int
    timestamp: datetime
    source: str = "stormglass"
    
    # Wave data
    wave_height: Optional[float] = None
    wave_direction: Optional[float] = None
    wave_period: Optional[float] = None
    
    # Swell data
    swell_height: Optional[float] = None
    swell_direction: Optional[float] = None
    swell_period: Optional[float] = None
    
    # Wind data
    wind_speed: Optional[float] = None
    wind_direction: Optional[float] = None
    wind_gust: Optional[float] = None
    
    # Temperature data
    water_temperature: Optional[float] = None
    air_temperature: Optional[float] = None
    
    # Current data
    current_speed: Optional[float] = None
    current_direction: Optional[float] = None
    
    # Marine bio data
    chlorophyll: Optional[float] = None
    salinity: Optional[float] = None
    ph: Optional[float] = None
    oxygen: Optional[float] = None
    
    # Additional data
    additional_data: Optional[Dict[str, Any]] = None
    
    # Suitability scores
    safety_score: Optional[int] = None
    suitability_level: Optional[str] = None


# Properties to receive on weather data creation
class WeatherDataCreate(WeatherDataBase):
    pass


# Properties to receive on weather data update
class WeatherDataUpdate(BaseModel):
    # Wave data
    wave_height: Optional[float] = None
    wave_direction: Optional[float] = None
    wave_period: Optional[float] = None
    
    # Swell data
    swell_height: Optional[float] = None
    swell_direction: Optional[float] = None
    swell_period: Optional[float] = None
    
    # Wind data
    wind_speed: Optional[float] = None
    wind_direction: Optional[float] = None
    wind_gust: Optional[float] = None
    
    # Temperature data
    water_temperature: Optional[float] = None
    air_temperature: Optional[float] = None
    
    # Current data
    current_speed: Optional[float] = None
    current_direction: Optional[float] = None
    
    # Marine bio data
    chlorophyll: Optional[float] = None
    salinity: Optional[float] = None
    ph: Optional[float] = None
    oxygen: Optional[float] = None
    
    # Additional data
    additional_data: Optional[Dict[str, Any]] = None
    
    # Suitability scores
    safety_score: Optional[int] = None
    suitability_level: Optional[str] = None


# Properties shared by models stored in DB
class WeatherDataInDBBase(WeatherDataBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# Properties to return to client
class WeatherData(WeatherDataInDBBase):
    pass


# Properties properties stored in DB
class WeatherDataInDB(WeatherDataInDBBase):
    pass


# Properties for beach conditions summary
class BeachConditions(BaseModel):
    beach_id: int
    beach_name: str
    timestamp: datetime
    wave_height: Optional[float] = None
    wind_speed: Optional[float] = None
    water_temperature: Optional[float] = None
    suitability_level: str
    safety_score: int
    warning_message: Optional[str] = None 