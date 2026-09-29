from fastapi import APIRouter, HTTPException, Query

from schemas.drug import DrugDetailResponse, DrugSearchResponse, MetaResponse
from services import drug_info_service, prediction_service
from services.interaction_service import interaction_service

router = APIRouter(tags=["drugs"])


@router.get("/meta", response_model=MetaResponse)
def meta():
    return {
        "supported_drug_count": drug_info_service.supported_count(),
        "model_loaded": prediction_service.model_is_loaded(),
        "interaction_data_available": interaction_service.data_source_connected(),
    }


@router.get("/drugs/search", response_model=DrugSearchResponse)
def search_drugs(q: str = Query(default=""), limit: int = Query(default=30, ge=1, le=50)):
    return {"results": drug_info_service.search_drugs(q, limit)}


@router.get("/drugs/{k_code}", response_model=DrugDetailResponse)
def get_drug(k_code: str):
    detail = drug_info_service.compose_drug_detail(k_code)
    if detail is None:
        raise HTTPException(status_code=404, detail="등록된 의약품 정보를 찾을 수 없습니다.")
    return detail
