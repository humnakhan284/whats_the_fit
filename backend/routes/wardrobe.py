from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis, WardrobeItem
from schemas import AnalyzeResponse, WardrobeItemOut, WardrobeSuggestRequest
from services.extra_features_service import suggest_outfit_from_wardrobe
from utils.storage import build_static_url, read_and_validate_image, save_image_bytes

router = APIRouter(prefix="/api/wardrobe", tags=["Virtual Wardrobe"])


@router.post("", response_model=WardrobeItemOut)
async def add_item(
    image: UploadFile = File(...),
    category: str = Form(...),
    name: str | None = Form(None),
    color: str | None = Form(None),
    tags: str | None = Form(None),
    db: Session = Depends(get_db),
):
    image_data = await read_and_validate_image(image)

    if image_data is None:
        raise HTTPException(status_code=400, detail="Image is required.")

    image_path = save_image_bytes(*image_data, subfolder="wardrobe")

    item = WardrobeItem(
        category=category,
        name=name,
        color=color,
        image_path=image_path,
        tags=[t.strip() for t in tags.split(",")] if tags else [],
    )

    db.add(item)
    db.commit()
    db.refresh(item)

    return WardrobeItemOut(
        id=item.id,
        category=item.category,
        name=item.name,
        image_url=build_static_url(item.image_path),
        color=item.color,
        tags=item.tags or [],
        created_at=item.created_at,
    )


@router.get("", response_model=list[WardrobeItemOut])
def get_items(db: Session = Depends(get_db)):
    items = db.query(WardrobeItem).order_by(WardrobeItem.created_at.desc()).all()

    return [
        WardrobeItemOut(
            id=i.id,
            category=i.category,
            name=i.name,
            image_url=build_static_url(i.image_path),
            color=i.color,
            tags=i.tags or [],
            created_at=i.created_at,
        )
        for i in items
    ]


@router.post("/suggest", response_model=AnalyzeResponse)
def suggest_outfit(payload: WardrobeSuggestRequest, db: Session = Depends(get_db)):
    """Feature 6: builds an outfit using ONLY items already in the
    user's virtual wardrobe (optionally filtered by category)."""
    query = db.query(WardrobeItem)
    if payload.category_filter:
        query = query.filter(WardrobeItem.category == payload.category_filter)
    items = query.all()

    if not items:
        raise HTTPException(
            status_code=400,
            detail="No wardrobe items found to build a suggestion from.",
        )

    items_payload = [
        {
            "id": i.id,
            "category": i.category,
            "name": i.name,
            "color": i.color,
            "tags": i.tags or [],
        }
        for i in items
    ]

    try:
        result = suggest_outfit_from_wardrobe(
            items=items_payload,
            occasion=payload.occasion,
            style=payload.style,
        )
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    record = Analysis(
        category="wardrobe_suggestion",
        occasion=payload.occasion,
        aesthetic=payload.style,
        result=result,
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    return AnalyzeResponse(analysis_id=record.id, category="wardrobe_suggestion", result=result)


@router.delete("/{item_id}")
def delete_item(item_id: str, db: Session = Depends(get_db)):
    item = db.query(WardrobeItem).filter(WardrobeItem.id == item_id).first()

    if not item:
        raise HTTPException(status_code=404, detail="Wardrobe item not found.")

    db.delete(item)
    db.commit()

    return {"status": "deleted"}