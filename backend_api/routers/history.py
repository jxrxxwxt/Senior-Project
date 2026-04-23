from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session, defer
from typing import List, Optional
from datetime import datetime, timedelta
from database import get_db, History, User, Folder
from schemas.models import (
    HistoryCreate,
    HistoryResponse,
    FolderCreate,
    FolderResponse,
    HistoryListResponse,
)
from routers.auth import get_current_user

router = APIRouter(prefix="/history", tags=["History"])

@router.get("/folders", response_model=List[FolderResponse])
def get_folders(
    search: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(Folder).filter(Folder.user_id == current_user.id)

    if search:
        query = query.filter(Folder.name.ilike(f"%{search}%"))

    folders = query.order_by(Folder.name.asc()).all()

    for f in folders:
        f.item_count = len(f.items)

    return folders

@router.post(
    "/folders", response_model=FolderResponse, status_code=status.HTTP_201_CREATED
)
def create_folder(
    folder: FolderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    
    existing = (
        db.query(Folder)
        .filter(Folder.user_id == current_user.id, Folder.name == folder.name)
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="Folder name already exists")

    new_folder = Folder(name=folder.name, user_id=current_user.id)
    db.add(new_folder)
    db.commit()
    db.refresh(new_folder)
    return new_folder

@router.delete("/folders/{folder_id}")
def delete_folder(
    folder_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    folder = (
        db.query(Folder)
        .filter(Folder.id == folder_id, Folder.user_id == current_user.id)
        .first()
    )

    if not folder:
        raise HTTPException(status_code=404, detail="Folder not found")

    db.delete(folder)
    db.commit()
    return {"message": "Folder deleted successfully"}

@router.get("/", response_model=List[HistoryListResponse])
def get_all_history(
    folder_id: Optional[int] = None,
    gram_type: Optional[str] = None,
    shape: Optional[str] = None,
    date_range: Optional[str] = None,
    search: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(History).filter(History.user_id == current_user.id)

    if folder_id is not None:
        query = query.filter(History.folder_id == folder_id)

    if gram_type and gram_type != "All Types":
        query = query.filter(History.gram_type == gram_type)

    if shape and shape != "All Shapes":
        query = query.filter(History.shape == shape)

    if date_range and date_range != "All Time":
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

    if search:
        search_term = f"%{search}%"
        query = query.outerjoin(Folder).filter(
            (History.item_name.ilike(search_term))
            | (History.note.ilike(search_term))
            | (Folder.name.ilike(search_term))
        )

    query = query.options(
        defer(History.original_image_base64), defer(History.annotated_image_base64)
    )

    return query.order_by(History.timestamp.desc()).all()


@router.get("/stats/summary")
def get_dashboard_stats(
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    stats = (
        db.query(
            func.count(History.id).label("total"),
            func.avg(History.accuracy).label("avg_acc"),
        )
        .filter(History.user_id == current_user.id)
        .first()
    )

    today = datetime.now().date()
    today_count = (
        db.query(func.count(History.id))
        .filter(
            History.user_id == current_user.id, 
            func.date(History.timestamp) == today
        )
        .scalar() or 0
    )

    user_department = current_user.department
    department_count = (
        db.query(func.count(History.id))
        .join(User) 
        .filter(User.department == user_department)
        .scalar() or 0
    )

    return {
        "total": stats.total or 0,
        "avg_accuracy": round(stats.avg_acc or 0.0, 1),
        "today_count": today_count,
        "department_count": department_count,
    }

@router.get("/{item_id}", response_model=HistoryResponse)
def get_history_detail(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    item = (
        db.query(History)
        .filter(History.id == item_id, History.user_id == current_user.id)
        .first()
    )
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@router.post("/", response_model=HistoryResponse)
def create_history_item(
    item: HistoryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    db_history = History(**item.dict(), user_id=current_user.id)
    db.add(db_history)
    db.commit()
    db.refresh(db_history)
    return db_history

@router.delete("/{item_id}")
def delete_history_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    item = (
        db.query(History)
        .filter(History.id == item_id, History.user_id == current_user.id)
        .first()
    )
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    db.delete(item)
    db.commit()
    return {"message": "Item deleted"}

@router.delete("/batch/delete")
def delete_multiple_items(
    item_ids: List[int] = Query(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    db.query(History).filter(
        History.id.in_(item_ids), History.user_id == current_user.id
    ).delete(synchronize_session=False)

    db.commit()
    return {"message": "Items deleted"}