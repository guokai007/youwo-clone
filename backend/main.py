from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import chat, memory
import os

app = FastAPI(title="游我 API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat.router)
app.include_router(memory.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "youwo-clone"}
