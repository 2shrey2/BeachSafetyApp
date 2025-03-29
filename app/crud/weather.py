from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta

from app.models.weather_data import WeatherData
from app.models.beach import Beach
from app.schemas.weather_data import WeatherDataCreate, BeachConditions


def get_weather_data(db: Session, id: int) -> Optional[WeatherData]:
    """Get weather data by ID"""
    return db.query(WeatherData).filter(WeatherData.id == id).first()


def get_beach_weather_data(
    db: Session,
    beach_id: int,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    skip: int = 0,
    limit: int = 100
) -> List[WeatherData]:
    """
    Get weather data for a specific beach within a time range
    """
    query = db.query(WeatherData).filter(WeatherData.beach_id == beach_id)
    
    if start_date:
        query = query.filter(WeatherData.timestamp >= start_date)
    
    if end_date:
        query = query.filter(WeatherData.timestamp <= end_date)
    
    query = query.order_by(WeatherData.timestamp.desc())
    
    return query.offset(skip).limit(limit).all()


def create_weather_data(db: Session, obj_in: WeatherDataCreate) -> WeatherData:
    """
    Create new weather data
    """
    weather_data = WeatherData(
        beach_id=obj_in.beach_id,
        timestamp=obj_in.timestamp,
        source=obj_in.source,
        # Wave data
        wave_height=obj_in.wave_height,
        wave_direction=obj_in.wave_direction,
        wave_period=obj_in.wave_period,
        # Swell data
        swell_height=obj_in.swell_height,
        swell_direction=obj_in.swell_direction,
        swell_period=obj_in.swell_period,
        # Wind data
        wind_speed=obj_in.wind_speed,
        wind_direction=obj_in.wind_direction,
        wind_gust=obj_in.wind_gust,
        # Temperature data
        water_temperature=obj_in.water_temperature,
        air_temperature=obj_in.air_temperature,
        # Current data
        current_speed=obj_in.current_speed,
        current_direction=obj_in.current_direction,
        # Marine bio data
        chlorophyll=obj_in.chlorophyll,
        salinity=obj_in.salinity,
        ph=obj_in.ph,
        oxygen=obj_in.oxygen,
        # Additional data
        additional_data=obj_in.additional_data,
        # Suitability scores
        safety_score=obj_in.safety_score,
        suitability_level=obj_in.suitability_level
    )
    
    db.add(weather_data)
    db.commit()
    db.refresh(weather_data)
    
    return weather_data


def get_latest_weather_data(db: Session, beach_id: int) -> Optional[WeatherData]:
    """
    Get the latest weather data for a beach
    """
    return db.query(WeatherData).filter(
        WeatherData.beach_id == beach_id
    ).order_by(WeatherData.timestamp.desc()).first()


def get_current_beach_conditions(db: Session, beach_id: int) -> Optional[BeachConditions]:
    """
    Get current beach conditions summary
    """
    # Get beach
    beach = db.query(Beach).filter(Beach.id == beach_id).first()
    if not beach:
        return None
    
    # Get latest weather data
    weather_data = get_latest_weather_data(db, beach_id)
    if not weather_data:
        return None
    
    # Generate warning message
    warning_message = None
    if weather_data.suitability_level == "warning":
        warning_message = "Exercise caution due to moderate conditions."
    elif weather_data.suitability_level == "danger":
        warning_message = "Dangerous conditions present. Not recommended for swimming or water activities."
    
    # Create conditions summary
    conditions = BeachConditions(
        beach_id=beach.id,
        beach_name=beach.name,
        timestamp=weather_data.timestamp,
        wave_height=weather_data.wave_height,
        wind_speed=weather_data.wind_speed,
        water_temperature=weather_data.water_temperature,
        suitability_level=weather_data.suitability_level,
        safety_score=weather_data.safety_score,
        warning_message=warning_message
    )
    
    return conditions


# Create a CRUD object to expose all operations
weather = {
    "get": get_weather_data,
    "get_beach_data": get_beach_weather_data,
    "create": create_weather_data,
    "get_latest": get_latest_weather_data,
    "get_conditions": get_current_beach_conditions
} 