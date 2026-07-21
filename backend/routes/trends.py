import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import ContentCache
from schemas import TrendsResponse
from services.extra_features_service import generate_trends

router = APIRouter(prefix="/api/trends", tags=["Fashion Trends"])


@router.get("", response_model=TrendsResponse)
def get_trends(
    region: Optional[str] = None,
    season: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """
    Returns curated trend inspiration, cached once per day per
    region+season combo so repeated calls don't re-hit the AI. Note this
    reflects the model's general fashion knowledge, not live runway news.
    """
    cache_key = f"{region or 'global'}::{season or 'any'}"
    today = datetime.date.today()

    cached = (
        db.query(ContentCache)
        .filter(
            ContentCache.kind == "trends",
            ContentCache.cache_key == cache_key,
            ContentCache.generated_date == today,
        )
        .first()
    )
    if cached:
        return TrendsResponse(trends=cached.content["trends"], generated_date=today, cache_key=cache_key)

    try:
        result = generate_trends(region=region, season=season)
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    entry = ContentCache(kind="trends", cache_key=cache_key, generated_date=today, content=result)
    db.add(entry)
    db.commit()

    return TrendsResponse(trends=result["trends"], generated_date=today, cache_key=cache_key)
