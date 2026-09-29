from typing import Any

from pydantic import BaseModel


class BoundingBox(BaseModel):
    x1: int
    y1: int
    x2: int
    y2: int


class DetectionOut(BaseModel):
    class_id: int
    confidence: float
    bbox: BoundingBox
    k_code: str | None
    drug: dict[str, Any] | None


class PredictResponse(BaseModel):
    detected: bool
    detections: list[DetectionOut]
