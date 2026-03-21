from database import Base
from sqlalchemy import Column, Integer, String, Date, Text

class Application(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(100), nullable=False)
    role = Column(String(100), nullable=False)
    application_date = Column(Date, nullable=False)
    deadline_date = Column(Date)
    status = Column(String(100), nullable=False)
    notes = Column(Text)
    