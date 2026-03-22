# API routes/endpoints for the Internship Tracker application
# Defines CRUD operations for managing internship applications

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Application
from schemas import ApplicationCreate, ApplicationUpdate, ApplicationResponse


# Create a router for organizing application-related endpoints
router = APIRouter()

@router.get("/applications", response_model=list[ApplicationResponse])
def get_applications(db: Session = Depends(get_db)):
    """
    Retrieve all internship applications from the database.

    Returns:
        List[ApplicationResponse]: A list of all application records
    """
    return db.query(Application).all()

@router.get("/applications/{id}", response_model=ApplicationResponse)
def get_application(id: int, db: Session = Depends(get_db)):
    """
    Retrieve a specific internship application by its ID.

    Args:
        id (int): The unique identifier of the application

    Returns:
        ApplicationResponse: The application data

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")
    return app

@router.post("/applications", response_model=ApplicationResponse, status_code=201)
def create_application(app: ApplicationCreate, db: Session = Depends(get_db)):
    """
    Create a new internship application.

    Args:
        app (ApplicationCreate): The application data to create

    Returns:
        ApplicationResponse: The created application with generated ID
    """
    # Convert Pydantic model to SQLAlchemy model
    db_app = Application(**app.model_dump())
    db.add(db_app)
    db.commit()
    db.refresh(db_app)  # Get the generated ID
    return db_app

@router.put("/applications/{id}", response_model=ApplicationResponse)
def update_application(id: int, app_update: ApplicationUpdate, db: Session = Depends(get_db)):
    """
    Update an existing internship application.

    Args:
        id (int): The unique identifier of the application to update
        app_update (ApplicationUpdate): The fields to update (partial update allowed)

    Returns:
        ApplicationResponse: The updated application data

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")

    # Update only the fields that were provided
    for key, value in app_update.model_dump(exclude_unset=True).items():
        setattr(app, key, value)

    db.commit()
    db.refresh(app)
    return app

@router.delete("/applications/{id}")
def delete_application(id: int, db: Session = Depends(get_db)):
    """
    Delete an internship application by its ID.

    Args:
        id (int): The unique identifier of the application to delete

    Returns:
        dict: Success message confirming deletion

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")

    db.delete(app)
    db.commit()
    return {"message": "Application deleted successfully"}
