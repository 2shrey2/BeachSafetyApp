import logging
from typing import Dict, Any, List, Optional, Tuple

from app.core.config import settings

logger = logging.getLogger(__name__)


class SuitabilityService:
    """Service for determining beach suitability and safety levels"""
    
    def __init__(self):
        # Load thresholds from settings
        self.wave_height_warning = getattr(settings, 'WAVE_HEIGHT_THRESHOLD_WARNING', 1.5)
        self.wave_height_danger = getattr(settings, 'WAVE_HEIGHT_THRESHOLD_DANGER', 2.5)
        self.wind_speed_warning = getattr(settings, 'WIND_SPEED_THRESHOLD_WARNING', 8.0)
        self.wind_speed_danger = getattr(settings, 'WIND_SPEED_THRESHOLD_DANGER', 15.0)
        self.current_speed_warning = getattr(settings, 'CURRENT_SPEED_THRESHOLD_WARNING', 0.5)
        self.current_speed_danger = getattr(settings, 'CURRENT_SPEED_THRESHOLD_DANGER', 1.0)
    
    def calculate_safety_score(self, weather_data: Dict[str, Any]) -> Tuple[int, str, List[str]]:
        """
        Calculate safety score based on weather data
        
        Args:
            weather_data: Weather data from StormGlass API
            
        Returns:
            Tuple with safety score (0-100), suitability level, and warning messages
        """
        # Initialize variables
        score = 100  # Start with perfect score
        warnings = []
        
        if not weather_data:
            logger.warning("Empty weather data provided for safety calculation")
            return 50, "unknown", ["Insufficient weather data available"]
        
        # Extract wave data
        wave_height = weather_data.get("wave_height")
        
        # Extract wind data
        wind_speed = weather_data.get("wind_speed")
        
        # Extract current data
        current_speed = weather_data.get("current_speed")
        
        # Check wave height
        if wave_height is not None:
            if wave_height >= self.wave_height_danger:
                score -= 40
                warnings.append(f"Dangerous wave height: {wave_height} meters")
            elif wave_height >= self.wave_height_warning:
                score -= 20
                warnings.append(f"Warning: High waves at {wave_height} meters")
        
        # Check wind speed
        if wind_speed is not None:
            if wind_speed >= self.wind_speed_danger:
                score -= 30
                warnings.append(f"Dangerous wind conditions: {wind_speed} m/s")
            elif wind_speed >= self.wind_speed_warning:
                score -= 15
                warnings.append(f"Warning: Strong winds at {wind_speed} m/s")
        
        # Check current speed
        if current_speed is not None:
            if current_speed >= self.current_speed_danger:
                score -= 30
                warnings.append(f"Dangerous currents: {current_speed} m/s")
            elif current_speed >= self.current_speed_warning:
                score -= 15
                warnings.append(f"Warning: Strong currents at {current_speed} m/s")
        
        # If we couldn't evaluate any conditions, return unknown
        if not warnings and (wave_height is None and wind_speed is None and current_speed is None):
            logger.warning("No evaluable conditions in weather data")
            return 50, "unknown", ["Insufficient weather data available"]
        
        # Ensure score is within 0-100 range
        score = max(0, min(100, score))
        
        # Determine suitability level based on score
        if score >= 80:
            suitability = "safe"
        elif score >= 50:
            suitability = "warning"
        else:
            suitability = "danger"
        
        return score, suitability, warnings
    
    def parse_stormglass_data(self, stormglass_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Parse StormGlass API data and prepare it for the database
        
        Args:
            stormglass_data: Data from StormGlass API
            
        Returns:
            List of parsed weather data points
        """
        parsed_data = []
        
        # Check for error in data
        if isinstance(stormglass_data, dict) and "error" in stormglass_data:
            logger.error(f"Error in StormGlass data: {stormglass_data.get('error')} - {stormglass_data.get('message')}")
            return parsed_data
            
        # Handle both "marine" key structure or direct "hours" structure (for mock data)
        hours_data = []
        if "marine" in stormglass_data:
            if "hours" in stormglass_data["marine"]:
                hours_data = stormglass_data["marine"]["hours"]
            else:
                logger.error("Marine data doesn't contain 'hours' key")
                return parsed_data
        elif "hours" in stormglass_data:
            hours_data = stormglass_data["hours"]
        else:
            logger.error("Invalid StormGlass data format - 'hours' not found")
            return parsed_data
        
        if not hours_data:
            logger.warning("Empty hours data in StormGlass response")
            return parsed_data
        
        # Process hourly data
        for hour_data in hours_data:
            try:
                # Extract timestamp
                timestamp = hour_data.get("time")
                if not timestamp:
                    logger.warning("Missing timestamp in hour data")
                    continue
                
                # Extract wave data
                wave_height = self._get_average_value(hour_data, "waveHeight")
                wave_direction = self._get_average_value(hour_data, "waveDirection")
                wave_period = self._get_average_value(hour_data, "wavePeriod")
                
                # Extract swell data
                swell_height = self._get_average_value(hour_data, "swellHeight")
                swell_direction = self._get_average_value(hour_data, "swellDirection")
                swell_period = self._get_average_value(hour_data, "swellPeriod")
                
                # Extract wind data
                wind_speed = self._get_average_value(hour_data, "windSpeed")
                wind_direction = self._get_average_value(hour_data, "windDirection")
                
                # Extract temperature data
                water_temperature = self._get_average_value(hour_data, "waterTemperature")
                
                # Extract current data
                current_speed = self._get_average_value(hour_data, "currentSpeed")
                current_direction = self._get_average_value(hour_data, "currentDirection")
                
                # Extract visibility
                visibility = self._get_average_value(hour_data, "visibility")
                
                # Create weather data point
                weather_data = {
                    "timestamp": timestamp,
                    "wave_height": wave_height,
                    "wave_direction": wave_direction,
                    "wave_period": wave_period,
                    "swell_height": swell_height,
                    "swell_direction": swell_direction,
                    "swell_period": swell_period,
                    "wind_speed": wind_speed,
                    "wind_direction": wind_direction,
                    "water_temperature": water_temperature,
                    "current_speed": current_speed,
                    "current_direction": current_direction,
                    "visibility": visibility,
                    "additional_data": hour_data  # Store full data for reference
                }
                
                # Calculate safety score
                safety_score, suitability_level, warnings = self.calculate_safety_score(weather_data)
                weather_data["safety_score"] = safety_score
                weather_data["suitability_level"] = suitability_level
                weather_data["warnings"] = warnings
                
                parsed_data.append(weather_data)
            except Exception as e:
                logger.error(f"Error parsing hour data: {e}")
                continue
        
        return parsed_data
    
    def _get_average_value(self, data: Dict[str, Any], key: str) -> Optional[float]:
        """
        Extract value from StormGlass data
        
        Args:
            data: Hour data from StormGlass API
            key: Key to extract
            
        Returns:
            Value or None if not available
        """
        try:
            if key not in data:
                return None
            
            # Handle new format with only "sg" source
            if isinstance(data[key], dict) and "sg" in data[key]:
                return data[key]["sg"]
            
            # Fallback to old format with multiple sources (for backward compatibility)
            elif isinstance(data[key], list):
                values = [item["value"] for item in data[key] if "value" in item]
                if not values:
                    return None
                return sum(values) / len(values)
            
            return None
        except Exception as e:
            logger.debug(f"Error getting value for {key}: {e}")
            return None 