from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from app.models.notification import Notification


def get_notification(db: Session, id: int) -> Optional[Notification]:
    """Get notification by ID"""
    return db.query(Notification).filter(Notification.id == id).first()


def get_user_notifications(
    db: Session,
    user_id: int,
    unread_only: bool = False,
    skip: int = 0,
    limit: int = 100
) -> List[Notification]:
    """Get user notifications"""
    query = db.query(Notification).filter(Notification.user_id == user_id)
    
    if unread_only:
        query = query.filter(Notification.is_read == False)
    
    query = query.order_by(Notification.created_at.desc())
    
    return query.offset(skip).limit(limit).all()


def create_notification(
    db: Session,
    user_id: int,
    title: str,
    content: str,
    beach_id: Optional[int] = None,
    notification_type: str = "safety_alert"
) -> Notification:
    """Create a new notification"""
    notification = Notification(
        user_id=user_id,
        beach_id=beach_id,
        title=title,
        content=content,
        notification_type=notification_type,
        is_read=False
    )
    
    db.add(notification)
    db.commit()
    db.refresh(notification)
    
    return notification


def mark_notification_as_read(db: Session, user_id: int, notification_id: int) -> Optional[Notification]:
    """Mark notification as read"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == user_id
    ).first()
    
    if notification:
        notification.mark_as_read()
        db.add(notification)
        db.commit()
        db.refresh(notification)
    
    return notification


# Create a CRUD object to expose all operations
notification = {
    "get": get_notification,
    "get_user_notifications": get_user_notifications,
    "create": create_notification,
    "mark_as_read": mark_notification_as_read
} 