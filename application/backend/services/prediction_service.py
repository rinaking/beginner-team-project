from PIL import Image

from services import drug_info_service

MODEL_PATH = drug_info_service.MODEL_DIR / "best.pt"
INFERENCE_IMAGE_SIZE = 768

_model = None


def model_is_loaded() -> bool:
    return _model is not None


def load_model():
    global _model
    if _model is None:
        from ultralytics import YOLO

        _model = YOLO(str(MODEL_PATH))
    return _model


def assemble_detection(class_id: int, confidence: float, bbox: dict) -> dict:
    k_code = drug_info_service.k_code_for_class(class_id)
    return {
        "class_id": class_id,
        "confidence": confidence,
        "bbox": bbox,
        "k_code": k_code,
        "drug": drug_info_service.get_drug(k_code),
    }


def predict_image(image: Image.Image) -> dict:
    yolo = load_model()
    results = yolo.predict(source=image, imgsz=INFERENCE_IMAGE_SIZE, verbose=False)
    detections = []
    for result in results:
        if result.boxes is None:
            continue
        for box in result.boxes:
            class_id = int(box.cls.item())
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            detections.append(
                assemble_detection(
                    class_id,
                    round(float(box.conf.item()), 4),
                    {
                        "x1": round(x1),
                        "y1": round(y1),
                        "x2": round(x2),
                        "y2": round(y2),
                    },
                )
            )
    return {"detected": bool(detections), "detections": detections}
