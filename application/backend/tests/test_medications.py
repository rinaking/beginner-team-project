from datetime import timedelta

from fastapi.testclient import TestClient

from main import app
from services.medication_service import today_kst


def _payload(k_code: str, **overrides):
    day = today_kst()
    body = {
        "k_code": k_code,
        "start_date": day.isoformat(),
        "end_date": None,
        "times": ["20:00", "08:00"],
        "memo": "식후",
    }
    body.update(overrides)
    return body


def test_medication_crud_schedule_taken_and_history(client):
    from services import drug_info_service

    k_code = drug_info_service.class_mapping["0"]
    drug_name = drug_info_service.get_drug(k_code)["name"]
    created = client.post("/medications", json=_payload(k_code))
    assert created.status_code == 201
    medication = created.json()
    medication_id = medication["id"]
    assert medication["name"] == drug_name
    assert medication["times"] == ["08:00", "20:00"]
    assert medication["drug"]["name"] == drug_name
    assert medication["memo"] == "식후"

    fetched = client.get(f"/medications/{medication_id}")
    assert fetched.status_code == 200
    assert fetched.json()["k_code"] == k_code

    today = client.get("/schedules/today")
    assert today.status_code == 200
    items = today.json()["items"]
    assert [item["scheduled_time"] for item in items] == ["08:00", "20:00"]
    assert all(item["taken"] is False for item in items)
    assert all(item["name"] == drug_name for item in items)

    day = today.json()["date"]
    taken = client.post(
        "/schedules/taken",
        json={"medication_id": medication_id, "date": day, "scheduled_time": "08:00"},
    )
    assert taken.status_code == 200
    assert taken.json()["taken"] is True
    assert taken.json()["taken_at"]

    again = client.post(
        "/schedules/taken",
        json={"medication_id": medication_id, "date": day, "scheduled_time": "08:00"},
    )
    assert again.status_code == 200
    assert again.json()["taken_at"] == taken.json()["taken_at"]

    history = client.get("/history", params={"date": day})
    assert history.status_code == 200
    history_items = history.json()["items"]
    assert history_items[0]["taken"] is True
    assert history_items[0]["taken_at"] == taken.json()["taken_at"]
    assert history_items[1]["scheduled_time"] == "20:00"
    assert history_items[1]["taken"] is False

    cancelled = client.post(
        "/schedules/cancel",
        json={"medication_id": medication_id, "date": day, "scheduled_time": "08:00"},
    )
    assert cancelled.status_code == 200
    assert cancelled.json()["taken"] is False
    assert cancelled.json()["taken_at"] is None

    updated = client.put(
        f"/medications/{medication_id}",
        json=_payload(
            k_code,
            times=["09:30"],
            memo="변경",
            end_date=(today_kst() + timedelta(days=3)).isoformat(),
        ),
    )
    assert updated.status_code == 200
    assert updated.json()["times"] == ["09:30"]
    assert updated.json()["memo"] == "변경"
    assert updated.json()["end_date"] == (today_kst() + timedelta(days=3)).isoformat()

    with TestClient(app) as restarted:
        persisted = restarted.get("/medications")
    assert persisted.status_code == 200
    assert persisted.json()[0]["id"] == medication_id
    assert persisted.json()[0]["times"] == ["09:30"]

    deleted = client.delete(f"/medications/{medication_id}")
    assert deleted.status_code == 204
    assert client.get(f"/medications/{medication_id}").status_code == 404
    assert client.get("/schedules/today").json()["items"] == []
    assert client.get("/history", params={"date": day}).json()["items"] == []


def test_inactive_medication_is_excluded_from_today(client):
    from services import drug_info_service

    k_code = drug_info_service.class_mapping["1"]
    tomorrow = (today_kst() + timedelta(days=1)).isoformat()
    yesterday = (today_kst() - timedelta(days=1)).isoformat()
    created = client.post(
        "/medications",
        json=_payload(k_code, start_date=tomorrow, times=["08:00"]),
    )
    assert created.status_code == 201
    ended = client.post(
        "/medications",
        json=_payload(
            k_code,
            start_date=yesterday,
            end_date=yesterday,
            times=["08:00"],
        ),
    )
    assert ended.status_code == 201
    assert client.get("/schedules/today").json()["items"] == []


def test_medication_validation_errors(client):
    from services import drug_info_service

    k_code = drug_info_service.class_mapping["2"]
    missing_time = client.post("/medications", json=_payload(k_code, times=[]))
    assert missing_time.status_code == 422
    assert missing_time.json()["detail"] == "복용 시간을 하나 이상 입력해 주세요."

    bad_time = client.post("/medications", json=_payload(k_code, times=["25:00"]))
    assert bad_time.status_code == 422
    assert "복용 시간" in bad_time.json()["detail"]

    reversed_dates = client.post(
        "/medications",
        json=_payload(
            k_code,
            start_date="2026-09-27",
            end_date="2026-09-26",
            times=["08:00"],
        ),
    )
    assert reversed_dates.status_code == 422
    assert reversed_dates.json()["detail"] == "복용 종료일은 시작일보다 빠를 수 없습니다."

    unknown = client.post("/medications", json=_payload("K-not-real", times=["08:00"]))
    assert unknown.status_code == 404


def test_taken_rejects_unknown_schedule(client):
    from services import drug_info_service

    k_code = drug_info_service.class_mapping["3"]
    created = client.post("/medications", json=_payload(k_code, times=["08:00"]))
    medication_id = created.json()["id"]
    day = today_kst().isoformat()

    wrong_time = client.post(
        "/schedules/taken",
        json={"medication_id": medication_id, "date": day, "scheduled_time": "21:00"},
    )
    assert wrong_time.status_code == 400
    assert wrong_time.json()["detail"] == "해당 복용 시간이 등록되어 있지 않습니다."

    outside = client.post(
        "/schedules/taken",
        json={
            "medication_id": medication_id,
            "date": "2020-01-01",
            "scheduled_time": "08:00",
        },
    )
    assert outside.status_code == 400
    assert outside.json()["detail"] == "해당 날짜에는 복용 일정이 없습니다."

    missing = client.post(
        "/schedules/cancel",
        json={"medication_id": 9999, "date": day, "scheduled_time": "08:00"},
    )
    assert missing.status_code == 404
