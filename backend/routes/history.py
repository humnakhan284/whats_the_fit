from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis
from schemas import AnalysisOut
from utils.storage import build_static_url

router = APIRouter(prefix="/api/history", tags=["Analysis History"])


def _to_out(item: Analysis) -> AnalysisOut:
    return AnalysisOut(
        id=item.id,
        category=item.category,
        occasion=item.occasion,
        aesthetic=item.aesthetic,
        additional_prompt=item.additional_prompt,
        primary_image_url=build_static_url(item.primary_image_path),
        secondary_image_url=build_static_url(item.secondary_image_path),
        result=item.result,
        created_at=item.created_at,
    )


@router.get("/", response_model=list[AnalysisOut])
def get_history(db: Session = Depends(get_db)):
    analyses = db.query(Analysis).order_by(Analysis.created_at.desc()).all()
    return [_to_out(item) for item in analyses]


@router.get("/{analysis_id}", response_model=AnalysisOut)
def get_analysis(analysis_id: str, db: Session = Depends(get_db)):
    analysis = db.query(Analysis).filter(Analysis.id == analysis_id).first()

    if not analysis:
        raise HTTPException(status_code=404, detail="Analysis not found.")

    return _to_out(analysis)


@router.delete("/{analysis_id}")
def delete_analysis(analysis_id: str, db: Session = Depends(get_db)):
    analysis = db.query(Analysis).filter(Analysis.id == analysis_id).first()

    if not analysis:
        raise HTTPException(status_code=404, detail="Analysis not found.")

    db.delete(analysis)
    db.commit()

    return {"status": "deleted", "analysis_id": analysis_id}