import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, ConfigDict, Field


# ---------- Shared / Analysis History ----------

class AnalysisOut(BaseModel):
    id: str
    category: str
    occasion: Optional[str] = None
    aesthetic: Optional[str] = None
    additional_prompt: Optional[str] = None
    primary_image_url: Optional[str] = None
    secondary_image_url: Optional[str] = None
    result: Dict[str, Any]
    created_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class AnalyzeResponse(BaseModel):
    analysis_id: str
    category: str
    result: Dict[str, Any]


# ---------- Chat (shared shape across all 4 assistants) ----------

class ChatRequest(BaseModel):
    session_id: str = Field(..., description="Client-generated id, one per conversation")
    message: str
    analysis_id: Optional[str] = Field(
        None, description="Optional: an earlier analysis_id from this same assistant to give the bot context"
    )


class ChatResponse(BaseModel):
    session_id: str
    reply: str


class ChatMessageOut(BaseModel):
    role: str
    content: str
    created_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


# ---------- Outfit Generator ----------

class OutfitGeneratorRequest(BaseModel):
    event: str
    style: Optional[str] = None
    color_preference: Optional[str] = None
    additional_prompt: Optional[str] = None


# ---------- Virtual Wardrobe ----------

class WardrobeItemOut(BaseModel):
    id: str
    category: str
    name: Optional[str] = None
    image_url: Optional[str] = None
    color: Optional[str] = None
    tags: List[str] = []
    created_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class WardrobeSuggestRequest(BaseModel):
    occasion: Optional[str] = None
    style: Optional[str] = None
    category_filter: Optional[str] = Field(
        None, description="Optionally restrict which wardrobe categories to consider"
    )


# ---------- Saved Looks ----------

class SaveLookRequest(BaseModel):
    analysis_id: str
    collection_name: str = "Uncategorized"
    note: Optional[str] = None


class SavedLookOut(BaseModel):
    id: str
    analysis_id: str
    collection_name: str
    note: Optional[str] = None
    created_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class CollectionSummary(BaseModel):
    collection_name: str
    count: int


# ---------- Color Palette ----------

class ColorPaletteResponse(BaseModel):
    analysis_id: str
    result: Dict[str, Any]


# ---------- Weather Styling ----------

class WeatherStyleRequest(BaseModel):
    weather_description: Optional[str] = Field(None, description="e.g. 'light rain', 'sunny and humid'")
    temperature_c: Optional[float] = None
    season: Optional[str] = None
    preference: Optional[str] = None


# ---------- Trends & Daily Tip ----------

class TrendItem(BaseModel):
    name: str
    description: str


class TrendsResponse(BaseModel):
    trends: List[TrendItem]
    generated_date: datetime.date
    cache_key: str


class DailyTipResponse(BaseModel):
    tip: str
    generated_date: datetime.date
