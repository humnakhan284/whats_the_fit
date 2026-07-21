import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import ContentCache
from schemas import DailyTipResponse
from services.extra_features_service import generate_daily_tip

router = APIRouter(prefix="/api/daily-tip", tags=["Daily Style Tips"])


@router.get("", response_model=DailyTipResponse)
def get_daily_tip(db: Session = Depends(get_db)):
    """Returns today's style tip, generating and caching it on first
    request of the day so every user gets the same tip."""
    today = datetime.date.today()

    cached = (
        db.query(ContentCache)
        .filter(
            ContentCache.kind == "daily_tip",
            ContentCache.cache_key == "global",
            ContentCache.generated_date == today,
        )
        .first()
    )
    if cached:
        return DailyTipResponse(tip=cached.content["tip"], generated_date=today)

    try:
        result = generate_daily_tip()
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=502, detail=str(e))

    entry = ContentCache(kind="daily_tip", cache_key="global", generated_date=today, content=result)
    db.add(entry)
    db.commit()

    return DailyTipResponse(tip=result["tip"], generated_date=today)
