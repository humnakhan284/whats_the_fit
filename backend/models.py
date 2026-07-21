import datetime
import uuid

from sqlalchemy import Column, String, Text, DateTime, JSON, Date, UniqueConstraint

from database import Base


def _uuid() -> str:
    return str(uuid.uuid4())


class Analysis(Base):
    """
    A single AI interaction result. Powers Analysis History (feature 8) and
    is what Saved Looks (feature 7) point back to.

    `category` is one of: clothing, accessories, makeup, hairstyle,
    outfit_generator, color_palette, weather_style.
    `result` is the structured JSON returned by Gemini for that category
    (shape differs per category - see README for exact fields).
    """

    __tablename__ = "analyses"

    id = Column(String, primary_key=True, default=_uuid)
    category = Column(String, index=True, nullable=False)

    occasion = Column(String, nullable=True)
    aesthetic = Column(String, nullable=True)
    additional_prompt = Column(Text, nullable=True)

    primary_image_path = Column(String, nullable=True)
    secondary_image_path = Column(String, nullable=True)  # e.g. face photo

    result = Column(JSON, nullable=False)

    created_at = Column(DateTime, default=datetime.datetime.utcnow, index=True)


class ChatMessage(Base):
    """One message in a per-assistant conversation, grouped by
    (assistant, session_id) so each of the 4 chatbots keeps separate history."""

    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, default=_uuid)
    assistant = Column(String, index=True, nullable=False)  # clothing/accessories/makeup/hairstyle
    session_id = Column(String, index=True, nullable=False)
    role = Column(String, nullable=False)  # "user" | "assistant"
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class SavedLook(Base):
    """A favorited AI result, organized into a named collection
    (e.g. 'Wedding ideas', 'Casual outfits')."""

    __tablename__ = "saved_looks"

    id = Column(String, primary_key=True, default=_uuid)
    analysis_id = Column(String, index=True, nullable=False)
    collection_name = Column(String, default="Uncategorized", index=True)
    note = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class WardrobeItem(Base):
    """A single item in the user's Virtual Wardrobe."""

    __tablename__ = "wardrobe_items"

    id = Column(String, primary_key=True, default=_uuid)
    category = Column(String, nullable=False)  # shirts/dresses/pants/shoes/accessories/other
    name = Column(String, nullable=True)
    image_path = Column(String, nullable=True)
    color = Column(String, nullable=True)
    tags = Column(JSON, default=list)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class ContentCache(Base):
    """
    Generic day-scoped cache for generated content that shouldn't be
    regenerated on every request - Daily Style Tips and Fashion Trends.
    One row per (kind, cache_key, generated_date).
    """

    __tablename__ = "content_cache"
    __table_args__ = (UniqueConstraint("kind", "cache_key", "generated_date"),)

    id = Column(String, primary_key=True, default=_uuid)
    kind = Column(String, nullable=False)  # "daily_tip" | "trends"
    cache_key = Column(String, default="global")  # e.g. region, or "global"
    generated_date = Column(Date, nullable=False)
    content = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
