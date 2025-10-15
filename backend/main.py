import base64, os, logging
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, Form, HTTPException, UploadFile, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from openai import OpenAI
load_dotenv(dotenv_path=Path(__file__).with_name(".env"))

app = FastAPI(title="Personalized Practice API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

logger = logging.getLogger("uvicorn.error")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.exception_handler(Exception)
async def all_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled error on %s %s", request.method, request.url)
    return JSONResponse(status_code=500, content={"detail": str(exc)})

BASE_PROMPT = (
    "Identify the objects in the uploaded pictures and design an interactive game for children "
    "that uses those objects. The plan should be step-based, with no more than five steps."
)

def _client() -> OpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(500, "OpenAI API key not configured")
    return OpenAI(api_key=api_key)

@app.post("/api/generate-game")
async def generate_game(
    image: UploadFile = File(...),           # ⚠️字段名必须叫 image
    instruction: Optional[str] = Form(None)  # ⚠️字段名必须叫 instruction
):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(400, "Only image uploads are supported")

    raw = await image.read()
    if not raw:
        raise HTTPException(400, "Empty image upload")
    mime = image.content_type
    data_url = f"data:{mime};base64,{base64.b64encode(raw).decode()}"

    prompt = BASE_PROMPT + (f"\nPlease also incorporate: {instruction}" if instruction else "")

    client = _client()
    resp = client.responses.create(
        model="gpt-4o-mini",
        input=[{
            "role": "user",
            "content": [
                {"type": "input_text", "text": prompt},
                {"type": "input_image", "image_url": data_url},
            ],
        }],
    )
    out = getattr(resp, "output_text", None)
    if not out:
        raise HTTPException(502, "Empty response from OpenAI")
    return {"result": out.strip()}