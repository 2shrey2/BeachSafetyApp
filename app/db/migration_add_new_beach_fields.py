"""
Migration script to add new fields to the Beach model:
- is_favorite
- rating
- view_count
- location

To run this migration:
python -m app.db.migration_add_new_beach_fields
"""

import logging
import psycopg2
from sqlalchemy import create_engine, text
from app.db.session import engine, SessionLocal
from app.core.config import settings
import os

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_migration():
    """Run the migration to add new columns to the beach table"""
    # Get database URL from environment or settings
    DATABASE_URL = os.getenv("DATABASE_URL", str(settings.DATABASE_URL))
    logger.info(f"Using database URL: {DATABASE_URL}")

    # Connect directly with psycopg2 for better transaction control
    try:
        # Extract connection parameters from the SQLAlchemy URL
        connection_parts = DATABASE_URL.replace("postgresql://", "").split("/")
        user_pass_host = connection_parts[0].split("@")
        
        user_pass = user_pass_host[0].split(":")
        username = user_pass[0]
        password = user_pass[1] if len(user_pass) > 1 else None
        
        host_port = user_pass_host[1].split(":")
        host = host_port[0]
        port = host_port[1] if len(host_port) > 1 else "5432"
        
        dbname = connection_parts[1]
        
        # Connect to the database
        conn = psycopg2.connect(
            dbname=dbname,
            user=username,
            password=password,
            host=host,
            port=port
        )
        conn.autocommit = False
        cursor = conn.cursor()
        
        logger.info("Connected to database successfully")
        
        # Get table name - could be "beach" or "beaches"
        cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_name IN ('beach', 'beaches') AND table_schema = 'public'")
        tables = cursor.fetchall()
        
        if not tables:
            logger.error("Neither 'beach' nor 'beaches' table found")
            return
            
        table_name = tables[0][0]
        logger.info(f"Found table: {table_name}")
        
        # Columns to add
        columns_info = [
            ("is_favorite", "BOOLEAN", "FALSE"),
            ("rating", "FLOAT", "NULL"),
            ("view_count", "INTEGER", "0"),
            ("location", "VARCHAR(100)", "NULL")
        ]
        
        for column_name, column_type, column_default in columns_info:
            try:
                # Check if column exists
                cursor.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}' AND column_name = '{column_name}'")
                if cursor.fetchone():
                    logger.info(f"Column '{column_name}' already exists in the {table_name} table")
                    continue
                
                # Add the column
                logger.info(f"Adding column '{column_name}' to {table_name} table")
                cursor.execute(f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_type} DEFAULT {column_default}")
                logger.info(f"Added column '{column_name}' successfully")
            except Exception as e:
                conn.rollback()
                logger.error(f"Error adding column '{column_name}': {e}")
                raise
        
        # Update location column with data from city and state for existing records
        try:
            logger.info("Updating location field for existing records")
            cursor.execute(f"UPDATE {table_name} SET location = city || ', ' || state WHERE location IS NULL")
            logger.info("Updated location field successfully")
        except Exception as e:
            conn.rollback()
            logger.error(f"Error updating location field: {e}")
            raise
        
        # Commit all changes
        conn.commit()
        logger.info("All changes committed successfully")
        
    except Exception as e:
        logger.error(f"Migration failed: {e}")
        raise
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    logger.info("Starting migration to add new beach fields")
    run_migration()
    logger.info("Migration finished") 