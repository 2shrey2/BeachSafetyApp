import logging
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from app.services.stormglass import StormGlassService
from app.services.suitability import SuitabilityService
from app.services.notification import NotificationService
from app.crud.beach import get_beach
from app.crud.weather import get_latest_weather_data, create_weather_data
from app.schemas.weather_data import WeatherDataCreate

logger = logging.getLogger(__name__)


async def fetch_and_store_weather_data(db: Session, beach_id: int) -> bool:
    """
    Fetch weather data from StormGlass API and store in database
    
    Args:
        db: Database session
        beach_id: Beach ID
        
    Returns:
        bool: Success status
    """
    try:
        # Get beach
        beach = get_beach(db, id=beach_id)
        if not beach:
            logger.error(f"Beach with ID {beach_id} not found")
            return False
        
        # Initialize services
        stormglass_service = StormGlassService()
        suitability_service = SuitabilityService()
        notification_service = NotificationService()
        
        # Get latest data to avoid duplication
        latest_data = get_latest_weather_data(db, beach_id=beach_id)
        start_time = datetime.utcnow()
        if latest_data:
            # If we have data less than 3 hours old, skip
            if (start_time - latest_data.timestamp) < timedelta(hours=3):
                logger.info(f"Recent data exists for beach {beach.name}, skipping fetch")
                return True
        
        # Set time range for data fetch
        end_time = start_time + timedelta(days=2)  # Forecast for 2 days
        
        # Fetch data from StormGlass API
        logger.info(f"Fetching weather data for beach {beach.name}")
        stormglass_data = await stormglass_service.get_combined_data(
            latitude=beach.latitude,
            longitude=beach.longitude,
            start=start_time,
            end=end_time
        )
        
        # Check for errors
        if "error" in stormglass_data.get("marine", {}):
            logger.error(f"Error fetching marine data: {stormglass_data['marine']['message']}")
            return False
            
        # Parse and process data
        parsed_data = suitability_service.parse_stormglass_data(stormglass_data)
        if not parsed_data:
            logger.error("No data parsed from StormGlass API response")
            return False
        
        # Store data in database
        for data_point in parsed_data:
            # Create weather data object
            weather_data_in = WeatherDataCreate(
                beach_id=beach_id,
                timestamp=datetime.fromisoformat(data_point["timestamp"].replace("Z", "+00:00")),
                source="stormglass",
                # Wave data
                wave_height=data_point.get("wave_height"),
                wave_direction=data_point.get("wave_direction"),
                wave_period=data_point.get("wave_period"),
                # Swell data
                swell_height=data_point.get("swell_height"),
                swell_direction=data_point.get("swell_direction"),
                swell_period=data_point.get("swell_period"),
                # Wind data
                wind_speed=data_point.get("wind_speed"),
                wind_direction=data_point.get("wind_direction"),
                wind_gust=data_point.get("wind_gust"),
                # Temperature data
                water_temperature=data_point.get("water_temperature"),
                # Current data
                current_speed=data_point.get("current_speed"),
                current_direction=data_point.get("current_direction"),
                # Marine bio data
                chlorophyll=data_point.get("chlorophyll"),
                salinity=data_point.get("salinity"),
                ph=data_point.get("ph"),
                oxygen=data_point.get("oxygen"),
                # Additional data
                additional_data=data_point.get("additional_data"),
                # Suitability scores
                safety_score=data_point.get("safety_score"),
                suitability_level=data_point.get("suitability_level")
            )
            
            # Save to database
            weather_data = create_weather_data(db, obj_in=weather_data_in)
            logger.info(f"Stored weather data for beach {beach.name} at {weather_data.timestamp}")
            
            # Check if we need to send notifications for dangerous conditions
            if data_point.get("suitability_level") in ["warning", "danger"] and data_point.get("warnings"):
                warning_msg = " ".join(data_point.get("warnings", []))
                logger.info(f"Sending notifications for beach {beach.name}: {warning_msg}")
                notification_service.notify_nearby_users(
                    db=db,
                    beach=beach,
                    warning_message=warning_msg,
                    condition_level=data_point.get("suitability_level")
                )
        
        return True
    except Exception as e:
        logger.exception(f"Error in fetch_and_store_weather_data: {str(e)}")
        return False 