# API routes/endpoints for the Internship Tracker application
# Defines CRUD operations for managing internship applications
# All routes are scoped to a specific user via /users/{username}/...

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Application
from schemas import ApplicationCreate, ApplicationUpdate, ApplicationResponse


router = APIRouter()


def _user_db(username: str):
    """FastAPI dependency that yields a session for the given user's database."""
    yield from get_db(username)


@router.get("/users/{username}/applications", response_model=list[ApplicationResponse])
def get_applications(username: str, db: Session = Depends(_user_db)):
    """
    Retrieve all internship applications for a specific user.

    Returns:
        List[ApplicationResponse]: A list of all application records for this user
    """
    return db.query(Application).all()


@router.get("/users/{username}/applications/{id}", response_model=ApplicationResponse)
def get_application(username: str, id: int, db: Session = Depends(_user_db)):
    """
    Retrieve a specific internship application by its ID.

    Args:
        username (str): The user who owns this application
        id (int): The unique identifier of the application

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")
    return app


@router.post("/users/{username}/applications", response_model=ApplicationResponse, status_code=201)
def create_application(username: str, app: ApplicationCreate, db: Session = Depends(_user_db)):
    """
    Create a new internship application for a specific user.

    Args:
        username (str): The user creating the application
        app (ApplicationCreate): The application data to create

    Returns:
        ApplicationResponse: The created application with generated ID
    """
    db_app = Application(**app.model_dump())
    db.add(db_app)
    db.commit()
    db.refresh(db_app)
    return db_app


@router.put("/users/{username}/applications/{id}", response_model=ApplicationResponse)
def update_application(username: str, id: int, app_update: ApplicationUpdate, db: Session = Depends(_user_db)):
    """
    Update an existing internship application.

    Args:
        username (str): The user who owns this application
        id (int): The unique identifier of the application to update
        app_update (ApplicationUpdate): The fields to update (partial update allowed)

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")

    for key, value in app_update.model_dump(exclude_unset=True).items():
        setattr(app, key, value)

    db.commit()
    db.refresh(app)
    return app


@router.delete("/users/{username}/applications/{id}")
def delete_application(username: str, id: int, db: Session = Depends(_user_db)):
    """
    Delete an internship application by its ID.

    Args:
        username (str): The user who owns this application
        id (int): The unique identifier of the application to delete

    Raises:
        HTTPException: 404 if application with given ID doesn't exist
    """
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")

    db.delete(app)
    db.commit()
    return {"message": "Application deleted successfully"}
