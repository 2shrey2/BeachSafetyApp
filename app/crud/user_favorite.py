from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from app.models.user_favorite import UserFavorite
from app.models.beach import Beach


def get_user_favorite(db: Session, user_id: int, beach_id: int) -> Optional[UserFavorite]:
    """Get a specific user favorite"""
    return db.query(UserFavorite).filter(
        UserFavorite.user_id == user_id,
        UserFavorite.beach_id == beach_id
    ).first()


def get_user_favorites(db: Session, user_id: int) -> List[UserFavorite]:
    """Get all favorites for a user"""
    return db.query(UserFavorite).filter(
        UserFavorite.user_id == user_id
    ).all()


def get_user_favorite_beaches(db: Session, user_id: int) -> List[Beach]:
    """Get all favorite beaches for a user"""
    return db.query(Beach).join(
        UserFavorite, UserFavorite.beach_id == Beach.id
    ).filter(
        UserFavorite.user_id == user_id,
        Beach.is_active == True
    ).all()


def add_favorite_beach(db: Session, user_id: int, beach_id: int) -> UserFavorite:
    """Add a beach to user's favorites"""
    # Check if already in favorites
    existing = get_user_favorite(db, user_id, beach_id)
    if existing:
        return existing
    
    # Create new favorite
    favorite = UserFavorite(
        user_id=user_id,
        beach_id=beach_id
    )
    
    db.add(favorite)
    db.commit()
    db.refresh(favorite)
    
    return favorite


def remove_favorite_beach(db: Session, user_id: int, beach_id: int) -> None:
    """Remove a beach from user's favorites"""
    favorite = get_user_favorite(db, user_id, beach_id)
    if favorite:
        db.delete(favorite)
        db.commit()


# Create a CRUD object to expose all operations
user_favorite = {
    "get": get_user_favorite,
    "get_multi": get_user_favorites,
    "get_beaches": get_user_favorite_beaches,
    "add": add_favorite_beach,
    "remove": remove_favorite_beach
} 