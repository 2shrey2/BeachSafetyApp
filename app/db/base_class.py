from typing import Any
from sqlalchemy.ext.declarative import declarative_base, declared_attr

class CustomBase:
    @declared_attr
    def __tablename__(cls) -> str:
        return cls.__name__.lower()

    # Add common columns or methods here
    id: Any

Base = declarative_base(cls=CustomBase)