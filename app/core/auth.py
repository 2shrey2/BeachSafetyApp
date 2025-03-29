from typing import Optional
from datetime import datetime, timedelta
from passlib.context import CryptContext
from jose import jwt
from sqlalchemy.orm import Session

from app.models.user import User
from app.core.config import settings

# Constants
ALGORITHM = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def create_access_token(subject: int, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create JWT access token
    
    Args:
        subject: Token subject (usually user ID)
        expires_delta: Token expiration time
        
    Returns:
        str: JWT token
    """
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    
    return encoded_jwt


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify password against hash
    
    Args:
        plain_password: Plain text password
        hashed_password: Hashed password
        
    Returns:
        bool: Password match status
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Hash password
    
    Args:
        password: Plain text password
        
    Returns:
        str: Hashed password
    """
    return pwd_context.hash(password)


def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """
    Authenticate user by email and password
    
    Args:
        db: Database session
        email: User email
        password: User password
        
    Returns:
        Optional[User]: Authenticated user or None
    """
    from app.crud import user
    
    db_user = user["get_by_email"](db, email=email)
    if not db_user:
        return None
    if not verify_password(password, db_user.hashed_password):
        return None
    
    return db_user 