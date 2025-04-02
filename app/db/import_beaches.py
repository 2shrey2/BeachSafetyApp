"""
Script to import beach data with the new fields structure.
This script will import 15 beaches with appropriate images and details.

To run this script:
python -m app.db.import_beaches
"""

import logging
import psycopg2
import json
from datetime import datetime
from app.core.config import settings
import os

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Beach data to import
BEACHES_DATA = [
    {
        "name": "Dwarka Beach",
        "description": "A sacred beach near the famous Dwarkadhish Temple in Gujarat.",
        "latitude": 22.2394,
        "longitude": 68.9671,
        "state": "Gujarat",
        "city": "Dwarka",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533411/1_tzjawp.jpg",
        "is_favorite": False,
        "rating": 4.5,
        "view_count": 1200,
        "location": "Dwarka, Gujarat"
    },
    {
        "name": "Chorwad Beach",
        "description": "A serene beach in Gujarat, known for its peaceful surroundings.",
        "latitude": 21.0159,
        "longitude": 70.2206,
        "state": "Gujarat",
        "city": "Chorwad",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533364/2_vessfs.jpg",
        "is_favorite": False,
        "rating": 4.2,
        "view_count": 800,
        "location": "Chorwad, Gujarat"
    },
    {
        "name": "Somnath Beach",
        "description": "A scenic beach near the famous Somnath Temple in Gujarat.",
        "latitude": 20.888,
        "longitude": 70.4012,
        "state": "Gujarat",
        "city": "Somnath",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533381/3_w1nomj.jpg",
        "is_favorite": False,
        "rating": 4.7,
        "view_count": 1500,
        "location": "Somnath, Gujarat"
    },
    {
        "name": "Juhu Beach",
        "description": "A famous beach in Mumbai, known for its street food and Bollywood celebrity sightings.",
        "latitude": 19.0968,
        "longitude": 72.8265,
        "state": "Maharashtra",
        "city": "Mumbai",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533361/4_uy7al6.jpg",
        "is_favorite": True,
        "rating": 4.6,
        "view_count": 2500,
        "location": "Mumbai, Maharashtra"
    },
    {
        "name": "Versova Beach",
        "description": "A quieter beach in Mumbai, known for its fishing community and cleanliness drives.",
        "latitude": 19.1378,
        "longitude": 72.7985,
        "state": "Maharashtra",
        "city": "Mumbai",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533363/5_tbpfre.jpg",
        "is_favorite": False,
        "rating": 4.3,
        "view_count": 900,
        "location": "Mumbai, Maharashtra"
    },
    {
        "name": "Baga Beach",
        "description": "A lively beach in Goa, popular for its nightlife and water sports.",
        "latitude": 15.5524,
        "longitude": 73.7516,
        "state": "Goa",
        "city": "Baga",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533364/6_jptivp.jpg",
        "is_favorite": True,
        "rating": 4.8,
        "view_count": 3000,
        "location": "Baga, Goa"
    },
    {
        "name": "Anjuna Beach",
        "description": "A popular beach in Goa, known for its trance parties and flea market.",
        "latitude": 15.5873,
        "longitude": 73.7438,
        "state": "Goa",
        "city": "Anjuna",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533363/7_wp1oic.jpg",
        "is_favorite": False,
        "rating": 4.5,
        "view_count": 2200,
        "location": "Anjuna, Goa"
    },
    {
        "name": "Kovalam Beach",
        "description": "A famous beach in Kerala, known for its lighthouse and surfing opportunities.",
        "latitude": 8.4,
        "longitude": 76.9784,
        "state": "Kerala",
        "city": "Kovalam",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533364/8_fkrs59.jpg",
        "is_favorite": False,
        "rating": 4.7,
        "view_count": 1800,
        "location": "Kovalam, Kerala"
    },
    {
        "name": "Varkala Beach",
        "description": "A beautiful cliffside beach in Kerala, also known as Papanasam Beach.",
        "latitude": 8.7333,
        "longitude": 76.7167,
        "state": "Kerala",
        "city": "Varkala",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533366/9_sn9meo.jpg",
        "is_favorite": False,
        "rating": 4.6,
        "view_count": 1600,
        "location": "Varkala, Kerala"
    },
    {
        "name": "Marina Beach",
        "description": "A beautiful beach in Chennai, one of the longest urban beaches in the world.",
        "latitude": 13.0499,
        "longitude": 80.282,
        "state": "Tamil Nadu",
        "city": "Chennai",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533368/10_be9bjb.jpg",
        "is_favorite": True,
        "rating": 4.4,
        "view_count": 3500,
        "location": "Chennai, Tamil Nadu"
    },
    {
        "name": "Elliot Beach",
        "description": "A calm and serene beach in Chennai, also known as Besant Nagar Beach.",
        "latitude": 12.9987,
        "longitude": 80.2715,
        "state": "Tamil Nadu",
        "city": "Chennai",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533368/11_u9p7qs.jpg",
        "is_favorite": False,
        "rating": 4.3,
        "view_count": 1400,
        "location": "Chennai, Tamil Nadu"
    },
    {
        "name": "Digha Beach",
        "description": "A famous beach in West Bengal, known for its flat hard beaches and gentle waves.",
        "latitude": 21.6278,
        "longitude": 87.509,
        "state": "West Bengal",
        "city": "Digha",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533380/12_ow1ppb.png",
        "is_favorite": False,
        "rating": 4.4,
        "view_count": 2000,
        "location": "Digha, West Bengal"
    },
    {
        "name": "Mandarmani Beach",
        "description": "A long and less crowded beach in West Bengal, known for its scenic beauty.",
        "latitude": 21.7696,
        "longitude": 87.6689,
        "state": "West Bengal",
        "city": "Mandarmani",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533367/13_f2c1zq.webp",
        "is_favorite": False,
        "rating": 4.5,
        "view_count": 1100,
        "location": "Mandarmani, West Bengal"
    },
    {
        "name": "Puri Beach",
        "description": "A sacred beach near the Jagannath Temple in Odisha.",
        "latitude": 19.7983,
        "longitude": 85.8249,
        "state": "Odisha",
        "city": "Puri",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533375/14_tnmnus.jpg",
        "is_favorite": False,
        "rating": 4.6,
        "view_count": 2100,
        "location": "Puri, Odisha"
    },
    {
        "name": "Chandipur Beach",
        "description": "A unique beach in Odisha, known for its disappearing sea phenomenon.",
        "latitude": 21.4716,
        "longitude": 87.017,
        "state": "Odisha",
        "city": "Chandipur",
        "is_active": True,
        "image_url": "https://res.cloudinary.com/duouemoop/image/upload/v1743533376/15_ktp4pa.jpg",
        "is_favorite": False,
        "rating": 4.5,
        "view_count": 1300,
        "location": "Chandipur, Odisha"
    }
]

def run_import():
    """Import beach data into the database"""
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
        
        # Get table name
        cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_name IN ('beach', 'beaches') AND table_schema = 'public'")
        tables = cursor.fetchall()
        
        if not tables:
            logger.error("Neither 'beach' nor 'beaches' table found")
            return
            
        table_name = tables[0][0]
        logger.info(f"Found table: {table_name}")
        
        # Check if the required columns exist
        cursor.execute(f"""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = '{table_name}' 
            AND column_name IN ('is_favorite', 'rating', 'view_count', 'location')
        """)
        existing_columns = [row[0] for row in cursor.fetchall()]
        
        if len(existing_columns) < 4:
            logger.warning(f"Not all required columns exist. Found: {existing_columns}")
            logger.warning("Please run the migration script first.")
            return
        
        # Delete existing data if any
        cursor.execute(f"DELETE FROM {table_name}")
        logger.info(f"Deleted existing data from {table_name}")
        
        # Get the columns in the table
        cursor.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
        all_columns = [row[0] for row in cursor.fetchall()]
        logger.info(f"Table columns: {all_columns}")
        
        # Import beach data
        now = datetime.now()
        for i, beach in enumerate(BEACHES_DATA):
            # Prepare data for insert based on existing columns
            beach_data = {}
            beach_data['name'] = beach['name']
            beach_data['description'] = beach['description']
            beach_data['latitude'] = beach['latitude']
            beach_data['longitude'] = beach['longitude']
            beach_data['state'] = beach['state']
            beach_data['city'] = beach['city']
            beach_data['is_active'] = beach['is_active']
            beach_data['image_url'] = beach['image_url']
            
            # Add new fields if they exist in the table
            if 'is_favorite' in all_columns:
                beach_data['is_favorite'] = beach['is_favorite']
            if 'rating' in all_columns:
                beach_data['rating'] = beach['rating']
            if 'view_count' in all_columns:
                beach_data['view_count'] = beach['view_count']
            if 'location' in all_columns:
                beach_data['location'] = beach['location']
            
            # Add created_at and updated_at if they exist
            if 'created_at' in all_columns:
                beach_data['created_at'] = now
            if 'updated_at' in all_columns:
                beach_data['updated_at'] = now
                
            # Build the SQL INSERT statement
            columns = ', '.join(beach_data.keys())
            placeholders = ', '.join(['%s'] * len(beach_data))
            values = list(beach_data.values())
            
            query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
            
            try:
                cursor.execute(query, values)
                logger.info(f"Inserted beach {i+1}/{len(BEACHES_DATA)}: {beach['name']}")
            except Exception as e:
                conn.rollback()
                logger.error(f"Error inserting beach {beach['name']}: {e}")
                raise
        
        # Commit all changes
        conn.commit()
        logger.info(f"Successfully imported {len(BEACHES_DATA)} beaches")
        
    except Exception as e:
        logger.error(f"Import failed: {e}")
        if 'conn' in locals():
            conn.rollback()
        raise
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    logger.info("Starting beach import")
    run_import()
    logger.info("Beach import finished") 