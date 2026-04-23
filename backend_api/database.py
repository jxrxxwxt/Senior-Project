from sqlalchemy import create_engine, Column, Integer, String, DateTime, Float, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime

SQLALCHEMY_DATABASE_URL = "sqlite:///./detection_app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String)
    department = Column(String)
    hashed_password = Column(String)
    
    folders = relationship("Folder", back_populates="owner", cascade="all, delete-orphan")
    history = relationship("History", back_populates="owner", cascade="all, delete-orphan")

class Folder(Base):
    __tablename__ = "folders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String, index=True)
    created_at = Column(DateTime, default=datetime.now)

    owner = relationship("User", back_populates="folders")
    items = relationship("History", back_populates="folder", cascade="all, delete-orphan")

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    folder_id = Column(Integer, ForeignKey("folders.id"), nullable=True) 
    item_name = Column(String)
    timestamp = Column(DateTime, default=datetime.now)
    model_used = Column(String)
    gram_type = Column(String)
    shape = Column(String)
    accuracy = Column(Float)
    original_image_base64 = Column(Text, nullable=True)
    annotated_image_base64 = Column(Text, nullable=True)
    note = Column(Text, nullable=True)

    owner = relationship("User", back_populates="history")
    folder = relationship("Folder", back_populates="items")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()