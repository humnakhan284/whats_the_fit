from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis
from schemas import AnalyzeResponse, WeatherStyleRequest
from services.extra_features_service import weather_style_suggestion

router = APIRouter(prefix="/api/weather-style", tags=["Weather-Based Styling"])


@router.post("", response_model=AnalyzeResponse)
def weather_style(payload: WeatherStyleRequest, db: Session = Depends(get_db)):
    """
    Client-supplied weather input (description/temperature/season). This
    endpoint does not call a live weather API - if you want real weather
    data, fetch it on the frontend (or add a weather API key here) and
    pass the description/temperature through.
    """
    try:
        result = weather_style_suggestion(
            weather_description=payload.weather_description,
            temperature_c=payload.temperature_c,
            season=payload.season,
            preference=payload.preference,
        )
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    record = Analysis(
        category="weather_style",
        aesthetic=payload.preference,
        additional_prompt=payload.weather_description,
        result=result,
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    return AnalyzeResponse(analysis_id=record.id, category="weather_style", result=result)
