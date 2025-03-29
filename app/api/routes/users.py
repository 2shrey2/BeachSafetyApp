from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Any, List

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import User as UserSchema, UserUpdate, UserLocationUpdate
from app.schemas.notification import Notification
from app.crud.user import get_user, update_user, update_user_location
from app.crud.notification import get_user_notifications, mark_notification_as_read

router = APIRouter()


@router.get("/me", response_model=UserSchema)
async def read_users_me(current_user: User = Depends(get_current_user)) -> Any:
    """
    Get current user information
    """
    return current_user


@router.put("/me", response_model=UserSchema)
async def update_user_me(
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Update own user information
    """
    user = update_user(db, db_obj=current_user, obj_in=user_in)
    return user


@router.put("/me/location", response_model=UserSchema)
async def update_current_location(
    location: UserLocationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Update current user location
    """
    user = update_user_location(
        db, 
        user=current_user, 
        latitude=location.latitude, 
        longitude=location.longitude
    )
    return user


@router.get("/me/notifications", response_model=List[Notification])
async def read_user_notifications(
    unread_only: bool = False,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Get user notifications
    """
    notifications = get_user_notifications(
        db, user_id=current_user.id, unread_only=unread_only, skip=skip, limit=limit
    )
    return notifications


@router.post("/me/notifications/{notification_id}/read", response_model=Notification)
async def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """
    Mark notification as read
    """
    notification = mark_notification_as_read(
        db, user_id=current_user.id, notification_id=notification_id
    )
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return notification 