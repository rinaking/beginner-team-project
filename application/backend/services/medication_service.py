from datetime import date, datetime
from zoneinfo import ZoneInfo

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from database.models import Medication, MedicationLog, MedicationSchedule
from schemas.medication import DoseAction, MedicationWrite
from services.drug_info_service import get_drug

KST = ZoneInfo("Asia/Seoul")


def today_kst() -> date:
    return datetime.now(KST).date()


def now_kst_iso() -> str:
    return datetime.now(KST).isoformat(timespec="seconds")


def _is_active(medication: Medication, day: date) -> bool:
    if medication.start_date > day:
        return False
    if medication.end_date is not None and medication.end_date < day:
        return False
    return True


def _load_query():
    return select(Medication).options(
        selectinload(Medication.schedules),
        selectinload(Medication.logs),
    )


def _get_or_404(db: Session, medication_id: int) -> Medication:
    medication = db.scalar(_load_query().where(Medication.id == medication_id))
    if medication is None:
        raise HTTPException(status_code=404, detail="등록된 복용약을 찾을 수 없습니다.")
    return medication


def serialize_medication(medication: Medication) -> dict:
    drug = get_drug(medication.k_code)
    name = drug.get("name") if drug else medication.name
    return {
        "id": medication.id,
        "k_code": medication.k_code,
        "name": name,
        "start_date": medication.start_date,
        "end_date": medication.end_date,
        "memo": medication.memo,
        "times": [schedule.time for schedule in medication.schedules],
        "drug": drug,
    }


def _apply_payload(medication: Medication, payload: MedicationWrite) -> None:
    drug = get_drug(payload.k_code)
    if drug is None or not drug.get("name"):
        raise HTTPException(status_code=404, detail="등록된 의약품 정보를 찾을 수 없습니다.")
    medication.k_code = payload.k_code
    medication.name = str(drug["name"])
    medication.start_date = payload.start_date
    medication.end_date = payload.end_date
    medication.memo = payload.memo
    medication.schedules.clear()
    for dose_time in payload.times:
        medication.schedules.append(MedicationSchedule(time=dose_time))


def list_medications(db: Session) -> list[dict]:
    medications = db.scalars(_load_query().order_by(Medication.id.desc())).all()
    return [serialize_medication(medication) for medication in medications]


def create_medication(db: Session, payload: MedicationWrite) -> dict:
    medication = Medication(
        k_code="",
        name="",
        start_date=payload.start_date,
    )
    _apply_payload(medication, payload)
    db.add(medication)
    db.commit()
    return serialize_medication(_get_or_404(db, medication.id))


def get_medication(db: Session, medication_id: int) -> dict:
    return serialize_medication(_get_or_404(db, medication_id))


def update_medication(db: Session, medication_id: int, payload: MedicationWrite) -> dict:
    medication = _get_or_404(db, medication_id)
    _apply_payload(medication, payload)
    db.commit()
    return serialize_medication(_get_or_404(db, medication_id))


def delete_medication(db: Session, medication_id: int) -> None:
    medication = _get_or_404(db, medication_id)
    db.delete(medication)
    db.commit()


def _find_log(medication: Medication, day: date, scheduled_time: str) -> MedicationLog | None:
    for log in medication.logs:
        if log.log_date == day and log.scheduled_time == scheduled_time:
            return log
    return None


def _dose_dict(medication: Medication, day: date, scheduled_time: str) -> dict:
    drug = get_drug(medication.k_code)
    name = drug.get("name") if drug else medication.name
    log = _find_log(medication, day, scheduled_time)
    return {
        "medication_id": medication.id,
        "k_code": medication.k_code,
        "name": name,
        "date": day,
        "scheduled_time": scheduled_time,
        "taken": bool(log and log.taken),
        "taken_at": log.taken_at if log and log.taken else None,
    }


def doses_for_date(db: Session, day: date) -> list[dict]:
    medications = db.scalars(_load_query()).all()
    items: list[dict] = []
    for medication in medications:
        active = _is_active(medication, day)
        times = {schedule.time for schedule in medication.schedules} if active else set()
        logged_times = {
            log.scheduled_time for log in medication.logs if log.log_date == day
        }
        if not times and not logged_times:
            continue
        for scheduled_time in sorted(times | logged_times):
            items.append(_dose_dict(medication, day, scheduled_time))
    items.sort(key=lambda item: (item["scheduled_time"], item["name"], item["medication_id"]))
    return items


def _require_scheduled_dose(medication: Medication, day: date, scheduled_time: str) -> None:
    if not _is_active(medication, day):
        raise HTTPException(status_code=400, detail="해당 날짜에는 복용 일정이 없습니다.")
    times = {schedule.time for schedule in medication.schedules}
    if scheduled_time not in times:
        raise HTTPException(status_code=400, detail="해당 복용 시간이 등록되어 있지 않습니다.")


def mark_taken(db: Session, payload: DoseAction) -> dict:
    medication = _get_or_404(db, payload.medication_id)
    _require_scheduled_dose(medication, payload.date, payload.scheduled_time)
    log = _find_log(medication, payload.date, payload.scheduled_time)
    if log is None:
        log = MedicationLog(
            medication_id=medication.id,
            log_date=payload.date,
            scheduled_time=payload.scheduled_time,
            taken=True,
            taken_at=now_kst_iso(),
        )
        db.add(log)
    elif not log.taken:
        log.taken = True
        log.taken_at = now_kst_iso()
    db.commit()
    return _dose_dict(_get_or_404(db, medication.id), payload.date, payload.scheduled_time)


def cancel_taken(db: Session, payload: DoseAction) -> dict:
    medication = _get_or_404(db, payload.medication_id)
    _require_scheduled_dose(medication, payload.date, payload.scheduled_time)
    log = _find_log(medication, payload.date, payload.scheduled_time)
    if log is not None:
        log.taken = False
        log.taken_at = None
    db.commit()
    return _dose_dict(_get_or_404(db, medication.id), payload.date, payload.scheduled_time)
