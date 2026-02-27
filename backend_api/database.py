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
    
    # Relationship
    history = relationship("History", back_populates="owner")

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    item_name = Column(String)
    timestamp = Column(DateTime, default=datetime.now)
    
    # Analysis Results
    model_used = Column(String) # 'Specimen' or 'Pure Culture'
    gram_type = Column(String)
    shape = Column(String)
    accuracy = Column(Float)
    image_path = Column(String, nullable=True) # เก็บ Path ของรูปใน Server
    note = Column(Text, nullable=True)
    folder_name = Column(String, default="General") # สำหรับจัดหมวดหมู่ Folder

    owner = relationship("User", back_populates="history")

# Dependency เพื่อใช้ใน Routers
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()