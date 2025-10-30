from firebase_functions import https_fn
from firebase_admin import initialize_app
from openai import OpenAI
from typing import Optional
import base64, os, json, re

# 可选：启动时打印版本，便于在日志中确认依赖版本
try:
    import openai as openai_pkg, httpx, sys
    print(f"[boot] python={sys.version} openai={getattr(openai_pkg,'__version__','?')} httpx={httpx.__version__}", flush=True)
except Exception:
    pass

initialize_app()

BASE_PROMPT = (
    "Identify the objects in the uploaded pictures and design an interactive game for children "
    "that uses those objects. The plan should be step-based, with no more than five steps."
)

def _get_client() -> OpenAI:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        # 500 但给出明确原因
        raise RuntimeError("OPENAI_API_KEY is not configured")
    return OpenAI(api_key=api_key)

def _is_data_url(s: str) -> bool:
    return bool(re.match(r"^data:image\/[a-zA-Z0-9.+-]+;base64,", s or ""))

def _mk_data_url_from_raw(raw: bytes, mime: str) -> str:
    return f"data:{mime};base64,{base64.b64encode(raw).decode()}"
def _mk_prompt_for_image(plan_text: str) -> str:
    # 画面重点在于将步骤转换成简单、易懂的卡通风格图示
    condensed = plan_text.strip()
    if len(condensed) > 800:
        condensed = condensed[:800] + "…"
    return (
        "Create a simple, step-by-step instructional illustration for young children. "
        "Use a cheerful cartoon style, bold outlines, and minimal text labels. "
        "Highlight the key actions from this activity plan:\n"
        f"{condensed}\n"
        "The illustration should feel friendly and focus on the numbered steps."
    )


def _create_instruction_image(client: OpenAI, plan_text: str) -> Optional[str]:
    try:
        prompt = _mk_prompt_for_image(plan_text)
        result = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            size="auto",
            quality="auto",
        )
        if result and result.data:
            b64 = getattr(result.data[0], "b64_json", None)
            if b64:
                return f"data:image/png;base64,{b64}"
            print("[image] response missing b64_json payload", flush=True)
        else:
            print("[image] empty response payload", flush=True)
    except Exception as exc:
        print(f"[image] generation failed: {exc}", flush=True)
    return None


# ====== 核心：OpenAI 调用（带 Responses 优先 + Chat 回退） ======
def call_openai(client: OpenAI, base_prompt: str, data_url: str) -> Optional[str]:
    # 1) 优先走 Responses API
    try:
        if hasattr(client, "responses"):
            r = client.responses.create(
                model="gpt-4o-mini",
                input=[{
                    "role": "user",
                    "content": [
                        {"type": "text", "text": base_prompt},            # ← 用 "text"
                        {"type": "input_image", "image_url": data_url},   # ← 图片
                    ],
                }],
            )
            txt = getattr(r, "output_text", None)
            if txt:
                return txt
    except Exception as e:
        print(f"[responses] fallback due to: {e}", flush=True)

    # 2) 回退到 Chat Completions（图片字段写法不同）
    r = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": base_prompt},
                {"type": "image_url", "image_url": {"url": data_url}},
            ],
        }],
        temperature=0.7,
    )
    return r.choices[0].message.content if (r and r.choices) else None

# 健康检查
@https_fn.on_request(region="us-central1")
def health(req: https_fn.Request) -> https_fn.Response:
    return https_fn.Response(
        response=json.dumps({"status": "ok"}),
        mimetype="application/json",
        status=200,
    )

# 生成游戏接口
@https_fn.on_request(region="us-central1", secrets=["OPENAI_API_KEY"])
def generate_game(req: https_fn.Request) -> https_fn.Response:
    if req.method != "POST":
        return https_fn.Response("Method Not Allowed", status=405)

    try:
        # -------- 统一提取通用字段（topic/level/items/instruction） --------
        topic: Optional[str] = None
        level: Optional[str] = None
        items: Optional[int] = None
        instruction: Optional[str] = None

        data_url: Optional[str] = None  # 统一转成 data:image/...;base64,...

        # 某些代理会改大小写，这样取更稳
        content_type = (req.headers.get("content-type") or req.headers.get("Content-Type") or "").lower()

        # --- A) multipart/form-data 路径（与旧实现完全兼容） ---
        if "multipart/form-data" in content_type:
            if not req.files or "image" not in req.files:
                return https_fn.Response(
                    response=json.dumps({"detail": "Missing required file field 'image'."}),
                    mimetype="application/json",
                    status=400,
                )
            uploaded = req.files["image"]
            mime = getattr(uploaded, "mimetype", "") or ""
            if not mime.startswith("image/"):
                return https_fn.Response(
                    response=json.dumps({"detail": "Only image uploads are supported."}),
                    mimetype="application/json",
                    status=400,
                )
            raw = uploaded.read() or b""
            if not raw:
                return https_fn.Response(
                    response=json.dumps({"detail": "Empty image upload."}),
                    mimetype="application/json",
                    status=400,
                )
            data_url = _mk_data_url_from_raw(raw, mime)

            if req.form:
                topic = req.form.get("topic")
                level = req.form.get("level")
                instruction = req.form.get("instruction")
                try:
                    items = int(req.form.get("items")) if req.form.get("items") else None
                except ValueError:
                    return https_fn.Response(
                        response=json.dumps({"detail": "items must be an integer"}),
                        mimetype="application/json",
                        status=422,
                    )

        # --- B) application/json 路径（新增：支持 image_url 或 image_b64） ---
        elif "application/json" in content_type:
            try:
                payload = req.get_json(force=True, silent=False) or {}
            except Exception:
                return https_fn.Response(
                    response=json.dumps({"detail": "Invalid JSON body"}),
                    mimetype="application/json",
                    status=400,
                )

            topic = payload.get("topic")
            level = payload.get("level")
            instruction = payload.get("instruction")
            items = payload.get("items")

            # 允许 image_url / image_b64 / 直接 data_url
            image_url = payload.get("image_url")
            image_b64 = payload.get("image_b64")
            maybe_data_url = payload.get("image_data_url")

            if maybe_data_url and _is_data_url(maybe_data_url):
                data_url = maybe_data_url
            elif image_b64:
                # 允许前端只传纯 base64（不含 data:image/... 前缀），默认为 jpg
                data_url = f"data:image/jpeg;base64,{image_b64}"
            elif image_url:
                # 直接把远程 URL 传给 OpenAI（Responses/Chat 都接受远程 URL 或 data URL）
                data_url = image_url

            if items is not None:
                try:
                    items = int(items)
                except Exception:
                    return https_fn.Response(
                        response=json.dumps({"detail": "items must be an integer"}),
                        mimetype="application/json",
                        status=422,
                    )

        else:
            return https_fn.Response(
                response=json.dumps({"detail": "Unsupported Content-Type"}),
                mimetype="application/json",
                status=415,
            )

        # -------- 参数校验：topic/level/items 可选；图片必须存在其一 --------
        if not data_url:
            return https_fn.Response(
                response=json.dumps({"detail": "Provide an image file (multipart 'image') or 'image_url'/'image_b64' in JSON."}),
                mimetype="application/json",
                status=400,
            )

        # 组装提示词
        base_prompt = BASE_PROMPT
        if instruction:
            base_prompt += f"\nPlease also incorporate: {instruction}"

        # -------- 调用 OpenAI（带回退）--------
        client = _get_client()
        try:
            output_text = call_openai(client, base_prompt, data_url)
        except Exception as e:
            return https_fn.Response(
                response=json.dumps({"detail": f"OpenAI error: {str(e)}"}),
                mimetype="application/json",
                status=502,
            )

        if not output_text:
            return https_fn.Response(
                response=json.dumps({"detail": "Empty response from OpenAI."}),
                mimetype="application/json",
                status=502,
            )
        illustration_url = _create_instruction_image(client, output_text)

        return https_fn.Response(
            response=json.dumps(
                {
                    "result": output_text.strip(),
                    "illustration": illustration_url,
                }
            ),
            mimetype="application/json",
            status=200,
        )

    except Exception as e:
        # 兜底 500（带明确信息）
        return https_fn.Response(
            response=json.dumps({"detail": f"Server error: {str(e)}"}),
            mimetype="application/json",
            status=500,
        )
