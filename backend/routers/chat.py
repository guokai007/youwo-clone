from fastapi import APIRouter
from pydantic import BaseModel
from services.llm import chat_with_model, generate_memory_note

router = APIRouter(prefix="/api/chat", tags=["chat"])


class ChatRequest(BaseModel):
    message: str
    history: list[dict] = []
    memory_context: str | None = None


@router.post("/")
def chat(req: ChatRequest):
    reply = chat_with_model(
        message=req.message,
        history=req.history,
        memory_context=req.memory_context,
    )
    return {"reply": reply}


class MemoryNoteRequest(BaseModel):
    conversation_summary: str
    keywords: list[str] = []

@router.post("/memory-note")
def memory_note(req: MemoryNoteRequest):
    note = generate_memory_note(req.conversation_summary, req.keywords)
    return {"note": note}
