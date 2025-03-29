import logging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Dict, Any, Optional
from datetime import datetime
from geopy.distance import geodesic

from app.core.config import settings
from app.models.user import User
from app.models.beach import Beach
from app.models.notification import Notification
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)


class NotificationService:
    """Service for managing and sending notifications to users"""
    
    def __init__(self):
        self.email_enabled = settings.EMAIL_ENABLED
        self.email_sender = settings.EMAIL_SENDER
        self.smtp_server = settings.SMTP_SERVER
        self.smtp_port = settings.SMTP_PORT
        self.smtp_username = settings.SMTP_USERNAME
        self.smtp_password = settings.SMTP_PASSWORD
        
    def send_email_notification(self, recipient: str, subject: str, content: str) -> bool:
        """
        Send email notification
        
        Args:
            recipient: Email recipient
            subject: Email subject
            content: Email content (HTML)
            
        Returns:
            bool: Success status
        """
        if not self.email_enabled:
            logger.warning("Email notifications are disabled")
            return False
            
        try:
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = subject
            message["From"] = self.email_sender
            message["To"] = recipient
            
            # Add HTML content
            html_part = MIMEText(content, "html")
            message.attach(html_part)
            
            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_username, self.smtp_password)
                server.sendmail(self.email_sender, recipient, message.as_string())
            
            logger.info(f"Email notification sent to {recipient}")
            return True
        except Exception as e:
            logger.error(f"Error sending email notification: {str(e)}")
            return False
            
    def create_user_notification(
        self,
        db: Session,
        user_id: int,
        title: str,
        content: str,
        beach_id: Optional[int] = None,
        notification_type: str = "safety_alert"
    ) -> Notification:
        """
        Create notification for a user
        
        Args:
            db: Database session
            user_id: User ID
            title: Notification title
            content: Notification content
            beach_id: Beach ID (optional)
            notification_type: Notification type
            
        Returns:
            Notification: Created notification
        """
        try:
            # Create notification object
            notification = Notification(
                user_id=user_id,
                beach_id=beach_id,
                title=title,
                content=content,
                notification_type=notification_type,
                is_read=False
            )
            
            # Add to database
            db.add(notification)
            db.commit()
            db.refresh(notification)
            
            logger.info(f"Notification created for user {user_id}")
            return notification
        except Exception as e:
            db.rollback()
            logger.error(f"Error creating notification: {str(e)}")
            raise
            
    def notify_nearby_users(
        self,
        db: Session,
        beach: Beach,
        warning_message: str,
        condition_level: str,
        radius_km: float = 10.0
    ) -> List[Notification]:
        """
        Notify users near a beach about dangerous conditions
        
        Args:
            db: Database session
            beach: Beach object
            warning_message: Warning message
            condition_level: Condition level (warning, danger)
            radius_km: Notification radius in kilometers
            
        Returns:
            List[Notification]: Created notifications
        """
        notifications = []
        
        # Only notify for warning or danger conditions
        if condition_level not in ["warning", "danger"]:
            return notifications
            
        try:
            # Get all active users with location data
            users = db.query(User).filter(
                User.is_active == True,
                User.current_latitude.isnot(None),
                User.current_longitude.isnot(None)
            ).all()
            
            beach_location = (beach.latitude, beach.longitude)
            
            for user in users:
                # Calculate distance
                user_location = (user.current_latitude, user.current_longitude)
                distance = geodesic(user_location, beach_location).kilometers
                
                # Check if user is within notification radius
                custom_radius = user.notification_radius_km or radius_km
                if distance <= custom_radius:
                    # Create notification
                    title = f"{condition_level.upper()} - {beach.name}"
                    content = f"Beach safety alert for {beach.name}: {warning_message}. Current distance: {distance:.1f} km."
                    
                    notification = self.create_user_notification(
                        db=db,
                        user_id=user.id,
                        title=title,
                        content=content,
                        beach_id=beach.id,
                        notification_type="safety_alert"
                    )
                    
                    notifications.append(notification)
                    
                    # Send email if enabled
                    if user.email_notifications:
                        email_content = f"""
                        <html>
                            <body>
                                <h2>Beach Safety Alert</h2>
                                <p>There is a <strong>{condition_level}</strong> condition at <strong>{beach.name}</strong>.</p>
                                <p>{warning_message}</p>
                                <p>Current distance: {distance:.1f} km.</p>
                                <p>Stay safe and check the Beach Safety App for more information.</p>
                            </body>
                        </html>
                        """
                        self.send_email_notification(
                            recipient=user.email,
                            subject=title,
                            content=email_content
                        )
            
            return notifications
        except Exception as e:
            logger.error(f"Error notifying nearby users: {str(e)}")
            return notifications 