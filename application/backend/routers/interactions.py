from fastapi import APIRouter, HTTPException

from schemas.interaction import InteractionCheckRequest, InteractionCheckResponse
from services.drug_info_service import get_drug
from services.interaction_service import interaction_service

router = APIRouter(tags=["interactions"])


@router.post("/interactions/check", response_model=InteractionCheckResponse)
def check_interactions(payload: InteractionCheckRequest):
    if get_drug(payload.k_code) is None:
        raise HTTPException(status_code=404, detail="등록된 의약품 정보를 찾을 수 없습니다.")
    return interaction_service.check(payload.k_code, payload.compare_k_codes)
