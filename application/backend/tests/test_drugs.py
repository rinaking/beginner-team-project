from services import drug_info_service
from services.prediction_service import assemble_detection


def test_catalog_links_every_class_to_a_drug():
    assert drug_info_service.supported_count() == 118
    assert len(drug_info_service.class_mapping) == 118
    missing = []
    for class_id, k_code in drug_info_service.class_mapping.items():
        drug = drug_info_service.get_drug(k_code)
        if not drug or not str(drug.get("name", "")).strip():
            missing.append((class_id, k_code))
    assert missing == []


def test_search_finds_drug_by_name(client):
    k_code = drug_info_service.class_mapping["0"]
    name = drug_info_service.get_drug(k_code)["name"]

    response = client.get("/drugs/search", params={"q": name})

    assert response.status_code == 200
    results = response.json()["results"]
    match = next(item for item in results if item["k_code"] == k_code)
    assert match["drug"]["name"] == name
    assert "item_seq" in match["drug"]


def test_empty_search_returns_no_drugs(client):
    response = client.get("/drugs/search", params={"q": "   "})
    assert response.status_code == 200
    assert response.json()["results"] == []


def test_unknown_drug_returns_404(client):
    response = client.get("/drugs/K-does-not-exist")
    assert response.status_code == 404
    assert response.json()["detail"] == "등록된 의약품 정보를 찾을 수 없습니다."


def _patch_sources(monkeypatch, easy=None, dur=None):
    monkeypatch.setattr(drug_info_service, "lookup_easy", lambda _seq: easy)
    monkeypatch.setattr(drug_info_service, "lookup_dur", lambda _seq: dur)


def test_drug_detail_keeps_mapping_when_public_sources_miss(client, monkeypatch):
    _patch_sources(monkeypatch)
    k_code = "K-004378"
    response = client.get(f"/drugs/{k_code}")
    assert response.status_code == 200
    body = response.json()
    drug = drug_info_service.get_drug(k_code)
    assert body["drug"]["name"] == drug["name"]
    assert body["basics"]["material"] == drug["material"]
    assert body["basics"]["company"] == drug["company"]
    assert body["basics"]["class_no"] == drug["class_no"]
    assert body["basics"]["chart"] == drug["chart"]
    assert body["basics"]["storage_method"] is None
    assert body["official"] == {
        "efficacy": None,
        "dosage": None,
        "caution": None,
        "before_use": None,
        "side_effect": None,
        "interaction_note": None,
    }
    assert "EE_DOC_ID" not in body["basics"]
    assert "TYPE_NAME" not in response.text


def test_easy_and_dur_detail_uses_easy_text_and_mapping_basics(client, monkeypatch):
    _patch_sources(
        monkeypatch,
        easy={
            "itemSeq": "197900277",
            "itemName": "다른 이름",
            "efcyQesitm": "<p>두통에 사용합니다.</p>",
            "useMethodQesitm": "성인 1회 1정",
            "atpnQesitm": "과다 복용하지 않습니다.",
            "atpnWarnQesitm": "알레르기가 있으면 전문가와 상의합니다.",
            "seQesitm": "발진이 나타날 수 있습니다.",
            "intrcQesitm": "다른 해열제와 함께 주의합니다.",
            "depositMethodQesitm": "습기를 피해 보관합니다.",
        },
        dur={
            "ITEM_SEQ": "197900277",
            "ITEM_NAME": "게보린정(수출명:돌로린정)",
            "ENTP_NAME": "다른 업체",
            "STORAGE_METHOD": "기밀용기",
            "VALID_TERM": "제조일로부터 36개월",
            "EE_DOC_ID": "https://nedrug.mfds.go.kr/pbp/cmn/pdfViewer/197900277/EE",
            "TYPE_NAME  ": "임부금기",
        },
    )
    response = client.get("/drugs/K-000573")
    assert response.status_code == 200
    body = response.json()
    assert body["drug"]["name"] == "게보린정 300mg/PTP"
    assert body["basics"]["company"] == "삼진제약(주)"
    assert body["basics"]["storage_method"] == "습기를 피해 보관합니다."
    assert body["basics"]["valid_term"] == "제조일로부터 36개월"
    assert body["official"]["efficacy"] == "두통에 사용합니다."
    assert body["official"]["dosage"] == "성인 1회 1정"
    assert body["official"]["caution"] == "과다 복용하지 않습니다."
    assert body["official"]["before_use"] == "알레르기가 있으면 전문가와 상의합니다."
    assert "nedrug" not in response.text
    assert "임부금기" not in response.text


def test_easy_only_detail_has_monograph_without_dur_fields(client, monkeypatch):
    _patch_sources(
        monkeypatch,
        easy={
            "itemSeq": "197400246",
            "efcyQesitm": "위산 과다에 사용합니다.",
            "useMethodQesitm": "성인 1회 1정",
            "atpnQesitm": "신장 질환이 있으면 전문가와 상의합니다.",
        },
    )
    body = client.get("/drugs/K-000250").json()
    assert body["drug"]["name"] == "마그밀정(수산화마그네슘)"
    assert body["basics"]["company"] == "삼남제약(주)"
    assert body["basics"]["storage_method"] is None
    assert body["official"]["efficacy"] == "위산 과다에 사용합니다."
    assert body["official"]["dosage"] == "성인 1회 1정"
    assert body["official"]["caution"] == "신장 질환이 있으면 전문가와 상의합니다."


def test_dur_only_detail_supplements_gaps_without_inventing_monograph(client, monkeypatch):
    _patch_sources(
        monkeypatch,
        dur={
            "ITEM_SEQ": "200410085",
            "ITEM_NAME": "리피토정20밀리그램(아토르바스타틴칼슘삼수화물)",
            "ENTP_NAME": "다른 업체",
            "CHART": "다른 성상",
            "STORAGE_METHOD": "기밀용기, 실온보관",
            "VALID_TERM": "제조일로부터 36개월",
            "EE_DOC_ID": "https://nedrug.mfds.go.kr/pbp/cmn/pdfViewer/200410085/EE",
            "UD_DOC_ID": "https://nedrug.mfds.go.kr/pbp/cmn/pdfViewer/200410085/UD",
            "NB_DOC_ID": "https://nedrug.mfds.go.kr/pbp/cmn/pdfViewer/200410085/NB",
            "TYPE_CODE": "C,D",
            "TYPE_NAME  ": "임부금기,용량주의",
        },
    )
    body = client.get("/drugs/K-016232").json()
    drug = drug_info_service.get_drug("K-016232")
    assert body["drug"]["name"] == drug["name"]
    assert body["basics"]["company"] == drug["company"]
    assert body["basics"]["chart"] == drug["chart"]
    assert body["basics"]["storage_method"] == "기밀용기, 실온보관"
    assert body["basics"]["valid_term"] == "제조일로부터 36개월"
    assert body["official"]["efficacy"] is None
    assert body["official"]["dosage"] is None
    assert body["official"]["caution"] is None
    assert "임부금기" not in str(body)
    assert "nedrug" not in str(body)


def test_public_api_failure_still_returns_mapping(client, monkeypatch):
    def fail(_seq):
        raise RuntimeError("upstream down")

    monkeypatch.setattr(drug_info_service, "lookup_easy", fail)
    monkeypatch.setattr(drug_info_service, "lookup_dur", fail)
    response = client.get("/drugs/K-004378")
    assert response.status_code == 200
    body = response.json()
    assert body["drug"]["name"] == "타이레놀정500mg"
    assert body["basics"]["material"] == "아세트아미노펜"
    assert body["official"]["efficacy"] is None


def test_dur_fills_only_empty_mapping_fields(monkeypatch):
    drug = {
        "name": "예시정",
        "item_seq": 1,
        "material": "성분A",
        "company": "",
        "etc_otc": "전문의약품",
        "class_no": "[001]분류",
        "chart": "",
    }
    monkeypatch.setattr(drug_info_service, "get_drug", lambda _k: drug)
    _patch_sources(
        monkeypatch,
        dur={
            "ITEM_SEQ": "1",
            "ITEM_NAME": "다른이름",
            "ENTP_NAME": "DUR업체",
            "ETC_OTC_CODE": "일반의약품",
            "CLASS_NO": "[999]다른분류",
            "CHART": "흰색 원형정",
            "MATERIAL_NAME": "다른성분,,10,밀리그램",
            "STORAGE_METHOD": "실온보관",
            "VALID_TERM": "제조일로부터 24개월",
        },
    )
    body = drug_info_service.compose_drug_detail("K-TEST")
    assert body["drug"]["name"] == "예시정"
    assert body["basics"]["material"] == "성분A"
    assert body["basics"]["company"] == "DUR업체"
    assert body["basics"]["etc_otc"] == "전문의약품"
    assert body["basics"]["class_no"] == "[001]분류"
    assert body["basics"]["chart"] == "흰색 원형정"
    assert body["official"]["efficacy"] is None


def test_unmapped_class_has_no_invented_drug():
    detection = assemble_detection(999999, 0.42, {"x1": 1, "y1": 2, "x2": 3, "y2": 4})
    assert detection["k_code"] is None
    assert detection["drug"] is None
    assert detection["class_id"] == 999999


def test_interaction_check_does_not_invent_safety(client):
    k_code = drug_info_service.class_mapping["0"]
    other = drug_info_service.class_mapping["1"]
    response = client.post(
        "/interactions/check",
        json={"k_code": k_code, "compare_k_codes": [other]},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["data_available"] is False
    assert body["interactions"] == []
    assert body["message"] == "확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다."
    assert "함께 복용해도" not in body["message"]


def test_meta_reports_catalog_size(client):
    response = client.get("/meta")
    assert response.status_code == 200
    body = response.json()
    assert body["supported_drug_count"] == 118
    assert body["interaction_data_available"] is False
