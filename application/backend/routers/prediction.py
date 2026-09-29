import io

from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError

from schemas.prediction import PredictResponse
from services import prediction_service

router = APIRouter(tags=["prediction"])


@router.post("/predict", response_model=PredictResponse)
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="이미지 파일이 비어 있습니다.")

    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except UnidentifiedImageError:
        raise HTTPException(status_code=400, detail="이미지 파일을 읽을 수 없습니다.")

    if not prediction_service.model_is_loaded():
        raise HTTPException(status_code=503, detail="인식 모델을 사용할 수 없습니다.")

    return prediction_service.predict_image(image)
