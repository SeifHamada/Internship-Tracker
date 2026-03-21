from pydantic import BaseModel
from datetime import date
from typing import Optional

class ApplicationBase(BaseModel):
    company:str
    role:str
    application_date:date
    deadline_date: Optional[date] = None
    status:str
    notes: Optional[str] = None

class ApplicationCreate(ApplicationBase):
    pass

class ApplicationUpdate(BaseModel):
    company: Optional[str] = None
    role: Optional[str] = None
    application_date: Optional[date] = None
    deadline_date: Optional[date] = None
    status: Optional[str] = None
    notes: Optional[str] = None

class ApplicationResponse(BaseModel):
    id:int
    company:str
    role:str
    application_date:date
    deadline_date: Optional[date] = None
    status:str
    notes: Optional[str] = None

    class Config:
        from_attributes = True