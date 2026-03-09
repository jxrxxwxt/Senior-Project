from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from database import get_db, User
from schemas.models import UserCreate, UserLogin, Token
import bcrypt # เพิ่ม import ตัวนี้ไว้ด้านบนสุด

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Configuration
SECRET_KEY = "YOUR_SECRET_KEY_HERE" # เปลี่ยนเป็น key ยากๆ ใน production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 300

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str):
    password_byte = plain_password.encode('utf-8')
    hashed_byte = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password_byte, hashed_byte)

def get_password_hash(password: str):
    # เปลี่ยน string เป็น bytes ก่อน hash
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(pwd_bytes, salt)
    # คืนค่ากลับไปเป็น string เพื่อเก็บในฐานข้อมูล
    return hashed_password.decode('utf-8')

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- Endpoints ---

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    hashed_pw = get_password_hash(user.password)
    new_user = User(
        username=user.username,
        email=user.email,
        department=user.department,
        hashed_password=hashed_pw
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User created successfully"}

@router.post("/login", response_model=Token)
def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == user_data.username).first()
    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect username or password")
    
    access_token = create_access_token(data={"sub": user.username})
    return {
        "access_token": access_token, 
        "token_type": "bearer", 
        "username": user.username,
        "department": user.department  # ← เพิ่มตรงนี้
    }

# Helper Function สำหรับ Router อื่นๆ เพื่อดึง User ปัจจุบัน
from fastapi.security import OAuth2PasswordBearer
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception
    return user