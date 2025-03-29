import json
import argparse
import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.config import settings
from app.models.beach import Beach
from app.db.base import Base

# Create async engine and session
engine = create_async_engine(settings.DATABASE_URL)
async_session = sessionmaker(
    engine, expire_on_commit=False, class_=AsyncSession
)

async def import_beaches(file_path: str) -> None:
    """
    Import beaches from a JSON file
    
    Args:
        file_path: Path to the JSON file
    """
    # Read JSON file
    try:
        with open(file_path, 'r') as f:
            beaches_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading JSON file: {e}")
        return
    
    # Validate data
    if not isinstance(beaches_data, list):
        print("JSON file must contain a list of beaches")
        return
    
    # Open session
    async with async_session() as session:
        async with session.begin():
            # Create beach objects
            beach_objects = []
            for idx, beach_data in enumerate(beaches_data):
                try:
                    # Validate required fields
                    required_fields = ['name', 'latitude', 'longitude', 'state', 'city']
                    for field in required_fields:
                        if field not in beach_data:
                            print(f"Beach #{idx+1} is missing required field: {field}")
                            continue
                    
                    # Create Beach object
                    beach = Beach(
                        name=beach_data['name'],
                        description=beach_data.get('description'),
                        latitude=float(beach_data['latitude']),
                        longitude=float(beach_data['longitude']),
                        state=beach_data['state'],
                        city=beach_data['city'],
                        is_active=beach_data.get('is_active', True),
                        image_url=beach_data.get('image_url')
                    )
                    beach_objects.append(beach)
                    print(f"Prepared beach: {beach.name}")
                except Exception as e:
                    print(f"Error creating beach #{idx+1}: {e}")
            
            # Add all beaches to the session
            if beach_objects:
                session.add_all(beach_objects)
                print(f"Added {len(beach_objects)} beaches to the database")
            else:
                print("No valid beaches found in JSON file")

async def main():
    parser = argparse.ArgumentParser(description='Import beaches from a JSON file')
    parser.add_argument('file', help='Path to the JSON file')
    args = parser.parse_args()
    
    await import_beaches(args.file)

if __name__ == "__main__":
    asyncio.run(main()) 