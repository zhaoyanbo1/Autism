from firebase_functions import https_fn
from firebase_admin import initialize_app
from openai import OpenAI
from typing import Optional
from werkzeug.wrappers import Request as WerkzeugRequest  # 仅用于类型提示
import base64
import os
import json

# 初始化 Firebase Admin（需要访问 Firestore/Storage/Auth 时）
initialize_app()

BASE_PROMPT = (
    "Identify the objects in the uploaded pictures and design an interactive game for children "
    "that uses those objects. The plan should be step-based, with no more than five steps."
)

def _get_client() -> OpenAI:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not configured")
    return OpenAI(api_key=api_key)

@https_fn.on_request()
def health(req: https_fn.Request) -> https_fn.Response:
    # GET /health
    return https_fn.Response(
        response=json.dumps({"status": "ok"}),
        mimetype="application/json",
        status=200,
    )

@https_fn.on_request()
def generate_game(req: https_fn.Request) -> https_fn.Response:
    # POST /api/generate-game
    if req.method != "POST":
        return https_fn.Response("Method Not Allowed", status=405)

    # `req` 是 Flask/Werkzeug Request 兼容的
    # multipart/form-data: image(必填), instruction(可选)
    if not req.files or "image" not in req.files:
        return https_fn.Response(
            response=json.dumps({"detail": "Missing required file field 'image'."}),
            mimetype="application/json",
            status=400,
        )

    uploaded = req.files["image"]
    if not uploaded or not getattr(uploaded, "filename", ""):
        return https_fn.Response(
            response=json.dumps({"detail": "Empty image upload."}),
            mimetype="application/json",
            status=400,
        )

    mime = getattr(uploaded, "mimetype", "") or ""
    if not mime.startswith("image/"):
        return https_fn.Response(
            response=json.dumps({"detail": "Only image uploads are supported."}),
            mimetype="application/json",
            status=400,
        )

    raw = uploaded.read()
    if not raw:
        return https_fn.Response(
            response=json.dumps({"detail": "Empty image upload."}),
            mimetype="application/json",
            status=400,
        )

    instruction: Optional[str] = ""
    if req.form:
        instruction = req.form.get("instruction") or ""

    prompt = BASE_PROMPT + (f"\nPlease also incorporate: {instruction}" if instruction else "")
    data_url = f"data:{mime};base64,{base64.b64encode(raw).decode()}"

    client = _get_client()
    try:
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
    except Exception as e:
        return https_fn.Response(
            response=json.dumps({"detail": f"OpenAI error: {str(e)}"}),
            mimetype="application/json",
            status=502,
        )

    output_text = getattr(resp, "output_text", None)
    if not output_text:
        return https_fn.Response(
            response=json.dumps({"detail": "Empty response from OpenAI."}),
            mimetype="application/json",
            status=502,
        )

    return https_fn.Response(
        response=json.dumps({"result": output_text.strip()}),
        mimetype="application/json",
        status=200,
    )
