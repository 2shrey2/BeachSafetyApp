from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any, Union
from datetime import datetime

from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.auth import get_password_hash, verify_password


def get_user(db: Session, id: int) -> Optional[User]:
    """Get user by ID"""
    return db.query(User).filter(User.id == id).first()


def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """Get user by email"""
    return db.query(User).filter(User.email == email).first()


def get_users(
    db: Session,
    skip: int = 0,
    limit: int = 100
) -> List[User]:
    """Get all users"""
    return db.query(User).offset(skip).limit(limit).all()


def create_user(db: Session, obj_in: UserCreate) -> User:
    """Create a new user"""
    # Hash the password
    hashed_password = get_password_hash(obj_in.password)
    
    # Create user
    user = User(
        email=obj_in.email,
        hashed_password=hashed_password,
        full_name=obj_in.full_name,
        is_active=obj_in.is_active,
        is_admin=obj_in.is_admin,
        email_notifications=obj_in.email_notifications,
        push_notifications=obj_in.push_notifications,
        notification_radius_km=obj_in.notification_radius_km
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    return user


def update_user(db: Session, db_obj: User, obj_in: UserUpdate) -> User:
    """Update an existing user"""
    # Update attributes
    if obj_in.email is not None:
        db_obj.email = obj_in.email
    if obj_in.full_name is not None:
        db_obj.full_name = obj_in.full_name
    if obj_in.is_active is not None:
        db_obj.is_active = obj_in.is_active
    if obj_in.email_notifications is not None:
        db_obj.email_notifications = obj_in.email_notifications
    if obj_in.push_notifications is not None:
        db_obj.push_notifications = obj_in.push_notifications
    if obj_in.notification_radius_km is not None:
        db_obj.notification_radius_km = obj_in.notification_radius_km
    if obj_in.password:
        db_obj.hashed_password = get_password_hash(obj_in.password)
    
    # Update location if provided
    if hasattr(obj_in, "current_latitude") and obj_in.current_latitude is not None:
        db_obj.current_latitude = obj_in.current_latitude
    if hasattr(obj_in, "current_longitude") and obj_in.current_longitude is not None:
        db_obj.current_longitude = obj_in.current_longitude
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    
    return db_obj


def update_user_location(
    db: Session,
    user: User,
    latitude: float,
    longitude: float
) -> User:
    """Update user's current location"""
    user.current_latitude = latitude
    user.current_longitude = longitude
    user.last_location_update = datetime.utcnow().isoformat()
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    return user


def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """Authenticate user with email and password"""
    user = get_user_by_email(db, email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


# Create a CRUD object to expose all operations
user = {
    "get": get_user,
    "get_by_email": get_user_by_email,
    "get_multi": get_users,
    "create": create_user,
    "update": update_user,
    "update_location": update_user_location,
    "authenticate": authenticate_user
} 