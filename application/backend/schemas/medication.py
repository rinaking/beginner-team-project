import re
from datetime import date
from typing import Any

from pydantic import BaseModel, field_validator, model_validator


def normalize_time(value: str) -> str:
    match = re.fullmatch(r"(\d{1,2}):(\d{2})", value.strip())
    if not match:
        raise ValueError("복용 시간 형식이 올바르지 않습니다. 예: 08:00")
    hour = int(match.group(1))
    minute = int(match.group(2))
    if hour > 23 or minute > 59:
        raise ValueError("복용 시간 형식이 올바르지 않습니다. 예: 08:00")
    return f"{hour:02d}:{minute:02d}"


class MedicationWrite(BaseModel):
    k_code: str
    start_date: date
    end_date: date | None = None
    times: list[str]
    memo: str | None = None

    @field_validator("k_code")
    @classmethod
    def validate_k_code(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("약 정보가 없습니다.")
        return value

    @field_validator("times")
    @classmethod
    def validate_times(cls, times: list[str]) -> list[str]:
        if not times:
            raise ValueError("복용 시간을 하나 이상 입력해 주세요.")
        normalized = [normalize_time(item) for item in times]
        if len(set(normalized)) != len(normalized):
            raise ValueError("같은 복용 시간이 중복되었습니다.")
        return sorted(normalized)

    @field_validator("memo")
    @classmethod
    def validate_memo(cls, memo: str | None) -> str | None:
        if memo is None:
            return None
        memo = memo.strip()
        if not memo:
            return None
        if len(memo) > 500:
            raise ValueError("메모는 500자 이하로 입력해 주세요.")
        return memo

    @model_validator(mode="after")
    def validate_dates(self):
        if self.end_date is not None and self.end_date < self.start_date:
            raise ValueError("복용 종료일은 시작일보다 빠를 수 없습니다.")
        return self


class MedicationOut(BaseModel):
    id: int
    k_code: str
    name: str
    start_date: date
    end_date: date | None
    memo: str | None
    times: list[str]
    drug: dict[str, Any] | None


class DoseOut(BaseModel):
    medication_id: int
    k_code: str
    name: str
    date: date
    scheduled_time: str
    taken: bool
    taken_at: str | None


class DoseAction(BaseModel):
    medication_id: int
    date: date
    scheduled_time: str

    @field_validator("scheduled_time")
    @classmethod
    def validate_scheduled_time(cls, value: str) -> str:
        return normalize_time(value)


class ScheduleResponse(BaseModel):
    date: date
    items: list[DoseOut]
