from typing import List, Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from database import get_db
from models import Analysis, ChatMessage
from schemas import (
    AnalyzeResponse,
    ChatMessageOut,
    ChatRequest,
    ChatResponse,
)
from services.assistant_service import (
    analyze_with_persona,
    chat_with_persona,
)
from services.personas import CATEGORIES
from utils.storage import (
    build_static_url,
    read_and_validate_image,
    save_image_bytes,)



def _load_history(db: Session, assistant: str, session_id: str) -> List[dict]:
    rows = (
        db.query(ChatMessage)
        .filter(ChatMessage.assistant == assistant, ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
        .all()
    )
    return [
        {"role": "user" if r.role == "user" else "model", "parts": [r.content]}
        for r in rows
    ]


def build_assistant_router(category: str) -> APIRouter:
    """Builds /api/{category}/analyze and /api/{category}/chat endpoints
    for one of: clothing, accessories, makeup, hairstyle."""
    if category not in CATEGORIES:
        raise ValueError(f"Unknown assistant category: {category}")

    label = CATEGORIES[category]["label"]
    router = APIRouter(prefix=f"/api/{category}", tags=[label])

    @router.post("/analyze", response_model=AnalyzeResponse)
    async def analyze(
        primary_image: Optional[UploadFile] = File(
            None, description="Outfit/clothing/accessories photo"
        ),
        face_image: Optional[UploadFile] = File(
            None, description="Face photo - used by makeup & hairstyle assistants"
        ),
        occasion: Optional[str] = Form(None),
        aesthetic: Optional[str] = Form(None),
        additional_prompt: Optional[str] = Form(None),
        db: Session = Depends(get_db),
    ):
        primary = await read_and_validate_image(primary_image)
        secondary = await read_and_validate_image(face_image)

        if primary is None and secondary is None:
            raise HTTPException(
                status_code=400,
                detail="At least one image (primary_image or face_image) is required.",
            )

        try:
            result = analyze_with_persona(
                category=category,
                primary_image=primary,
                secondary_image=secondary,
                occasion=occasion,
                aesthetic=aesthetic,
                additional_prompt=additional_prompt,
            )
        except RuntimeError as e:
            raise HTTPException(status_code=500, detail=str(e))
        except ValueError as e:
            raise HTTPException(status_code=502, detail=str(e))

        primary_path = save_image_bytes(*primary, subfolder=f"{category}") if primary else None
        secondary_path = save_image_bytes(*secondary, subfolder=f"{category}_face") if secondary else None

        record = Analysis(
            category=category,
            occasion=occasion,
            aesthetic=aesthetic,
            additional_prompt=additional_prompt,
            primary_image_path=primary_path,
            secondary_image_path=secondary_path,
            result=result,
        )
        db.add(record)
        db.commit()
        db.refresh(record)

        return AnalyzeResponse(analysis_id=record.id, category=category, result=result)

    @router.post("/chat", response_model=ChatResponse)
    def chat(payload: ChatRequest, db: Session = Depends(get_db)):
        if not payload.message.strip():
            raise HTTPException(status_code=400, detail="Message cannot be empty.")

        context = None
        if payload.analysis_id:
            record = (
                db.query(Analysis)
                .filter(Analysis.id == payload.analysis_id, Analysis.category == category)
                .first()
            )
            if not record:
                raise HTTPException(status_code=404, detail="analysis_id not found for this assistant.")
            context = record.result

        history = _load_history(db, category, payload.session_id)

        try:
            reply = chat_with_persona(category, payload.message, history, context)
        except RuntimeError as e:
            raise HTTPException(status_code=500, detail=str(e))

        db.add(ChatMessage(assistant=category, session_id=payload.session_id, role="user", content=payload.message))
        db.add(ChatMessage(assistant=category, session_id=payload.session_id, role="assistant", content=reply))
        db.commit()

        return ChatResponse(session_id=payload.session_id, reply=reply)

    @router.get("/chat/{session_id}/history", response_model=List[ChatMessageOut])
    def get_history(session_id: str, db: Session = Depends(get_db)):
        rows = (
            db.query(ChatMessage)
            .filter(ChatMessage.assistant == category, ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.asc())
            .all()
        )
        return rows

    @router.delete("/chat/{session_id}")
    def clear_history(session_id: str, db: Session = Depends(get_db)):
        db.query(ChatMessage).filter(
            ChatMessage.assistant == category, ChatMessage.session_id == session_id
        ).delete()
        db.commit()
        return {"status": "cleared", "assistant": category, "session_id": session_id}

    return router


ASSISTANT_ROUTERS = [build_assistant_router(cat) for cat in CATEGORIES]
