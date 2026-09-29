import os

from schemas.interaction import InteractionCheckResponse


class InteractionService:
    """Looks up interaction records from a configured official source.

    No source is connected. This service does not invent interaction text
    and does not describe a combination as safe.
    """

    def __init__(self) -> None:
        self.base_url = os.getenv("INTERACTION_API_BASE_URL", "").strip()
        self.api_key = os.getenv("INTERACTION_API_KEY", "").strip()

    def data_source_connected(self) -> bool:
        return False

    def check(self, k_code: str, compare_k_codes: list[str]) -> InteractionCheckResponse:
        del k_code, compare_k_codes
        if self.base_url and not self.data_source_connected():
            return InteractionCheckResponse(
                data_available=False,
                message="확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다.",
                interactions=[],
            )
        return InteractionCheckResponse(
            data_available=False,
            message="확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다.",
            interactions=[],
        )


interaction_service = InteractionService()
