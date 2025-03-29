from app.db.session import Base

# Import all models here to ensure they are registered with SQLAlchemy
from app.models.user import User
from app.models.beach import Beach
from app.models.weather_data import WeatherData
from app.models.user_favorite import UserFavorite
from app.models.notification import Notification

# Import all schemas
from app.schemas.user import UserCreate, UserUpdate, User as UserSchema
from app.schemas.beach import BeachCreate, BeachUpdate, Beach as BeachSchema
from app.schemas.weather_data import WeatherDataCreate, WeatherDataUpdate, WeatherData as WeatherDataSchema
from app.schemas.notification import NotificationCreate, NotificationUpdate, Notification as NotificationSchema

# This allows Alembic to detect the models