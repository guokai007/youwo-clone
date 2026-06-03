from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api/memory", tags=["memory"])


class SaveRecordRequest(BaseModel):
    content: str
    tags: list[str] = []
    source: str = "chat"


@router.post("/record")
def save_record(req: SaveRecordRequest):
    import uuid
    from datetime import datetime
    record = {
        "id": str(uuid.uuid4()),
        "content": req.content,
        "tags": req.tags,
        "source": req.source,
        "created_at": datetime.now().isoformat(),
    }
    return {"record": record}


@router.get("/records")
def get_records(limit: int = 50):
    return {"records": []}


@router.get("/memories")
def get_memories():
    return {"memories": []}
