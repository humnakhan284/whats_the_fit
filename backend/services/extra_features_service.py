from typing import List, Optional

from services.gemini_client import generate_json

COMPLETE_LOOK_SCHEMA = {
    "type": "object",
    "properties": {
        "dress_suggestion": {"type": "string"},
        "jewelry": {"type": "string"},
        "hairstyle": {"type": "string"},
        "makeup_style": {"type": "string"},
        "shoes_or_bag": {"type": "string"},
        "overall_summary": {"type": "string"},
    },
    "required": [
        "dress_suggestion", "jewelry", "hairstyle", "makeup_style",
        "shoes_or_bag", "overall_summary",
    ],
}


def generate_complete_look(
    event: str,
    style: Optional[str],
    color_preference: Optional[str],
    additional_prompt: Optional[str],
) -> dict:
    """Feature 5: Outfit Generator - combines clothing, accessories,
    hairstyle, and makeup into one complete look."""
    lines = [
        "You are the Outfit Generator for 'What's The Fit?', combining "
        "clothing, accessories, hairstyle, and makeup into ONE complete, "
        "coherent look.",
        f"Event: {event}",
        f"Style preference: {style or 'no strong preference - use your best judgment'}",
        f"Color preference: {color_preference or 'no strong preference'}",
    ]
    if additional_prompt:
        lines.append(f"Extra context: {additional_prompt}")
    lines.append(
        "Respond ONLY with a single JSON object matching the required "
        "schema. Make every field specific and mutually coherent (the "
        "jewelry, hairstyle, and makeup should all make sense together "
        "with the dress suggestion)."
    )
    prompt = "\n".join(lines)
    return generate_json(prompt, schema=COMPLETE_LOOK_SCHEMA, temperature=0.8)


COLOR_PALETTE_SCHEMA = {
    "type": "object",
    "properties": {
        "dominant_colors": {"type": "array", "items": {"type": "string"}},
        "matching_colors": {"type": "array", "items": {"type": "string"}},
        "complementary_colors": {"type": "array", "items": {"type": "string"}},
        "explanation": {"type": "string"},
    },
    "required": ["dominant_colors", "matching_colors", "complementary_colors", "explanation"],
}


def analyze_color_palette(image: tuple[bytes, str]) -> dict:
    """Feature 9: Color Palette Analyzer."""
    prompt = (
        "You are the Color Palette Analyzer for 'What's The Fit?'. Look at "
        "the outfit photo and identify: the dominant colors in the outfit, "
        "colors that would match well with it, and complementary colors "
        "(opposite on the color wheel) that could be used as accent "
        "pieces or accessories. Give a short explanation of your "
        "reasoning. Respond ONLY with a single JSON object matching the "
        "required schema."
    )
    return generate_json(prompt, images=[image], schema=COLOR_PALETTE_SCHEMA, temperature=0.6)


WEATHER_STYLE_SCHEMA = {
    "type": "object",
    "properties": {
        "clothing_suggestions": {"type": "array", "items": {"type": "string"}},
        "fabric_suggestions": {"type": "array", "items": {"type": "string"}},
        "layering_ideas": {"type": "array", "items": {"type": "string"}},
        "summary": {"type": "string"},
    },
    "required": ["clothing_suggestions", "fabric_suggestions", "layering_ideas", "summary"],
}


def weather_style_suggestion(
    weather_description: Optional[str],
    temperature_c: Optional[float],
    season: Optional[str],
    preference: Optional[str],
) -> dict:
    """Feature 10: Weather-Based Styling."""
    lines = [
        "You are the Weather-Based Styling assistant for 'What's The "
        "Fit?'. Suggest what to wear given the following conditions:",
        f"Weather: {weather_description or 'not specified'}",
        f"Temperature: {f'{temperature_c}°C' if temperature_c is not None else 'not specified'}",
        f"Season: {season or 'not specified'}",
        f"Style preference: {preference or 'no strong preference'}",
        "Give clothing suggestions, fabric suggestions suited to the "
        "conditions, and layering ideas if relevant. Respond ONLY with a "
        "single JSON object matching the required schema.",
    ]
    prompt = "\n".join(lines)
    return generate_json(prompt, schema=WEATHER_STYLE_SCHEMA, temperature=0.7)


TRENDS_SCHEMA = {
    "type": "object",
    "properties": {
        "trends": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "description": {"type": "string"},
                },
                "required": ["name", "description"],
            },
        }
    },
    "required": ["trends"],
}


def generate_trends(region: Optional[str] = None, season: Optional[str] = None) -> dict:
    """Feature 11: Fashion Trends. NOTE: Gemini has no live web access here,
    so this reflects general/seasonal style knowledge rather than
    real-time runway news - good for inspiration, not breaking fashion
    news. Cached once per day per region (see routers/trends.py)."""
    lines = [
        "You are the Fashion Trends curator for 'What's The Fit?'. List 6 "
        "current style trends/aesthetics relevant right now (e.g. "
        "minimalism, old money aesthetic, streetwear, traditional fashion "
        "fusion), each with a short 1-2 sentence description of what "
        "defines it and how to wear it.",
    ]
    if region:
        lines.append(f"Focus on trends relevant to: {region}.")
    if season:
        lines.append(f"Keep it relevant to this season: {season}.")
    lines.append(
        "Respond ONLY with a single JSON object matching the required schema."
    )
    prompt = "\n".join(lines)
    return generate_json(prompt, schema=TRENDS_SCHEMA, temperature=0.9)


DAILY_TIP_SCHEMA = {
    "type": "object",
    "properties": {"tip": {"type": "string"}},
    "required": ["tip"],
}


def generate_daily_tip() -> dict:
    """Feature 12: Daily Style Tips."""
    prompt = (
        "You are the Daily Style Tips writer for 'What's The Fit?'. Write "
        "ONE short, punchy, practical fashion tip for today (one or two "
        "sentences, e.g. 'Try adding a belt to improve this outfit' or "
        "'Gold accessories complement warm colors'). Respond ONLY with a "
        "single JSON object matching the required schema."
    )
    return generate_json(prompt, schema=DAILY_TIP_SCHEMA, temperature=0.9)


WARDROBE_OUTFIT_SCHEMA = {
    "type": "object",
    "properties": {
        "outfit_items": {
            "type": "array",
            "items": {"type": "string"},
            "description": "The wardrobe item ids used in this outfit",
        },
        "explanation": {"type": "string"},
        "styling_tip": {"type": "string"},
    },
    "required": ["outfit_items", "explanation", "styling_tip"],
}


def suggest_outfit_from_wardrobe(
    items: List[dict],
    occasion: Optional[str],
    style: Optional[str],
) -> dict:
    """Feature 6: Virtual Wardrobe - compose an outfit using ONLY the
    user's existing wardrobe items. `items` is a list of
    {id, category, name, color, tags}."""
    lines = [
        "You are the Virtual Wardrobe stylist for 'What's The Fit?'. Build "
        "ONE outfit using ONLY the items listed below - do not invent or "
        "suggest items that aren't in this list.",
        f"Occasion: {occasion or 'not specified - any everyday occasion'}",
        f"Style preference: {style or 'no strong preference'}",
        "",
        "Wardrobe items (id, category, name, color, tags):",
    ]
    for it in items:
        lines.append(
            f"- id={it['id']} | category={it['category']} | "
            f"name={it.get('name') or 'unnamed'} | color={it.get('color') or 'unknown'} | "
            f"tags={', '.join(it.get('tags') or [])}"
        )
    lines.append(
        "\nReturn the ids of the items you selected (outfit_items), a "
        "short explanation of why they work together, and one styling "
        "tip. Respond ONLY with a single JSON object matching the "
        "required schema."
    )
    prompt = "\n".join(lines)
    return generate_json(prompt, schema=WARDROBE_OUTFIT_SCHEMA, temperature=0.7)

