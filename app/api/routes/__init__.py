from fastapi import APIRouter, Depends, HTTPException
from app.api.routes import beaches, weather, users, auth
from app.db.session import get_db
from app.db.redis import get_redis_connection
from app.services.stormglass import StormGlassService
from sqlalchemy.orm import Session
from sqlalchemy import text
import traceback

api_router = APIRouter()

@api_router.get("/health", tags=["health"])
async def health_check(db: Session = Depends(get_db)):
    """
    Health check endpoint to verify API is running
    """
    try:
        db_type = str(db.bind.engine.url).split("://")[0]
        redis = get_redis_connection()
        redis_status = "connected" if redis else "using in-memory cache"
        storm_glass = StormGlassService()
        storm_glass_status = "using real API" if not storm_glass.use_mock else "using mock data"
        
        # Test database query
        db_status = "ok"
        detail = None
        try:
            result = db.execute(text("SELECT 1")).scalar()
            if result != 1:
                db_status = "error"
                detail = "Unexpected query result"
        except Exception as e:
            db_status = "error"
            detail = str(e)
        
        return {
            "status": "ok",
            "version": "0.1.0",
            "database": {
                "type": db_type,
                "status": db_status,
                "detail": detail
            },
            "redis": redis_status,
            "storm_glass_api": storm_glass_status
        }
    except Exception as e:
        tb = traceback.format_exc()
        return {
            "status": "error",
            "error": str(e),
            "traceback": tb
        }

@api_router.get("/debug", tags=["debug"])
async def debug_info():
    """
    Debug endpoint to get system information
    """
    import sys
    import os
    import platform
    
    # Get module locations
    module_locations = {}
    for name, module in sys.modules.items():
        if hasattr(module, "__file__") and module.__file__:
            if name.startswith("app."):
                module_locations[name] = module.__file__
    
    return {
        "python_version": sys.version,
        "platform": platform.platform(),
        "current_dir": os.getcwd(),
        "app_modules": module_locations,
        "env_variables": {k: "***" if "password" in k.lower() or "key" in k.lower() else v 
                          for k, v in os.environ.items() if k.startswith("POSTGRES") or k.startswith("DATABASE")}
    }

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(beaches.router, prefix="/beaches", tags=["Beaches"])
api_router.include_router(weather.router, prefix="/weather", tags=["Weather"]) 