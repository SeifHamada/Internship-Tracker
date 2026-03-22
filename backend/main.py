# Main FastAPI application for the Internship Tracker backend
# Sets up the web server, database, routing, and CORS middleware

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import router
from database import Base, engine

# Create database tables if they don't exist
Base.metadata.create_all(bind=engine)

# Create the main FastAPI application instance
app = FastAPI()

# Add CORS middleware to allow requests from Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (for development)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Include the API routes from routes.py
app.include_router(router)
