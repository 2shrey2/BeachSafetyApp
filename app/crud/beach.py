from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional, Dict, Any
from geopy.distance import geodesic

from app.models.beach import Beach
from app.schemas.beach import BeachCreate, BeachUpdate
from app.schemas.weather_data import BeachConditions


def get_beach(db: Session, id: int) -> Optional[Beach]:
    """Get beach by ID"""
    beach = db.query(Beach).filter(Beach.id == id).first()
    if beach and not beach.location:
        # Generate location if it doesn't exist
        beach.location = f"{beach.city}, {beach.state}"
    return beach


def get_beaches(
    db: Session, 
    skip: int = 0, 
    limit: int = 100,
    state: Optional[str] = None,
    name: Optional[str] = None,
    is_active: bool = True
) -> List[Beach]:
    """Get beaches with optional filtering"""
    query = db.query(Beach).filter(Beach.is_active == is_active)
    
    if state:
        query = query.filter(Beach.state == state)
    
    if name:
        query = query.filter(Beach.name.ilike(f"%{name}%"))
    
    beaches = query.offset(skip).limit(limit).all()
    
    # Generate location field if missing
    for beach in beaches:
        if not beach.location:
            beach.location = f"{beach.city}, {beach.state}"
    
    return beaches


def create_beach(db: Session, obj_in: BeachCreate) -> Beach:
    """Create a new beach"""
    # Generate location if not provided
    location = obj_in.location
    if not location and obj_in.city and obj_in.state:
        location = f"{obj_in.city}, {obj_in.state}"
    
    beach = Beach(
        name=obj_in.name,
        description=obj_in.description,
        latitude=obj_in.latitude,
        longitude=obj_in.longitude,
        state=obj_in.state,
        city=obj_in.city,
        is_active=obj_in.is_active,
        image_url=obj_in.image_url,
        is_favorite=obj_in.is_favorite,
        rating=obj_in.rating,
        view_count=obj_in.view_count or 0,
        location=location
    )
    db.add(beach)
    db.commit()
    db.refresh(beach)
    return beach


def update_beach(db: Session, db_obj: Beach, obj_in: BeachUpdate) -> Beach:
    """Update an existing beach"""
    # Update attributes
    if obj_in.name is not None:
        db_obj.name = obj_in.name
    if obj_in.description is not None:
        db_obj.description = obj_in.description
    if obj_in.latitude is not None:
        db_obj.latitude = obj_in.latitude
    if obj_in.longitude is not None:
        db_obj.longitude = obj_in.longitude
    if obj_in.state is not None:
        db_obj.state = obj_in.state
    if obj_in.city is not None:
        db_obj.city = obj_in.city
    if obj_in.is_active is not None:
        db_obj.is_active = obj_in.is_active
    if obj_in.image_url is not None:
        db_obj.image_url = obj_in.image_url
    if obj_in.is_favorite is not None:
        db_obj.is_favorite = obj_in.is_favorite
    if obj_in.rating is not None:
        db_obj.rating = obj_in.rating
    if obj_in.view_count is not None:
        db_obj.view_count = obj_in.view_count
    
    # Generate location field if city or state was updated
    if obj_in.location is not None:
        db_obj.location = obj_in.location
    elif (obj_in.city is not None or obj_in.state is not None) and db_obj.city and db_obj.state:
        db_obj.location = f"{db_obj.city}, {db_obj.state}"
        
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj


def increment_view_count(db: Session, beach_id: int) -> Beach:
    """Increment the view count for a beach"""
    beach = get_beach(db, id=beach_id)
    if beach:
        beach.view_count = (beach.view_count or 0) + 1
        db.add(beach)
        db.commit()
        db.refresh(beach)
    return beach


def delete_beach(db: Session, id: int) -> None:
    """Delete a beach (only marks as inactive)"""
    beach = get_beach(db, id=id)
    if beach:
        beach.is_active = False
        db.add(beach)
        db.commit()


def get_nearby_beaches(
    db: Session,
    latitude: float,
    longitude: float,
    radius_km: float = 50.0,
    limit: int = 10
) -> List[Beach]:
    """
    Get beaches near a specific location
    
    Note: This is a simple implementation using Python.
    For production, consider using PostGIS for geospatial queries.
    """
    # Get all active beaches
    beaches = db.query(Beach).filter(Beach.is_active == True).all()
    
    # Calculate distances and filter
    nearby_beaches = []
    for beach in beaches:
        # Calculate distance using geodesic formula
        distance = geodesic(
            (latitude, longitude),
            (beach.latitude, beach.longitude)
        ).kilometers
        
        if distance <= radius_km:
            # Add distance attribute to beach
            beach.distance = distance
            # Generate location if missing
            if not beach.location:
                beach.location = f"{beach.city}, {beach.state}"
            nearby_beaches.append(beach)
    
    # Sort by distance and limit results
    nearby_beaches.sort(key=lambda x: x.distance)
    return nearby_beaches[:limit]


def get_nearby_beaches_with_conditions(
    db: Session,
    latitude: float,
    longitude: float,
    radius_km: float = 50.0,
    limit: int = 10
) -> List[BeachConditions]:
    """
    Get beaches near a specific location with current conditions
    """
    # Import here to avoid circular dependency
    from app.crud.weather import get_current_beach_conditions
    
    # Get nearby beaches
    beaches = get_nearby_beaches(db, latitude, longitude, radius_km, limit)
    
    # Get conditions for each beach
    results = []
    for beach in beaches:
        conditions = get_current_beach_conditions(db, beach_id=beach.id)
        if conditions:
            # Add distance to conditions
            conditions.distance_km = getattr(beach, 'distance', None)
            results.append(conditions)
    
    return results


# Create a CRUD object to expose all operations
beach = {
    "get": get_beach,
    "get_multi": get_beaches, 
    "create": create_beach,
    "update": update_beach,
    "delete": delete_beach,
    "get_nearby": get_nearby_beaches,
    "get_nearby_with_conditions": get_nearby_beaches_with_conditions,
    "increment_view_count": increment_view_count
} 