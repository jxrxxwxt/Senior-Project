import shutil
import os
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from ultralytics import YOLO
from schemas.models import AnalysisResponse
from datetime import datetime
import numpy as np
from PIL import Image
import io

router = APIRouter(prefix="/analysis", tags=["Analysis"])

# Mapping Label จาก Model ให้เป็นภาษาคน
# Key: ชื่อ Class ที่เทรนมา (posbasi, negcoc, etc.)
# Value: (Gram Type, Shape)
LABEL_MAP = {
    "poscoc": ("Gram-positive", "Cocci"),
    "posbasi": ("Gram-positive", "Bacilli"),
    "negcoc": ("Gram-negative", "Cocci"),
    "negbasi": ("Gram-negative", "Bacilli"),
}

# Load Models (Global variables)
# ตรวจสอบว่ามีไฟล์อยู่จริงไหม เพื่อป้องกัน Error ตอนรันครั้งแรก
try:
    specimen_model = YOLO("models/specimen_model.pt")
    pure_culture_model = YOLO("models/pure_culture_model.pt")
except Exception as e:
    print(f"Warning: Could not load YOLO models. Please place .pt files in models/ folder. Error: {e}")
    specimen_model = None
    pure_culture_model = None

@router.post("/predict", response_model=AnalysisResponse)
async def analyze_image(
    file: UploadFile = File(...),
    model_type: str = Form(...) # "Specimen" or "Pure Culture"
):
    # 1. เลือกโมเดล
    model = None
    if model_type == "Specimen":
        model = specimen_model
    elif model_type == "Pure Culture":
        model = pure_culture_model
    else:
        raise HTTPException(status_code=400, detail="Invalid model type")

    if model is None:
        raise HTTPException(status_code=500, detail="Model file not found on server")

    # 2. อ่านไฟล์รูปภาพ
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes))

    # 3. ให้โมเดลทำนาย (Predict)
    results = model(image)
    
    if not results or len(results[0].boxes) == 0:
        # กรณีตรวจไม่เจออะไรเลย
        return AnalysisResponse(
            model_used=model_type,
            gram_type="Unknown",
            shape="Unknown",
            accuracy=0.0,
            timestamp=datetime.now()
        )

    # 4. ประมวลผลผลลัพธ์ (หา Class ที่มีความมั่นใจสูงสุด หรือเฉลี่ย)
    # ในที่นี้ขอดึงตัวที่มี Confidence สูงสุดมาเป็นตัวแทนภาพ
    result = results[0]
    boxes = result.boxes
    
    # หา index ของกล่องที่มี conf สูงสุด
    best_box_idx = boxes.conf.argmax()
    cls_id = int(boxes.cls[best_box_idx])
    accuracy = float(boxes.conf[best_box_idx]) * 100 # แปลงเป็น %

    # ดึงชื่อ Class จากโมเดล (เช่น 'posbasi')
    detected_class_name = model.names[cls_id]

    # แปลงเป็นข้อความที่ต้องการ (ตัด arrangement ออก)
    gram_type, shape = LABEL_MAP.get(detected_class_name, ("Unknown", "Unknown"))

    return AnalysisResponse(
        model_used=model_type,
        gram_type=gram_type,
        shape=shape,
        accuracy=round(accuracy, 1),
        timestamp=datetime.now()
    )