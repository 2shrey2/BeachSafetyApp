import logging
import asyncio
from datetime import datetime
from typing import List, Optional
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError
from sqlalchemy.sql import text

from app.core.config import settings
from app.db.session import SessionLocal, engine
from app.crud.beach import get_beaches
from app.tasks.weather import fetch_and_store_weather_data

logger = logging.getLogger(__name__)

# Move the fetch_weather function outside the class
async def fetch_weather():
    """Fetch weather data for all active beaches"""
    async with asyncio.Lock():
        db = SessionLocal()
        try:
            beaches = get_beaches(db, is_active=True)
            tasks = []
            for beach in beaches:
                tasks.append(fetch_and_store_weather_data(db, beach.id))
            if tasks:
                results = await asyncio.gather(*tasks, return_exceptions=True)
                success_count = sum(1 for r in results if r is True)
                error_count = len(results) - success_count
                logger.info(f"Weather data fetch completed: {success_count} successful, {error_count} failed")
        finally:
            db.close()


class WeatherScheduler:
    """Scheduler for weather data fetch tasks"""
    
    def __init__(self):
        self.scheduler: Optional[AsyncIOScheduler] = None
        self.initialized = False
        
    def init_scheduler(self) -> None:
        """Initialize the scheduler"""
        if self.initialized:
            return
            
        logger.info("Initializing weather data scheduler")
        
        try:
            # Create scheduler with SQLAlchemy job store
            jobstore = {
                'default': SQLAlchemyJobStore(url=str(settings.DATABASE_URL))
            }
            
            self.scheduler = AsyncIOScheduler(jobstores=jobstore)
            self.initialized = True
            logger.info("Scheduler initialized with database jobstore")
        except Exception as e:
            logger.warning(f"Failed to initialize scheduler with database: {e}")
            logger.info("Using in-memory scheduler instead")
            # Create in-memory scheduler as fallback
            self.scheduler = AsyncIOScheduler()
            self.initialized = True
        
    def start(self) -> None:
        """Start the scheduler"""
        try:
            if not self.initialized:
                self.init_scheduler()
                
            if self.scheduler and not self.scheduler.running:
                logger.info("Starting weather data scheduler")
                
                # Test database connection before scheduling
                try:
                    with SessionLocal() as db:
                        # Just test a simple query
                        count = db.execute(text("SELECT 1")).fetchone()  # Fixed warning
                        logger.info("Database connection successful, starting scheduler")
                except Exception as e:
                    logger.warning(f"Database connection test failed: {e}")
                    logger.warning("Scheduler will start but may encounter errors when running jobs")
                
                self.scheduler.start()
                self.schedule_regular_tasks()
        except Exception as e:
            logger.error(f"Failed to start scheduler: {e}")
            
    def shutdown(self) -> None:
        """Shutdown the scheduler"""
        try:
            if self.scheduler and self.scheduler.running:
                logger.info("Shutting down weather data scheduler")
                self.scheduler.shutdown()
        except Exception as e:
            logger.error(f"Error shutting down scheduler: {e}")
            
    def schedule_regular_tasks(self) -> None:
        """Schedule regular data fetch tasks"""
        try:
            if not self.scheduler:
                logger.error("Scheduler not initialized")
                return

            # Schedule the standalone function
            self.scheduler.add_job(
                fetch_weather,
                'interval',
                hours=1,
                id='fetch_all_beaches_weather',
                replace_existing=True,
                next_run_time=datetime.utcnow()
            )
            logger.info("Weather data fetch job scheduled successfully")
        except Exception as e:
            logger.error(f"Failed to schedule tasks: {e}")


# Create global scheduler
scheduler = WeatherScheduler()