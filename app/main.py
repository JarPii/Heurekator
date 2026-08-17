from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from app.core.engine import Engine
from app.core.store import JSONFileStore
from app.llm.factory import get_llm_client

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data" / "sessions"
FRONTEND_DIR = BASE_DIR / "frontend"

app = FastAPI(title="Heurekator")

_llm = get_llm_client()
_store = JSONFileStore(DATA_DIR)
_engine = Engine(_llm, _store)


class StartRequest(BaseModel):
    idea: str


class AnswerRequest(BaseModel):
    answer: str


@app.post("/api/sessions")
def start_session(req: StartRequest):
    session, question = _engine.start_session(req.idea)
    return {"session_id": session.id, "question": question, "area_index": session.current_area_index}


@app.post("/api/sessions/{session_id}/answer")
def submit_answer(session_id: str, req: AnswerRequest):
    try:
        session = _store.load(session_id)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Sessiota ei löytynyt.")

    session, question, report = _engine.submit_answer(session, req.answer)
    if report is not None:
        return {"done": True, "report": report.model_dump()}
    return {"done": False, "question": question, "area_index": session.current_area_index}


@app.get("/api/sessions/{session_id}")
def get_session(session_id: str):
    try:
        session = _store.load(session_id)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Sessiota ei löytynyt.")
    return session.model_dump()


app.mount("/", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")
