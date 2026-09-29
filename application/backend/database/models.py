from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, String, Text, UniqueConstraint
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class Medication(Base):
    __tablename__ = "medications"

    id: Mapped[int] = mapped_column(primary_key=True)
    k_code: Mapped[str] = mapped_column(String(32), index=True)
    name: Mapped[str] = mapped_column(String(255))
    start_date: Mapped[date] = mapped_column(Date)
    end_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.now, onupdate=datetime.now
    )

    schedules: Mapped[list["MedicationSchedule"]] = relationship(
        back_populates="medication",
        cascade="all, delete-orphan",
        order_by="MedicationSchedule.time",
    )
    logs: Mapped[list["MedicationLog"]] = relationship(
        back_populates="medication",
        cascade="all, delete-orphan",
    )


class MedicationSchedule(Base):
    __tablename__ = "medication_schedules"

    id: Mapped[int] = mapped_column(primary_key=True)
    medication_id: Mapped[int] = mapped_column(
        ForeignKey("medications.id", ondelete="CASCADE"), index=True
    )
    time: Mapped[str] = mapped_column(String(5))

    medication: Mapped[Medication] = relationship(back_populates="schedules")


class MedicationLog(Base):
    __tablename__ = "medication_logs"
    __table_args__ = (
        UniqueConstraint(
            "medication_id",
            "log_date",
            "scheduled_time",
            name="uq_medication_log",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    medication_id: Mapped[int] = mapped_column(
        ForeignKey("medications.id", ondelete="CASCADE"), index=True
    )
    log_date: Mapped[date] = mapped_column(Date, index=True)
    scheduled_time: Mapped[str] = mapped_column(String(5))
    taken: Mapped[bool] = mapped_column(Boolean, default=False)
    taken_at: Mapped[str | None] = mapped_column(String(40), nullable=True)

    medication: Mapped[Medication] = relationship(back_populates="logs")
