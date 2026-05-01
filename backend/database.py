# Database configuration and session management for the Internship Tracker backend
# Each user gets their own SQLite database file for data isolation.

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from typing import Generator

Base = declarative_base()

# Cache of engines keyed by username so we don't recreate them per request
_engines: dict = {}


def _get_engine(username: str):
    """Return (and lazily create) the SQLAlchemy engine for a given user."""
    key = username.lower().strip()
    if key not in _engines:
        db_path = f"{key}.db"
        engine = create_engine(
            f"sqlite:///{db_path}",
            connect_args={"check_same_thread": False},
        )
        # Create tables in this user's database on first access
        Base.metadata.create_all(bind=engine)
        _engines[key] = engine
    return _engines[key]


def get_db(username: str) -> Generator:
    """
    Dependency function that provides a database session scoped to `username`.
    Creates the user's database file on first access.
    """
    engine = _get_engine(username)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
