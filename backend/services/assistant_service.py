from typing import List, Optional

from services.gemini_client import (
    chat_send_message,
    generate_json,
)
from services.personas import (
    CATEGORIES,
    build_analysis_prompt,
)

def analyze_with_persona(
    category: str,
    primary_image: Optional[tuple[bytes, str]],
    secondary_image: Optional[tuple[bytes, str]],
    occasion: Optional[str],
    aesthetic: Optional[str],
    additional_prompt: Optional[str],
) -> dict:
    cfg = CATEGORIES[category]
    prompt = build_analysis_prompt(category, occasion, aesthetic, additional_prompt)

    images = []
    if primary_image:
        images.append(primary_image)
    if secondary_image:
        images.append(secondary_image)

    return generate_json(prompt, images=images, schema=cfg["schema"], temperature=0.7)


def chat_with_persona(
    category: str,
    message: str,
    history: List[dict],
    context: Optional[dict] = None,
) -> str:
    cfg = CATEGORIES[category]
    system_prompt = cfg["chat_system_prompt"]
    if context:
        system_prompt += (
            "\n\nHere is the user's most recent analysis from this "
            f"assistant, for reference:\n{context}"
        )
    return chat_send_message(system_prompt, message, history, temperature=0.8)
