import io

from PIL import Image

from services.prediction_service import INFERENCE_IMAGE_SIZE, load_model, model_is_loaded


def _png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (32, 32), "white").save(buffer, format="PNG")
    return buffer.getvalue()


def test_invalid_image_does_not_require_model(client):
    response = client.post(
        "/predict",
        files={"file": ("note.txt", b"not-an-image", "text/plain")},
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "이미지 파일을 읽을 수 없습니다."


def test_empty_image_is_rejected(client):
    response = client.post(
        "/predict",
        files={"file": ("empty.jpg", b"", "image/jpeg")},
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "이미지 파일이 비어 있습니다."


def test_predict_endpoint_uses_existing_model(client):
    assert INFERENCE_IMAGE_SIZE == 768
    assert model_is_loaded() is False
    not_ready = client.post(
        "/predict",
        files={"file": ("blank.png", _png_bytes(), "image/png")},
    )
    assert not_ready.status_code == 503

    load_model()
    assert model_is_loaded() is True
    response = client.post(
        "/predict",
        files={"file": ("blank.png", _png_bytes(), "image/png")},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["detected"] is False
    assert body["detections"] == []
