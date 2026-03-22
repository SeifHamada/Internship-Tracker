# Database configuration and session management for the Internship Tracker backend
# Uses SQLAlchemy ORM with SQLite database

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# Create SQLite engine with special config for FastAPI (allows multiple threads)
engine = create_engine("sqlite:///applications.db", connect_args={"check_same_thread": False})

# Configure session factory for database connections
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for all database models
Base = declarative_base()

def get_db():
    """
    Dependency function that provides database sessions to FastAPI endpoints.
    Creates a new session for each request and ensures proper cleanup.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

