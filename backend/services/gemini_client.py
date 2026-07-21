import json
import logging
from typing import Any, List, Optional

import google.generativeai as genai

from config import get_settings

logger = logging.getLogger("whats_the_fit.gemini")

settings = get_settings()
_configured = False


def _ensure_configured() -> None:
    global _configured
    if not _configured:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY is not set. Add it to your .env file.")
        genai.configure(api_key=settings.GEMINI_API_KEY)
        _configured = True


def _safe_text(response) -> str:
    """Raises a clean ValueError instead of an opaque SDK exception when
    Gemini has no usable text (e.g. blocked by safety filters)."""
    if not response.candidates:
        reason = getattr(response.prompt_feedback, "block_reason", "unknown")
        raise ValueError(f"The AI declined to respond (reason: {reason}). Please try again.")
    try:
        return response.text
    except (ValueError, AttributeError):
        raise ValueError("The AI returned an empty response. Please try again.")


def generate_json(
    prompt: str,
    images: Optional[List[tuple[bytes, str]]] = None,
    schema: Optional[dict] = None,
    temperature: float = 0.7,
) -> dict:
    """Call Gemini with a text prompt + optional images, forcing structured
    JSON output that matches `schema`. Returns the parsed dict."""
    _ensure_configured()

    model = genai.GenerativeModel(settings.GEMINI_MODEL)
    parts: List[Any] = [prompt]
    for data, mime_type in images or []:
        parts.append({"mime_type": mime_type, "data": data})

    generation_config = {"response_mime_type": "application/json", "temperature": temperature}
    if schema:
        generation_config["response_schema"] = schema

    response = model.generate_content(parts, generation_config=generation_config)
    text = _safe_text(response)

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        logger.error("Gemini returned non-JSON output: %s", text)
        raise ValueError("The AI response could not be parsed. Please try again.")


def chat_send_message(
    system_prompt: str,
    message: str,
    history: List[dict],
    temperature: float = 0.8,
) -> str:
    """
    history: list of {"role": "user"|"model", "parts": [text]}, oldest first,
    NOT including the new `message`.
    """
    _ensure_configured()

    model = genai.GenerativeModel(settings.GEMINI_MODEL, system_instruction=system_prompt)
    chat = model.start_chat(history=history)
    response = chat.send_message(message, generation_config={"temperature": temperature})
    return _safe_text(response)