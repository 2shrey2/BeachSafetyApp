from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
import logging
import os
from app.api.routes import api_router
from app.core.config import settings
from app.db.session import create_tables, engine
from app.tasks.scheduler import scheduler

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def create_application() -> FastAPI:
    application = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="Beach Safety App API",
        openapi_url=f"{settings.API_V1_STR}/openapi.json",
    )

    # Set all CORS enabled origins
    if settings.BACKEND_CORS_ORIGINS:
        application.add_middleware(
            CORSMiddleware,
            allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # Include API router
    application.include_router(api_router, prefix=settings.API_V1_STR)

    @application.on_event("startup")
    async def startup_event():
        logger.info("Starting up Beach Safety application...")
        try:
            # Create database tables
            create_tables()
            
            # Start scheduler only if we're using PostgreSQL
            if 'postgresql' in str(engine.url):
                logger.info("Starting scheduler...")
                scheduler.start()
            else:
                logger.warning("Using SQLite database - scheduler disabled")
        except Exception as e:
            logger.error(f"Error during startup: {e}")
            # We'll continue running the app even if there are database issues
            # so the user can still access the API documentation and diagnostics

    @application.on_event("shutdown")
    async def shutdown_event():
        logger.info("Shutting down Beach Safety application...")
        # Shutdown scheduler if it's running
        if hasattr(scheduler, 'scheduler') and scheduler.scheduler and scheduler.scheduler.running:
            logger.info("Shutting down scheduler...")
            scheduler.shutdown()

    return application


app = create_application() 