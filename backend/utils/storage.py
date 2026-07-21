import os
import uuid
from typing import Optional, Tuple

from fastapi import HTTPException, UploadFile

from config import get_settings

settings = get_settings()

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}
_EXT_BY_MIME = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "image/heic": ".heic",
}


async def read_and_validate_image(upload: Optional[UploadFile]) -> Optional[Tuple[bytes, str]]:
    """Read an uploaded image into memory and validate type/size.
    Returns (bytes, mime_type) or None if no file was provided."""
    if upload is None or not upload.filename:
        return None

    if upload.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported image type '{upload.content_type}'. "
            f"Allowed: {', '.join(sorted(ALLOWED_MIME_TYPES))}",
        )

    data = await upload.read()
    if len(data) == 0:
        raise HTTPException(status_code=400, detail="Uploaded image is empty.")
    if len(data) > settings.max_image_bytes:
        raise HTTPException(
            status_code=400,
            detail=f"Image too large. Max size is {settings.MAX_IMAGE_MB}MB.",
        )
    return data, upload.content_type


def save_image_bytes(data: bytes, mime_type: str, subfolder: str = "uploads") -> str:
    """Persist image bytes to disk and return a path relative to STATIC_URL_PREFIX
    (e.g. 'uploads/ab12cd34.jpg'), suitable for building a servable URL."""
    ext = _EXT_BY_MIME.get(mime_type, ".jpg")
    folder = os.path.join(settings.STATIC_DIR, subfolder)
    os.makedirs(folder, exist_ok=True)

    filename = f"{uuid.uuid4().hex}{ext}"
    full_path = os.path.join(folder, filename)
    with open(full_path, "wb") as f:
        f.write(data)

    return f"{subfolder}/{filename}"


def build_static_url(relative_path: Optional[str]) -> Optional[str]:
    if not relative_path:
        return None
    return f"{settings.STATIC_URL_PREFIX}/{relative_path}"
