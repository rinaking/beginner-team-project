from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from database.database import get_db
from schemas.medication import DoseAction, DoseOut, ScheduleResponse
from services import medication_service

router = APIRouter(tags=["schedules"])


@router.get("/schedules/today", response_model=ScheduleResponse)
def today_schedule(db: Session = Depends(get_db)):
    day = medication_service.today_kst()
    return {"date": day, "items": medication_service.doses_for_date(db, day)}


@router.get("/schedules", response_model=ScheduleResponse)
def schedule_for_date(
    day: date = Query(alias="date"),
    db: Session = Depends(get_db),
):
    return {"date": day, "items": medication_service.doses_for_date(db, day)}


@router.get("/history", response_model=ScheduleResponse)
def history(
    day: date | None = Query(default=None, alias="date"),
    db: Session = Depends(get_db),
):
    target = day or medication_service.today_kst()
    return {"date": target, "items": medication_service.doses_for_date(db, target)}


@router.post("/schedules/taken", response_model=DoseOut)
def mark_taken(payload: DoseAction, db: Session = Depends(get_db)):
    return medication_service.mark_taken(db, payload)


@router.post("/schedules/cancel", response_model=DoseOut)
def cancel_taken(payload: DoseAction, db: Session = Depends(get_db)):
    return medication_service.cancel_taken(db, payload)
