import httpx
import logging
import json
import random
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional

from app.core.config import settings
from app.db.redis import get_cache, set_cache

logger = logging.getLogger(__name__)


class StormGlassService:
    """Service for interacting with StormGlass API"""
    
    def __init__(self):
        self.api_key = settings.STORMGLASS_API_KEY
        self.base_url = settings.STORMGLASS_BASE_URL
        self.headers = {
            "Authorization": self.api_key
        }
        self.cache_ttl = settings.STORMGLASS_CACHE_TTL
        self.use_mock = not self.api_key or self.api_key == ""
        if self.use_mock:
            logger.warning("No StormGlass API key provided, using mock data")
    
    async def get_marine_data(
        self,
        latitude: float,
        longitude: float,
        start: Optional[datetime] = None,
        end: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """
        Get marine weather data from StormGlass API
        
        Args:
            latitude: Location latitude
            longitude: Location longitude
            start: Start time (defaults to current time)
            end: End time (defaults to start + 1 day)
            
        Returns:
            Dictionary with marine weather data
        """
        # If no API key is provided, return mock data
        if self.use_mock:
            return self._generate_mock_marine_data(start, end)
            
        # Set default time range if not provided
        if not start:
            start = datetime.utcnow()
        if not end:
            end = start + timedelta(days=1)
        
        # Generate cache key
        cache_key = f"marine:{latitude}:{longitude}:{start.isoformat()}:{end.isoformat()}"
        
        # Check if data is in cache
        cached_data = get_cache(cache_key)
        if cached_data:
            logger.info(f"Using cached marine data for {latitude}, {longitude}")
            return cached_data
        
        # Parameters for API request - use only specific parameters and sg source
        params = {
            "lat": latitude,
            "lng": longitude,
            "params": ",".join([
                "waveHeight", "waveDirection", "wavePeriod",
                "swellHeight", "swellDirection", "swellPeriod",
                "windSpeed", "windDirection", "visibility",
                "waterTemperature", "currentSpeed", "currentDirection"
            ]),
            "source": "sg",  # Only use StormGlass source
            "start": start.isoformat(),
            "end": end.isoformat()
        }
        
        try:
            async with httpx.AsyncClient() as client:
                logger.info(f"Fetching marine data from StormGlass API for {latitude}, {longitude}")
                response = await client.get(
                    f"{self.base_url}/weather/point",
                    headers=self.headers,
                    params=params,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    logger.info(f"Successfully fetched marine data: {len(data.get('hours', []))} hours")
                    # Cache the data
                    set_cache(cache_key, data, self.cache_ttl)
                    return data
                else:
                    logger.error(f"StormGlass API error: {response.status_code} - {response.text}")
                    return {"error": f"API Error: {response.status_code}", "message": response.text}
                    
        except Exception as e:
            logger.error(f"Error fetching marine data: {str(e)}")
            return {"error": "Connection Error", "message": str(e)}
    
    async def get_combined_data(
        self,
        latitude: float,
        longitude: float,
        start: Optional[datetime] = None,
        end: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """
        Get marine data (previously combined marine and tide)
        
        Args:
            latitude: Location latitude
            longitude: Location longitude
            start: Start time (defaults to current time)
            end: End time (defaults to start + 1 day)
            
        Returns:
            Dictionary with marine data
        """
        marine_data = await self.get_marine_data(latitude, longitude, start, end)
        
        # For compatibility with existing code
        return {
            "marine": marine_data
        }
        
    def _generate_mock_marine_data(self, start: Optional[datetime] = None, end: Optional[datetime] = None) -> Dict[str, Any]:
        """Generate mock marine data for development/testing"""
        if not start:
            start = datetime.utcnow()
        if not end:
            end = start + timedelta(days=1)
            
        hours = []
        current_time = start
        
        while current_time <= end:
            # Generate random values for each parameter - only using sg source format
            hours.append({
                "time": current_time.isoformat(),
                "waveHeight": {"sg": round(random.uniform(0.5, 3.0), 2)},
                "waveDirection": {"sg": round(random.uniform(0, 360), 1)},
                "wavePeriod": {"sg": round(random.uniform(5, 15), 1)},
                "swellHeight": {"sg": round(random.uniform(0.2, 2.0), 2)},
                "swellDirection": {"sg": round(random.uniform(0, 360), 1)},
                "swellPeriod": {"sg": round(random.uniform(5, 20), 1)},
                "windSpeed": {"sg": round(random.uniform(2, 20), 1)},
                "windDirection": {"sg": round(random.uniform(0, 360), 1)},
                "visibility": {"sg": round(random.uniform(5, 20), 1)},
                "waterTemperature": {"sg": round(random.uniform(20, 30), 1)},
                "currentSpeed": {"sg": round(random.uniform(0.1, 1.5), 2)},
                "currentDirection": {"sg": round(random.uniform(0, 360), 1)}
            })
            
            current_time += timedelta(hours=1)
            
        return {
            "hours": hours,
            "meta": {
                "isMock": True
            }
        } 