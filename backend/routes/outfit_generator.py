from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis
from schemas import AnalyzeResponse, OutfitGeneratorRequest
from services.extra_features_service import generate_complete_look

router = APIRouter(prefix="/api/outfit-generator", tags=["Outfit Generator"])


@router.post("", response_model=AnalyzeResponse)
def generate(payload: OutfitGeneratorRequest, db: Session = Depends(get_db)):
    """Generates a complete look (clothing + accessories + hairstyle +
    makeup + shoes/bag) for an event, style, and color preference."""
    try:
        result = generate_complete_look(
            event=payload.event,
            style=payload.style,
            color_preference=payload.color_preference,
            additional_prompt=payload.additional_prompt,
        )
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    record = Analysis(
        category="outfit_generator",
        occasion=payload.event,
        aesthetic=payload.style,
        additional_prompt=payload.additional_prompt,
        result=result,
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    return AnalyzeResponse(analysis_id=record.id, category="outfit_generator", result=result)
