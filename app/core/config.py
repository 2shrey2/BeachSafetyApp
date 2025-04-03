import os
import secrets
from typing import List, Optional, Union, Dict, Any
from pydantic import AnyHttpUrl, PostgresDsn, validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "Beach Safety App"
    VERSION: str = "0.1.0"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = os.getenv("SECRET_KEY", secrets.token_urlsafe(32))
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60 * 24 * 8))  # 8 days
    
    # CORS configuration
    # This list defines the origins that are allowed to make cross-origin requests to our API
    # CORS (Cross-Origin Resource Sharing) is a security feature implemented by browsers
    # that restricts web pages from making requests to a different domain than the one that served the page
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = [
        "http://localhost:3000",  # React/Next.js default port
        "http://localhost:8000",  # FastAPI/Django default port
        "http://localhost:5000",  # Flask default port
        "http://127.0.0.1:3000",  # Same as localhost but using IP
        "http://127.0.0.1:8000",  # Same as localhost but using IP
        "http://127.0.0.1:5000",  # Same as localhost but using IP
        "http://192.0.0.4:8000",   # Android emulator special IP that maps to host machine's localhost
        "http://192.168.1.100:8000",   # Android emulator special IP that maps to host machine's localhost
        "http://192.168.1.100:5000",   # Android emulator special IP that maps to host machine's localhost
    ]

    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    # Database configuration
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "beach_safety_db")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    DATABASE_URL: Optional[PostgresDsn] = None

    @validator("DATABASE_URL", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: Dict[str, Any]) -> Any:
        if isinstance(v, str):
            return v
            
        # Build the connection URL
        return PostgresDsn.build(
            scheme="postgresql",
            username=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_SERVER"),
            port=values.get("POSTGRES_PORT"),
            path=f"{values.get('POSTGRES_DB') or ''}",
        )

    # Redis configuration
    REDIS_HOST: str = os.getenv("REDIS_HOST", "localhost")
    REDIS_PORT: int = int(os.getenv("REDIS_PORT", 6379))
    REDIS_DB: int = int(os.getenv("REDIS_DB", 0))
    REDIS_PASSWORD: Optional[str] = os.getenv("REDIS_PASSWORD")

    # StormGlass API configuration
    STORMGLASS_API_KEY: str = os.getenv("STORMGLASS_API_KEY", "")
    STORMGLASS_BASE_URL: str = "https://api.stormglass.io/v2"
    STORMGLASS_CACHE_TTL: int = int(os.getenv("STORMGLASS_CACHE_TTL", 3600))  # 1 hour

    # Notification settings
    EMAIL_ENABLED: bool = os.getenv("EMAIL_ENABLED", "False").lower() == "true"
    EMAIL_SENDER: str = os.getenv("EMAIL_SENDER", "beachsafety@example.com")
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", 587))
    SMTP_USERNAME: str = os.getenv("SMTP_USERNAME", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")

    # Suitability algorithm thresholds
    WAVE_HEIGHT_THRESHOLD_WARNING: float = float(os.getenv("WAVE_HEIGHT_THRESHOLD_WARNING", 1.5))  # meters
    WAVE_HEIGHT_THRESHOLD_DANGER: float = float(os.getenv("WAVE_HEIGHT_THRESHOLD_DANGER", 2.5))  # meters
    WIND_SPEED_THRESHOLD_WARNING: float = float(os.getenv("WIND_SPEED_THRESHOLD_WARNING", 10.0))  # m/s
    WIND_SPEED_THRESHOLD_DANGER: float = float(os.getenv("WIND_SPEED_THRESHOLD_DANGER", 15.0))  # m/s
    CURRENT_SPEED_THRESHOLD_WARNING: float = float(os.getenv("CURRENT_SPEED_THRESHOLD_WARNING", 0.5))  # m/s
    CURRENT_SPEED_THRESHOLD_DANGER: float = float(os.getenv("CURRENT_SPEED_THRESHOLD_DANGER", 1.0))  # m/s

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings() 