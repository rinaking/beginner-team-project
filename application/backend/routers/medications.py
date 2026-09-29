from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.orm import Session

from database.database import get_db
from schemas.medication import MedicationOut, MedicationWrite
from services import medication_service

router = APIRouter(tags=["medications"])


@router.get("/medications", response_model=list[MedicationOut])
def list_medications(db: Session = Depends(get_db)):
    return medication_service.list_medications(db)


@router.post("/medications", response_model=MedicationOut, status_code=201)
def create_medication(payload: MedicationWrite, db: Session = Depends(get_db)):
    return medication_service.create_medication(db, payload)


@router.get("/medications/{medication_id}", response_model=MedicationOut)
def get_medication(medication_id: int, db: Session = Depends(get_db)):
    return medication_service.get_medication(db, medication_id)


@router.put("/medications/{medication_id}", response_model=MedicationOut)
def update_medication(
    medication_id: int,
    payload: MedicationWrite,
    db: Session = Depends(get_db),
):
    return medication_service.update_medication(db, medication_id, payload)


@router.delete("/medications/{medication_id}", status_code=204)
def delete_medication(medication_id: int, db: Session = Depends(get_db)):
    medication_service.delete_medication(db, medication_id)
    return Response(status_code=204)
