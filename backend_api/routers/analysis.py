from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from ultralytics import YOLO
from schemas.models import AnalysisResponse
from datetime import datetime
from PIL import Image, ImageDraw, ImageOps
import io
import base64
from typing import List

router = APIRouter(prefix="/analysis", tags=["Analysis"])

LABEL_MAP = {
    "poscoc": ("Gram-positive", "Cocci"),
    "posbasi": ("Gram-positive", "Bacilli"),
    "posbaci": ("Gram-positive", "Bacilli"),
    "negcoc": ("Gram-negative", "Cocci"),
    "negbasi": ("Gram-negative", "Bacilli"),
    "negbaci": ("Gram-negative", "Bacilli")
}

try:
    specimen_model = YOLO("models/specimen_model.pt")
    pure_culture_model = YOLO("models/pure_culture_model.pt")
except Exception as e:
    print(f"Warning: Could not load YOLO models. Please place .pt files in models/ folder. Error: {e}")
    specimen_model = None
    pure_culture_model = None

def _draw_bounding_boxes(image: Image.Image, boxes: List, cls: List, model) -> Image.Image:
    img_copy = image.copy()
    draw = ImageDraw.Draw(img_copy)
    
    box_color = (0, 255, 0)  
    text_color = (255, 255, 255)
    bg_color = (0, 128, 0)
    
    for i, box in enumerate(boxes):
        x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
        x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
        
        draw.rectangle([x1, y1, x2, y2], outline=box_color, width=3)
        
        cls_id = int(cls[i])
        class_name = model.names[cls_id]
        
        label_text = f"{class_name}"
        bbox = draw.textbbox((x1, y1 - 10), label_text)
        draw.rectangle(bbox, fill=bg_color)
        draw.text((x1, y1 - 10), label_text, fill=text_color)
    
    return img_copy

def _image_to_base64(image: Image.Image) -> str:
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    buffer.seek(0)
    return base64.b64encode(buffer.getvalue()).decode()

@router.post("/predict", response_model=AnalysisResponse)
async def analyze_image(
    file: UploadFile = File(...),
    model_type: str = Form(...)
):
    model = None
    if model_type == "Specimen":
        model = specimen_model
    elif model_type == "Pure Culture":
        model = pure_culture_model
    else:
        raise HTTPException(status_code=400, detail="Invalid model type")

    if model is None:
        raise HTTPException(status_code=500, detail="Model file not found on server")

    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes))
    
    image = ImageOps.exif_transpose(image)
    
    original_image = image.copy()

    results = model(image)
    
    if not results or len(results[0].boxes) == 0:
        original_b64 = _image_to_base64(original_image)
        annotated_b64 = original_b64 
        
        return AnalysisResponse(
            model_used=model_type,
            gram_type="Unknown",
            shape="Unknown",
            accuracy=0.0,
            timestamp=datetime.now(),
            original_image_base64=original_b64,
            annotated_image_base64=annotated_b64
        )

    result = results[0]
    boxes = result.boxes
    
    best_box_idx = boxes.conf.argmax()
    cls_id = int(boxes.cls[best_box_idx])
    accuracy = float(boxes.conf[best_box_idx]) * 100

    detected_class_name = model.names[cls_id]
    gram_type, shape = LABEL_MAP.get(detected_class_name, (f"Unknown ({detected_class_name})", "Unknown"))

    annotated_image = _draw_bounding_boxes(original_image, boxes, boxes.cls, model)
    
    original_b64 = _image_to_base64(original_image)
    annotated_b64 = _image_to_base64(annotated_image)

    return AnalysisResponse(
        model_used=model_type,
        gram_type=gram_type,
        shape=shape,
        accuracy=round(accuracy, 1),
        timestamp=datetime.now(),
        original_image_base64=original_b64,
        annotated_image_base64=annotated_b64
    )