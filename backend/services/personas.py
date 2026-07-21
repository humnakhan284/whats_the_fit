"""
Defines the 4 core AI assistants: clothing, accessories, makeup, hairstyle.
Each has its own chat persona (system prompt) and its own analysis JSON
schema, so `POST /api/{category}/analyze` and `POST /api/{category}/chat`
feel like talking to a different specialist each time.
"""

from typing import Optional


def _schema(properties: dict, required: list[str]) -> dict:
    return {"type": "object", "properties": properties, "required": required}


CLOTHING_SCHEMA = _schema(
    {
        "clothing_type": {"type": "string"},
        "colors": {"type": "array", "items": {"type": "string"}},
        "style": {"type": "string"},
        "pattern": {"type": "string"},
        "occasion_suitability": {"type": "string"},
        "color_combinations": {"type": "array", "items": {"type": "string"}},
        "styling_tips": {"type": "array", "items": {"type": "string"}},
        "outfit_suggestions": {"type": "array", "items": {"type": "string"}},
    },
    [
        "clothing_type", "colors", "style", "pattern", "occasion_suitability",
        "color_combinations", "styling_tips", "outfit_suggestions",
    ],
)

ACCESSORIES_SCHEMA = _schema(
    {
        "metal_tone_recommendation": {"type": "string", "description": "gold, silver, rose gold, or mixed"},
        "earrings": {"type": "string"},
        "necklaces": {"type": "string"},
        "bracelets": {"type": "string"},
        "rings": {"type": "string"},
        "handbag": {"type": "string"},
        "shoes": {"type": "string"},
        "watch": {"type": "string"},
        "overall_reasoning": {"type": "string"},
    },
    [
        "metal_tone_recommendation", "earrings", "necklaces", "bracelets",
        "rings", "handbag", "shoes", "watch", "overall_reasoning",
    ],
)

MAKEUP_SCHEMA = _schema(
    {
        "makeup_style": {"type": "string"},
        "intensity": {"type": "string", "description": "subtle, medium, or full glam"},
        "color_palette": {"type": "array", "items": {"type": "string"}},
        "lipstick_shades": {"type": "array", "items": {"type": "string"}},
        "eye_makeup_idea": {"type": "string"},
        "beginner_tips": {"type": "array", "items": {"type": "string"}},
    },
    [
        "makeup_style", "intensity", "color_palette", "lipstick_shades",
        "eye_makeup_idea", "beginner_tips",
    ],
)

HAIRSTYLE_SCHEMA = _schema(
    {
        "hairstyle_suggestions": {"type": "array", "items": {"type": "string"}},
        "length_idea": {"type": "string"},
        "styling_method": {"type": "string"},
        "hair_accessories": {"type": "array", "items": {"type": "string"}},
        "overall_tips": {"type": "array", "items": {"type": "string"}},
    },
    [
        "hairstyle_suggestions", "length_idea", "styling_method",
        "hair_accessories", "overall_tips",
    ],
)


CATEGORIES = {
    "clothing": {
        "label": "Clothing AI Stylist",
        "emoji": "👗",
        "schema": CLOTHING_SCHEMA,
        "analysis_focus": (
            "Analyze the clothing/outfit in the photo: clothing type, colors, "
            "style, pattern, and how suitable it is for the stated occasion. "
            "Then give color combination ideas, styling tips, and outfit "
            "suggestions."
        ),
        "chat_system_prompt": (
            "You are the Clothing AI Stylist inside 'What's The Fit?'. You "
            "specialize in outfit selection, styling, and clothing "
            "combinations - things like 'what should I wear to a wedding', "
            "'how do I style this black dress', or 'what colors go with "
            "this outfit'. Give specific, practical outfit and color "
            "advice. Keep replies conversational and a few sentences long, "
            "using a short list only when it genuinely helps."
        ),
    },
    "accessories": {
        "label": "Accessories AI Stylist",
        "emoji": "💍",
        "schema": ACCESSORIES_SCHEMA,
        "analysis_focus": (
            "Look at the outfit in the photo and recommend accessories "
            "that complete it: earrings, necklaces, bracelets, rings, "
            "handbag, shoes, and watch. Recommend gold vs silver vs rose "
            "gold tone, and explain briefly why each recommendation works "
            "with the outfit."
        ),
        "chat_system_prompt": (
            "You are the Accessories AI Stylist inside 'What's The Fit?'. "
            "You specialize in jewelry, bags, shoes, and watches - things "
            "like 'which earrings suit this dress', 'gold or silver for "
            "this outfit', or 'what bag matches this look'. Always briefly "
            "explain *why* an accessory works with the outfit, not just "
            "what to wear. Keep replies conversational and concise."
        ),
    },
    "makeup": {
        "label": "Makeup AI Assistant",
        "emoji": "💄",
        "schema": MAKEUP_SCHEMA,
        "analysis_focus": (
            "Based on the face photo (if provided), outfit photo (if "
            "provided), and the occasion, suggest a makeup look: overall "
            "makeup style, intensity (subtle/medium/full glam), a color "
            "palette, lipstick shade options, and an eye makeup idea. Keep "
            "suggestions beginner-friendly and easy to follow."
        ),
        "chat_system_prompt": (
            "You are the Makeup AI Assistant inside 'What's The Fit?'. You "
            "specialize in makeup looks matched to outfits, occasions, and "
            "personal coloring - things like 'suggest makeup for a "
            "wedding', 'what makeup matches this red dress', or 'give me a "
            "soft glam look'. Explain steps simply enough for a makeup "
            "beginner. Keep replies conversational and concise."
        ),
    },
    "hairstyle": {
        "label": "Hairstyle AI Assistant",
        "emoji": "💇",
        "schema": HAIRSTYLE_SCHEMA,
        "analysis_focus": (
            "Based on the face photo (if provided), outfit photo (if "
            "provided), and the occasion, suggest hairstyles that match: "
            "specific hairstyle ideas, a hair length idea, a styling "
            "method, and hair accessories."
        ),
        "chat_system_prompt": (
            "You are the Hairstyle AI Assistant inside 'What's The Fit?'. "
            "You specialize in hairstyles matched to outfits and "
            "occasions - things like 'which hairstyle suits this dress' or "
            "'suggest a hairstyle for a formal event'. Give specific, "
            "achievable styling advice. Keep replies conversational and "
            "concise."
        ),
    },
}


def build_analysis_prompt(
    category: str,
    occasion: Optional[str],
    aesthetic: Optional[str],
    additional_prompt: Optional[str],
) -> str:
    cfg = CATEGORIES[category]
    lines = [
        f"You are the {cfg['label']} for the app 'What's The Fit?'.",
        cfg["analysis_focus"],
        "",
        f"Occasion / event: {occasion or 'Not specified - infer a sensible guess.'}",
        f"Desired aesthetic / style: {aesthetic or 'Not specified - infer from the photo(s).'}",
    ]
    if additional_prompt:
        lines.append(f"Extra context from the user: {additional_prompt}")

    lines += [
        "",
        "Be specific and reference what you actually see in the photo(s) "
        "rather than giving generic advice. Be constructive and honest.",
        "",
        "Respond ONLY with a single JSON object matching the required "
        "schema - no markdown fences, no extra commentary.",
    ]
    return "\n".join(lines)
