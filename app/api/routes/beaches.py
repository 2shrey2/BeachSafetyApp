from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from sqlalchemy.orm import Session
from typing import Any, List, Optional, Dict
from datetime import datetime

from app.api.deps import get_db, get_current_user, get_current_active_admin
from app.models.user import User
from app.schemas.beach import Beach, BeachCreate, BeachUpdate
from app.schemas.weather_data import BeachConditions
from app.crud.beach import get_beach, get_beaches, create_beach, update_beach, delete_beach
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
    db: Session = Depends(get_db)
) -> Any:
    """
    Retrieve beaches with optional filtering
    """
    beaches = get_beaches(
        db, skip=skip, limit=limit, state=state, name=name, is_active=is_active
    )
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
            # Convert to BeachCreate model
            beach_in = BeachCreate(
                name=beach_data.get("name"),
                description=beach_data.get("description"),
                latitude=beach_data.get("latitude"),
                longitude=beach_data.get("longitude"),
                state=beach_data.get("state"),
                city=beach_data.get("city"),
                is_active=beach_data.get("is_active", True),
                image_url=beach_data.get("image_url")
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
    db: Session = Depends(get_db)
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
    return {"status": "success", "message": "Beach removed from favorites"}


@router.get("/favorites", response_model=List[Beach])
async def read_favorite_beaches(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Get user's favorite beaches
    """
    beaches = get_user_favorite_beaches(db, user_id=current_user.id)
    return beaches 