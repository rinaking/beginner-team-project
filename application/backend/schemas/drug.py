from typing import Any

from pydantic import BaseModel, Field


class OfficialDrugProfile(BaseModel):
    efficacy: str | None = None
    dosage: str | None = None
    caution: str | None = None
    before_use: str | None = None
    side_effect: str | None = None
    interaction_note: str | None = None


class DrugBasics(BaseModel):
    etc_otc: str | None = None
    material: str | None = None
    company: str | None = None
    class_no: str | None = None
    chart: str | None = None
    storage_method: str | None = None
    valid_term: str | None = None


class DrugSearchItem(BaseModel):
    k_code: str
    drug: dict[str, Any]


class DrugSearchResponse(BaseModel):
    results: list[DrugSearchItem]


class DrugDetailResponse(BaseModel):
    k_code: str
    drug: dict[str, Any]
    basics: DrugBasics
    official: OfficialDrugProfile


class MetaResponse(BaseModel):
    supported_drug_count: int
    model_loaded: bool
    interaction_data_available: bool = Field(
        description="True only when an official interaction source returns data."
    )
