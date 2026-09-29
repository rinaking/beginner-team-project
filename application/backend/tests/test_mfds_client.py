import services.mfds_client as mfds_client


def test_plain_text_keeps_wording_and_drops_tags():
    raw = "<p>두통에 사용합니다.</p><br>성인 1회 1정"
    assert mfds_client.plain_text(raw) == "두통에 사용합니다.\n성인 1회 1정"
    assert mfds_client.plain_text("  ") is None
    assert mfds_client.plain_text(None) is None


def test_lookup_requires_exact_item_seq_and_caches_miss(monkeypatch):
    calls = {"n": 0}

    def fetch(_url):
        calls["n"] += 1
        return {
            "header": {"resultCode": "00", "resultMsg": "NORMAL SERVICE."},
            "body": {
                "totalCount": 1,
                "items": [{"itemSeq": "999", "efcyQesitm": "다른 약"}],
            },
        }

    monkeypatch.setenv("MFDS_SERVICE_KEY", "test-key")
    monkeypatch.setattr(mfds_client, "_fetch_json", fetch)
    mfds_client.clear_public_cache()

    assert mfds_client.lookup_easy("197900277") is None
    assert mfds_client.lookup_easy("197900277") is None
    assert calls["n"] == 1
    assert "test-key" not in str(mfds_client._cache)


def test_lookup_does_not_cache_transport_errors(monkeypatch):
    calls = {"n": 0}

    def fetch(_url):
        calls["n"] += 1
        raise TimeoutError("slow")

    monkeypatch.setenv("MFDS_SERVICE_KEY", "test-key")
    monkeypatch.setattr(mfds_client, "_fetch_json", fetch)
    mfds_client.clear_public_cache()

    assert mfds_client.lookup_dur("200410085") is None
    assert mfds_client.lookup_dur("200410085") is None
    assert calls["n"] == 2


def test_lookup_caches_exact_row(monkeypatch):
    calls = {"n": 0}

    def fetch(_url):
        calls["n"] += 1
        return {
            "header": {"resultCode": "00"},
            "body": {
                "items": [
                    {
                        "ITEM_SEQ": "200410085",
                        "ITEM_NAME": "리피토정20밀리그램(아토르바스타틴칼슘삼수화물)",
                        "STORAGE_METHOD": "기밀용기",
                    }
                ]
            },
        }

    monkeypatch.setenv("MFDS_SERVICE_KEY", "test-key")
    monkeypatch.setattr(mfds_client, "_fetch_json", fetch)
    mfds_client.clear_public_cache()

    first = mfds_client.lookup_dur("200410085")
    second = mfds_client.lookup_dur("200410085")
    assert first["STORAGE_METHOD"] == "기밀용기"
    assert second == first
    assert calls["n"] == 1
