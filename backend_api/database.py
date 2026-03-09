from sqlalchemy import create_engine, Column, Integer, String, DateTime, Float, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime

# สร้าง Database เป็นไฟล์ SQLite ง่ายๆ (สามารถเปลี่ยนเป็น PostgreSQL ได้ภายหลัง)
SQLALCHEMY_DATABASE_URL = "sqlite:///./detection_app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# --- SQL Models (Tables) ---

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String)
    department = Column(String)
    hashed_password = Column(String)
    
    # Relationships
    folders = relationship("Folder", back_populates="owner", cascade="all, delete-orphan")
    history = relationship("History", back_populates="owner", cascade="all, delete-orphan")

class Folder(Base):
    __tablename__ = "folders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String, index=True)
    created_at = Column(DateTime, default=datetime.now)

    # Relationships
    owner = relationship("User", back_populates="folders")
    items = relationship("History", back_populates="folder", cascade="all, delete-orphan")

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    # ★ แก้ไข: เปลี่ยนจาก folder_name เป็น folder_id เพื่อผูกความสัมพันธ์กับตาราง Folders
    folder_id = Column(Integer, ForeignKey("folders.id"), nullable=True) 
    
    item_name = Column(String)
    timestamp = Column(DateTime, default=datetime.now)
    
    # Analysis Results
    model_used = Column(String) # 'Specimen' or 'Pure Culture'
    gram_type = Column(String)
    shape = Column(String)
    accuracy = Column(Float)
    image_path = Column(String, nullable=True) # เก็บ Path ของรูปใน Server
    note = Column(Text, nullable=True)

    # Relationships
    owner = relationship("User", back_populates="history")
    folder = relationship("Folder", back_populates="items")

# Dependency เพื่อใช้ใน Routers
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()