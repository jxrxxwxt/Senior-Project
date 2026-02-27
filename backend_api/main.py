from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routers import auth, analysis, history

# สร้าง Table ใน Database เมื่อเริ่มทำงาน
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Detection App API",
    description="Backend for Medical Detection Application",
    version="1.0.0"
)

# ตั้งค่า CORS (สำคัญมากเพื่อให้ Flutter ต่อเข้ามาได้)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # ใน Production ควรระบุ IP ของ Mobile หรือ Web
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# เชื่อมต่อ Routers
app.include_router(auth.router)
app.include_router(analysis.router)
app.include_router(history.router)

@app.get("/")
def root():
    return {"message": "Welcome to Detection App API"}

if __name__ == "__main__":
    import uvicorn
    # รันด้วยคำสั่ง: python main.py
    uvicorn.run(app, host="0.0.0.0", port=8000)