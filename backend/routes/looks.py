from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis, SavedLook
from schemas import SaveLookRequest, SavedLookOut, CollectionSummary

router = APIRouter(prefix="/api/looks", tags=["Saved Looks"])


@router.post("", response_model=SavedLookOut)
def save_look(payload: SaveLookRequest, db: Session = Depends(get_db)):
    analysis = (
        db.query(Analysis)
        .filter(Analysis.id == payload.analysis_id)
        .first()
    )

    if not analysis:
        raise HTTPException(
            status_code=404,
            detail="Analysis not found."
        )

    saved = SavedLook(
        analysis_id=payload.analysis_id,
        collection_name=payload.collection_name,
        note=payload.note,
    )

    db.add(saved)
    db.commit()
    db.refresh(saved)

    return saved


@router.get("", response_model=list[SavedLookOut])
def get_saved_looks(db: Session = Depends(get_db)):
    return (
        db.query(SavedLook)
        .order_by(SavedLook.created_at.desc())
        .all()
    )


@router.get("/collections", response_model=list[CollectionSummary])
def collections(db: Session = Depends(get_db)):
    rows = db.query(SavedLook).all()

    data = {}

    for row in rows:
        data[row.collection_name] = data.get(row.collection_name, 0) + 1

    return [
        CollectionSummary(
            collection_name=name,
            count=count,
        )
        for name, count in sorted(data.items())
    ]


@router.delete("/{look_id}", status_code=204)
def delete_saved_look(
    look_id: str,
    db: Session = Depends(get_db),
):
    look = (
        db.query(SavedLook)
        .filter(SavedLook.id == look_id)
        .first()
    )

    if not look:
        raise HTTPException(
            status_code=404,
            detail="Saved look not found."
        )

    db.delete(look)
    db.commit()

    return None