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

# --- Analysis Schemas ---
class AnalysisResponse(BaseModel):
    model_used: str
    gram_type: str
    shape: str
    accuracy: float
    timestamp: datetime

# --- History Schemas ---
class HistoryCreate(BaseModel):
    item_name: str
    model_used: str
    gram_type: str
    shape: str
    accuracy: float
    note: Optional[str] = None
    folder_name: Optional[str] = "General"

class HistoryResponse(HistoryCreate):
    id: int
    timestamp: datetime
    
    class Config:
        from_attributes = True