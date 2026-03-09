from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# --- Auth Schemas ---
class UserCreate(BaseModel):
    username: str
    email: str
    department: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    username: str
    department: str  # ← เพิ่มตรงนี้

# --- Analysis Schemas ---
class AnalysisResponse(BaseModel):
    model_used: str
    gram_type: str
    shape: str
    accuracy: float
    timestamp: datetime
    original_image_base64: str  # รูปปกติ base64
    annotated_image_base64: str  # รูป+bounding box base64

# --- Folder Schemas (เพิ่มใหม่) ---
class FolderCreate(BaseModel):
    name: str

class FolderResponse(BaseModel):
    id: int
    name: str
    created_at: datetime
    item_count: int = 0  # จำนวนไอเท็มในโฟลเดอร์ (คำนวณก่อนส่งกลับให้ UI)

    class Config:
        from_attributes = True

# --- History Schemas ---
class HistoryCreate(BaseModel):
    item_name: str
    model_used: str
    gram_type: str
    shape: str
    accuracy: float
    note: Optional[str] = None
    folder_id: Optional[int] = None
    original_image_base64: str  # รูปปกติ base64
    annotated_image_base64: str  # รูป+bounding box base64

class HistoryResponse(HistoryCreate):
    id: int
    timestamp: datetime
    
    class Config:
        from_attributes = True