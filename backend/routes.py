from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Application
from schemas import ApplicationCreate, ApplicationUpdate, ApplicationResponse

router = APIRouter()

@router.get("/applications", response_model=list[ApplicationResponse])
def get_applications(db: Session = Depends(get_db)):
    return db.query(Application).all()

@router.get("/applications/{id}", response_model=ApplicationResponse)
def get_application(id: int, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")
    return app

@router.post("/applications", response_model=ApplicationResponse, status_code=201)
def create_application(app: ApplicationCreate, db: Session = Depends(get_db)):
    db_app = Application(**app.model_dump())
    db.add(db_app)
    db.commit()
    db.refresh(db_app)
    return db_app

@router.put("/applications/{id}", response_model=ApplicationResponse)
def update_application(id: int, app_update: ApplicationUpdate, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")
    for key, value in app_update.model_dump(exclude_unset=True).items():
        setattr(app, key, value)
    db.commit()
    db.refresh(app)
    return app

@router.delete("/applications/{id}")
def delete_application(id: int, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")
    db.delete(app)
    db.commit()
    return {"message": "Application deleted successfully"}
