from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
from database import get_db, History, User
from schemas.models import HistoryCreate, HistoryResponse
from routers.auth import get_current_user

router = APIRouter(prefix="/history", tags=["History"])

@router.get("/", response_model=List[HistoryResponse])
def get_all_history(
    folder: Optional[str] = None,
    gram_type: Optional[str] = None,
    shape: Optional[str] = None,
    date_range: Optional[str] = None, # 'Today', 'Week', 'Month', 'All Time'
    search: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(History).filter(History.user_id == current_user.id)
    
    # 1. Filter by Folder
    if folder:
        # ถ้า folder เป็น "General" ให้หาพวกที่เป็น Null หรือ "General"
        if folder == "General":
            query = query.filter((History.folder_name == "General") | (History.folder_name == None))
        else:
            query = query.filter(History.folder_name == folder)

    # 2. Filter by Gram Type
    if gram_type and gram_type != "All Types":
        query = query.filter(History.gram_type == gram_type)

    # 3. Filter by Shape
    if shape and shape != "All Shapes":
        query = query.filter(History.shape == shape)

    # 4. Filter by Date Range
    if date_range:
        now = datetime.now()
        if date_range == "Today":
            start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
            query = query.filter(History.timestamp >= start_date)
        elif date_range == "This Week":
            start_date = now - timedelta(days=7)
            query = query.filter(History.timestamp >= start_date)
        elif date_range == "This Month":
            start_date = now - timedelta(days=30)
            query = query.filter(History.timestamp >= start_date)

    # 5. Search (Simple text search)
    if search:
        search_term = f"%{search}%"
        query = query.filter((History.item_name.ilike(search_term)) | (History.note.ilike(search_term)))

    return query.order_by(History.timestamp.desc()).all()

# ... (Functions อื่นๆ create, delete, stats เหมือนเดิม)
@router.post("/", response_model=HistoryResponse)
def create_history_item(
    item: HistoryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # บันทึก Folder Name ตามที่ส่งมา (ถ้า User สร้างใหม่ ก็จะส่งชื่อใหม่มาตรงนี้เลย)
    db_history = History(
        **item.dict(),
        user_id=current_user.id
    )
    db.add(db_history)
    db.commit()
    db.refresh(db_history)
    return db_history

@router.delete("/{item_id}")
def delete_history_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    item = db.query(History).filter(History.id == item_id, History.user_id == current_user.id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    
    db.delete(item)
    db.commit()
    return {"message": "Item deleted"}

@router.delete("/batch/delete")
def delete_multiple_items(
    item_ids: List[int] = Query(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db.query(History).filter(
        History.id.in_(item_ids), 
        History.user_id == current_user.id
    ).delete(synchronize_session=False)
    
    db.commit()
    return {"message": "Items deleted"}

@router.get("/dashboard-stats")
def get_dashboard_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user_history = db.query(History).filter(History.user_id == current_user.id).all()
    
    total = len(user_history)
    if total == 0:
        return {"total": 0, "avg_accuracy": 0, "today_count": 0}

    total_acc = sum([h.accuracy for h in user_history])
    avg_acc = total_acc / total

    today = datetime.now().date()
    today_count = sum([1 for h in user_history if h.timestamp.date() == today])

    return {
        "total": total,
        "avg_accuracy": round(avg_acc, 1),
        "today_count": today_count
    }