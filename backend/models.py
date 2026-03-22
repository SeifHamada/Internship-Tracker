# SQLAlchemy database models for the Internship Tracker application

from database import Base
from sqlalchemy import Column, Integer, String, Date, Text

class Application(Base):
    """
    Database model representing an internship application.
    Maps to the 'applications' table in SQLite database.
    """
    __tablename__ = "applications"

    # Primary key - auto-incremented by database
    id = Column(Integer, primary_key=True, index=True)

    # Required fields for the application
    company = Column(String(100), nullable=False)  # Company name (max 100 chars)
    role = Column(String(100), nullable=False)     # Job role/title (max 100 chars)
    application_date = Column(Date, nullable=False) # When application was submitted
    status = Column(String(100), nullable=False)    # Current status (e.g., "Applied", "Interview")

    # Optional fields
    deadline_date = Column(Date)  # Application deadline (can be null)
    notes = Column(Text)          # Additional notes about the application
    