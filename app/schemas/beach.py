from typing import Optional
from pydantic import BaseModel, Field


# Shared properties
class BeachBase(BaseModel):
    name: str
    description: Optional[str] = None
    latitude: float
    longitude: float
    state: str
    city: str
    is_active: bool = True
    image_url: Optional[str] = None
    is_favorite: bool = False
    rating: Optional[float] = None
    view_count: Optional[int] = 0
    location: Optional[str] = None


# Properties to receive on beach creation
class BeachCreate(BeachBase):
    pass


# Properties to receive on beach update
class BeachUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    state: Optional[str] = None
    city: Optional[str] = None
    is_active: Optional[bool] = None
    image_url: Optional[str] = None
    is_favorite: Optional[bool] = None
    rating: Optional[float] = None
    view_count: Optional[int] = None
    location: Optional[str] = None


# Properties shared by models stored in DB
class BeachInDBBase(BeachBase):
    id: int
    
    class Config:
        from_attributes = True


# Properties to return to client
class Beach(BeachInDBBase):
    pass


# Properties properties stored in DB
class BeachInDB(BeachInDBBase):
    pass 