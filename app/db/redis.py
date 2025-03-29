import redis
import json
import logging
from typing import Any, Optional, Dict
import time

from app.core.config import settings

logger = logging.getLogger(__name__)

# In-memory cache fallback
in_memory_cache: Dict[str, Dict[str, Any]] = {}

# Try to create Redis client
redis_client = None
use_redis = True

try:
    redis_client = redis.Redis(
        host=settings.REDIS_HOST,
        port=settings.REDIS_PORT,
        db=settings.REDIS_DB,
        password=settings.REDIS_PASSWORD,
        decode_responses=True,
        socket_timeout=2.0  # Short timeout to fail quickly
    )
    # Test connection
    redis_client.ping()
    logger.info("Connected to Redis server")
except (redis.ConnectionError, redis.exceptions.TimeoutError) as e:
    logger.warning(f"Redis connection failed: {e}")
    logger.warning("Using in-memory cache instead")
    use_redis = False
except Exception as e:
    logger.warning(f"Redis error: {e}")
    logger.warning("Using in-memory cache instead")
    use_redis = False

def get_redis_connection():
    """Get Redis connection"""
    return redis_client if use_redis else None

def set_cache(key: str, value: Any, expiration: int = settings.STORMGLASS_CACHE_TTL) -> bool:
    """
    Set cache value in Redis or in-memory
    
    Args:
        key: Cache key
        value: Value to cache
        expiration: Cache expiration time in seconds
        
    Returns:
        bool: Success status
    """
    if use_redis and redis_client:
        try:
            serialized_value = json.dumps(value)
            redis_client.set(key, serialized_value, ex=expiration)
            return True
        except Exception as e:
            logger.error(f"Error setting Redis cache: {e}")
            # Fall back to in-memory cache
            logger.info("Falling back to in-memory cache")
            
    # Use in-memory cache
    try:
        expiry_time = int(time.time()) + expiration
        in_memory_cache[key] = {
            "value": value,
            "expiry": expiry_time
        }
        return True
    except Exception as e:
        logger.error(f"Error setting in-memory cache: {e}")
        return False

def get_cache(key: str) -> Optional[Any]:
    """
    Get cached value from Redis or in-memory
    
    Args:
        key: Cache key
        
    Returns:
        Any: Cached value or None if not found
    """
    if use_redis and redis_client:
        try:
            cached_value = redis_client.get(key)
            if cached_value:
                return json.loads(cached_value)
        except Exception as e:
            logger.error(f"Error getting Redis cache: {e}")
            # Fall back to in-memory cache
            logger.info("Falling back to in-memory cache")
    
    # Use in-memory cache
    try:
        cache_entry = in_memory_cache.get(key)
        if cache_entry:
            # Check if expired
            current_time = int(time.time())
            if current_time < cache_entry["expiry"]:
                return cache_entry["value"]
            else:
                # Clean up expired entry
                del in_memory_cache[key]
        return None
    except Exception as e:
        logger.error(f"Error getting in-memory cache: {e}")
        return None

def delete_cache(key: str) -> bool:
    """
    Delete cached value from Redis or in-memory
    
    Args:
        key: Cache key
        
    Returns:
        bool: Success status
    """
    success = True
    
    if use_redis and redis_client:
        try:
            redis_client.delete(key)
        except Exception as e:
            logger.error(f"Error deleting Redis cache: {e}")
            success = False
    
    # Also remove from in-memory cache
    try:
        if key in in_memory_cache:
            del in_memory_cache[key]
    except Exception as e:
        logger.error(f"Error deleting in-memory cache: {e}")
        success = False
        
    return success 