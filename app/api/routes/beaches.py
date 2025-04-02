from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from sqlalchemy.orm import Session
from typing import Any, List, Optional, Dict
from datetime import datetime

from app.api.deps import get_db, get_current_user, get_current_active_admin
from app.models.user import User
from app.schemas.beach import Beach, BeachCreate, BeachUpdate
from app.schemas.weather_data import BeachConditions
from app.crud.beach import (
    get_beach, get_beaches, create_beach, update_beach, delete_beach,
    increment_view_count
)
from app.crud.weather import get_current_beach_conditions
from app.crud.user_favorite import add_favorite_beach, remove_favorite_beach, get_user_favorite_beaches

router = APIRouter()


@router.get("", response_model=List[Beach])
async def read_beaches(
    skip: int = 0,
    limit: int = 100,
    state: Optional[str] = None,
    name: Optional[str] = None,
    is_active: bool = True,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user)
) -> Any:
    """
    Retrieve beaches with optional filtering
    """
    beaches = get_beaches(
        db, skip=skip, limit=limit, state=state, name=name, is_active=is_active
    )
    
    # Set is_favorite flag if user is authenticated
    if current_user:
        user_favorites = get_user_favorite_beaches(db, user_id=current_user.id)
        favorite_ids = {beach.id for beach in user_favorites}
        
        for beach in beaches:
            beach.is_favorite = beach.id in favorite_ids
    
    return beaches


@router.post("", response_model=Beach, status_code=status.HTTP_201_CREATED)
async def create_new_beach(
    beach_in: BeachCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin)
) -> Any:
    """
    Create new beach (admin only)
    """
    # Generate location if not provided
    if not beach_in.location and beach_in.city and beach_in.state:
        beach_in.location = f"{beach_in.city}, {beach_in.state}"
        
    beach = create_beach(db, obj_in=beach_in)
    return beach


@router.post("/import", status_code=status.HTTP_201_CREATED)
async def import_beaches(
    beaches_data: List[Dict[str, Any]] = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin)
) -> Any:
    """
    Import multiple beaches at once from JSON (admin only)
    """
    if not beaches_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No beach data provided"
        )
    
    created_beaches = []
    errors = []
    
    for idx, beach_data in enumerate(beaches_data):
        try:
            # Generate location if not provided
            if not beach_data.get("location") and beach_data.get("city") and beach_data.get("state"):
                beach_data["location"] = f"{beach_data['city']}, {beach_data['state']}"
                
            # Convert to BeachCreate model
            beach_in = BeachCreate(
                name=beach_data.get("name"),
                description=beach_data.get("description"),
                latitude=beach_data.get("latitude"),
                longitude=beach_data.get("longitude"),
                state=beach_data.get("state"),
                city=beach_data.get("city"),
                is_active=beach_data.get("is_active", True),
                image_url=beach_data.get("image_url"),
                rating=beach_data.get("rating"),
                view_count=beach_data.get("view_count", 0),
                location=beach_data.get("location"),
                is_favorite=beach_data.get("is_favorite", False)
            )
            
            # Create beach
            beach = create_beach(db, obj_in=beach_in)
            created_beaches.append(beach)
            
        except Exception as e:
            errors.append({
                "index": idx,
                "error": str(e),
                "data": beach_data
            })
    
    return {
        "status": "success",
        "created_count": len(created_beaches),
        "errors": errors
    }


@router.get("/{beach_id}", response_model=Beach)
async def read_beach(
    beach_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user)
) -> Any:
    """
    Get beach by ID
    """
    beach = get_beach(db, id=beach_id)
    if not beach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach not found"
        )
    
    # Increment view count
    beach = increment_view_count(db, beach_id=beach_id)
    
    # Set is_favorite flag if user is authenticated
    if current_user:
        user_favorites = get_user_favorite_beaches(db, user_id=current_user.id)
        favorite_ids = {b.id for b in user_favorites}
        beach.is_favorite = beach.id in favorite_ids
    
    return beach


@router.put("/{beach_id}", response_model=Beach)
async def update_beach_info(
    beach_id: int,
    beach_in: BeachUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin)
) -> Any:
    """
    Update beach (admin only)
    """
    beach = get_beach(db, id=beach_id)
    if not beach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach not found"
        )
    
    # Generate location if not provided but city and state are updated
    if not beach_in.location:
        city = beach_in.city if beach_in.city is not None else beach.city
        state = beach_in.state if beach_in.state is not None else beach.state
        if city and state:
            beach_in.location = f"{city}, {state}"
    
    beach = update_beach(db, db_obj=beach, obj_in=beach_in)
    return beach


@router.delete("/{beach_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_beach_record(
    beach_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin)
) -> None:
    """
    Delete beach (admin only)
    """
    beach = get_beach(db, id=beach_id)
    if not beach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach not found"
        )
    delete_beach(db, id=beach_id)


@router.get("/{beach_id}/conditions", response_model=BeachConditions)
async def read_beach_conditions(
    beach_id: int,
    db: Session = Depends(get_db)
) -> Any:
    """
    Get current beach conditions with safety assessment
    """
    conditions = get_current_beach_conditions(db, beach_id=beach_id)
    if not conditions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach conditions not found"
        )
    return conditions


@router.post("/{beach_id}/favorite", status_code=status.HTTP_201_CREATED)
async def add_to_favorites(
    beach_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Add beach to user's favorites
    """
    beach = get_beach(db, id=beach_id)
    if not beach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beach not found"
        )
    add_favorite_beach(db, user_id=current_user.id, beach_id=beach_id)
    
    # Update the is_favorite flag for this beach for this user's session
    beach.is_favorite = True
    
    return {"status": "success", "message": "Beach added to favorites"}


@router.delete("/{beach_id}/favorite", status_code=status.HTTP_200_OK)
async def remove_from_favorites(
    beach_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Remove beach from user's favorites
    """
    remove_favorite_beach(db, user_id=current_user.id, beach_id=beach_id)
    
    # Update the is_favorite flag for this beach for this user's session
    beach = get_beach(db, id=beach_id)
    if beach:
        beach.is_favorite = False
    
    return {"status": "success", "message": "Beach removed from favorites"}


@router.get("/nearby", response_model=List[Beach])
async def get_nearby_beaches(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    radius: float = Query(50.0, description="Search radius in kilometers"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user)
) -> Any:
    """
    Get beaches near a location
    """
    beaches = app.crud.beach.get_nearby_beaches(
        db, latitude=lat, longitude=lng, radius_km=radius
    )
    
    # Set is_favorite flag if user is authenticated
    if current_user:
        user_favorites = get_user_favorite_beaches(db, user_id=current_user.id)
        favorite_ids = {b.id for b in user_favorites}
        
        for beach in beaches:
            beach.is_favorite = beach.id in favorite_ids
    
    return beaches


@router.get("/user/favorites", response_model=List[Beach])
async def read_favorite_beaches(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Get user's favorite beaches
    """
    beaches = get_user_favorite_beaches(db, user_id=current_user.id)
    
    # Set is_favorite flag to True for all beaches in this list
    for beach in beaches:
        beach.is_favorite = True
        
    return beaches 