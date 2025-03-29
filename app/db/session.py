from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import logging
from sqlalchemy.exc import OperationalError, ProgrammingError
from typing import Generator
from dotenv import load_dotenv
import os
import time

from app.core.config import settings

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

# Get database URL from environment or settings
DATABASE_URL = os.getenv("DATABASE_URL", str(settings.DATABASE_URL))
logger.info(f"Using database URL: {DATABASE_URL}")

# Create SQLAlchemy engine with retry logic
max_retries = 3
retry_count = 0
connected = False

while retry_count < max_retries and not connected:
    try:
        engine = create_engine(
            DATABASE_URL,
            pool_pre_ping=True,
            pool_size=5,
            max_overflow=10,
            connect_args={"connect_timeout": 10}
        )
        
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
            
        connected = True
        logger.info("Successfully connected to the database")
        
    except OperationalError as e:
        retry_count += 1
        logger.warning(f"Database connection failed (attempt {retry_count}/{max_retries}): {e}")
        
        if retry_count >= max_retries:
            logger.error(f"Failed to connect to the database after {max_retries} attempts")
            logger.error("Using the URL from DATABASE_URL environment variable or settings.DATABASE_URL")
            logger.error(f"Check your PostgreSQL credentials in .env file")
            raise
            
        time.sleep(2)  # Wait before retrying

# Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class for models
Base = declarative_base()

def get_db() -> Generator:
    """Dependency for getting DB session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_tables() -> None:
    """Create database tables if they don't exist"""
    # Import all models to ensure they are registered
    import app.db.base
    
    logger.info("Creating database tables...")
    max_retries = 3
    current_retry = 0
    
    while current_retry < max_retries:
        try:
            # Test database connection first
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
                logger.info("Database connection successful")
            
            # Try to create tables
            Base.metadata.create_all(bind=engine)
            logger.info("Database tables created successfully")
            return
            
        except OperationalError as e:
            current_retry += 1
            logger.warning(f"Database connection attempt {current_retry} failed: {e}")
            if current_retry >= max_retries:
                logger.error("Failed to connect to database after maximum retries")
                raise
            time.sleep(2)  # Wait before retrying
            
        except ProgrammingError as e:
            if "already exists" in str(e):
                logger.info("Tables already exist, skipping creation")
                return
            logger.error(f"Error creating database tables: {e}")
            raise
            
        except Exception as e:
            logger.error(f"Unexpected error creating database tables: {e}")
            raise