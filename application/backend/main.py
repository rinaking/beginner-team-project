import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError

from database.database import BASE_DIR, init_db
from routers import drugs, interactions, medications, prediction, schedules
from services.prediction_service import load_model

load_dotenv(BASE_DIR / ".env")
# 식약처 연동 전에 키만 읽어 둡니다. 값은 로그나 응답에 넣지 않습니다.
MFDS_SERVICE_KEY = os.getenv("MFDS_SERVICE_KEY", "").strip()


def _validation_message(exc: RequestValidationError) -> str:
    for error in exc.errors():
        message = str(error.get("msg", ""))
        if message.startswith("Value error, "):
            return message.removeprefix("Value error, ")
    return "입력값을 확인해 주세요."


def _cors_middleware_kwargs() -> dict:
    raw = os.getenv("CORS_ORIGINS", "").strip()
    if raw == "*":
        return {
            "allow_origins": ["*"],
            "allow_credentials": False,
            "allow_methods": ["*"],
            "allow_headers": ["*"],
        }
    origins = (
        [origin.strip() for origin in raw.split(",") if origin.strip()]
        if raw
        else ["http://localhost", "http://127.0.0.1"]
    )
    return {
        "allow_origins": origins,
        "allow_origin_regex": os.getenv(
            "CORS_ORIGIN_REGEX",
            r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
        ),
        "allow_credentials": True,
        "allow_methods": ["*"],
        "allow_headers": ["*"],
    }


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_db()
    if os.getenv("SKIP_MODEL_LOAD") != "1":
        load_model()
    yield


def create_app() -> FastAPI:
    app = FastAPI(title="Pill App", lifespan=lifespan)
    app.add_middleware(CORSMiddleware, **_cors_middleware_kwargs())
    app.include_router(prediction.router)
    app.include_router(drugs.router)
    app.include_router(medications.router)
    app.include_router(schedules.router)
    app.include_router(interactions.router)

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(_request, exc: RequestValidationError):
        return JSONResponse(status_code=422, content={"detail": _validation_message(exc)})

    @app.exception_handler(SQLAlchemyError)
    async def database_exception_handler(_request, _exc: SQLAlchemyError):
        return JSONResponse(
            status_code=500,
            content={"detail": "데이터를 저장하는 중 오류가 발생했습니다."},
        )

    return app


app = create_app()
