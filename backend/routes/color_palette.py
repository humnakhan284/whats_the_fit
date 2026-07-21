from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis
from schemas import AnalyzeResponse
from services.extra_features_service import analyze_color_palette
from utils.storage import read_and_validate_image, save_image_bytes

router = APIRouter(prefix="/api/color-palette", tags=["Color Palette Analyzer"])


@router.post("/analyze", response_model=AnalyzeResponse)
async def analyze(image: UploadFile = File(...), db: Session = Depends(get_db)):
    validated = await read_and_validate_image(image)
    if validated is None:
        raise HTTPException(status_code=400, detail="An image is required.")

    try:
        result = analyze_color_palette(validated)
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    image_path = save_image_bytes(*validated, subfolder="color_palette")
    record = Analysis(category="color_palette", primary_image_path=image_path, result=result)
    db.add(record)
    db.commit()
    db.refresh(record)

    return AnalyzeResponse(analysis_id=record.id, category="color_palette", result=result)
