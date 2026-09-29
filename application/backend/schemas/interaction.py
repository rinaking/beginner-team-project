from pydantic import BaseModel, Field


class InteractionItem(BaseModel):
    other_k_code: str
    other_name: str
    description: str
    with_current_medication: bool


class InteractionCheckRequest(BaseModel):
    k_code: str
    compare_k_codes: list[str] = Field(default_factory=list)


class InteractionCheckResponse(BaseModel):
    data_available: bool
    message: str | None
    interactions: list[InteractionItem]
