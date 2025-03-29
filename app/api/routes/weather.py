from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Any, List, Optional
from datetime import datetime, timedelta

from app.api.deps import get_db, get_current_active_admin
from app.models.user import User
from app.schemas.weather_data import WeatherData, WeatherDataCreate, BeachConditions
from app.crud.weather import get_beach_weather_data, get_current_beach_conditions
from app.services.stormglass import StormGlassService
from app.services.suitability import SuitabilityService
from app.tasks.weather import fetch_and_store_weather_data

router = APIRouter()


@router.get("/beaches/{beach_id}", response_model=List[WeatherData])
async def read_beach_weather(
    beach_id: int,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> Any:
    """
    Get weather data for a specific beach
    """
    if not start_date:
        start_date = datetime.utcnow() - timedelta(days=1)
    if not end_date:
        end_date = datetime.utcnow() + timedelta(days=1)
        
    weather_data = get_beach_weather_data(
        db, beach_id=beach_id, start_date=start_date, end_date=end_date, skip=skip, limit=limit
    )
    return weather_data


@router.post("/beaches/{beach_id}/fetch", response_model=dict)
async def fetch_weather_data(
    beach_id: int,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin)
) -> Any:
    """
    Fetch weather data for a beach from StormGlass API (admin only)
    """
    # Add task to background to fetch and store weather data
    background_tasks.add_task(
        fetch_and_store_weather_data, db, beach_id
    )
    
    return {
        "status": "success",
        "message": f"Weather data fetch for beach {beach_id} started in the background"
    }


@router.get("/beaches/{beach_id}/conditions", response_model=BeachConditions)
async def read_beach_weather_conditions(
    beach_id: int,
    db: Session = Depends(get_db)
) -> Any:
    """
    Get current weather conditions with safety assessment for a beach
    """
    conditions = get_current_beach_conditions(db, beach_id=beach_id)
    if not conditions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach conditions not found"
        )
    return conditions


@router.get("/nearby", response_model=List[BeachConditions])
async def read_nearby_beach_conditions(
    latitude: float,
    longitude: float,
    radius_km: float = 50.0,
    limit: int = 10,
    db: Session = Depends(get_db)
) -> Any:
    """
    Get conditions for beaches near a specific location
    """
    # This will be implemented in the beach CRUD module
    from app.crud.beach import get_nearby_beaches_with_conditions
    
    beaches = get_nearby_beaches_with_conditions(
        db, latitude=latitude, longitude=longitude, radius_km=radius_km, limit=limit
    )
    return beaches 