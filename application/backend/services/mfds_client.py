import html
import json
import os
import re
import threading
from urllib.error import HTTPError, URLError
from urllib.parse import quote, unquote
from urllib.request import Request, urlopen

_EASY_URL = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"
_DUR_URL = "https://apis.data.go.kr/1471000/DURPrdlstInfoService03/getDurPrdlstInfoList03"
_BLOCK_END = re.compile(r"(?i)<\s*/\s*(?:p|div|li|tr|h[1-6])\s*>")
_BR = re.compile(r"(?i)<\s*br\s*/?\s*>")
_TAG = re.compile(r"<[^>]+>")

_cache: dict[tuple[str, str], dict | None] = {}
_lock = threading.Lock()


def clear_public_cache() -> None:
    with _lock:
        _cache.clear()


def plain_text(value: object) -> str | None:
    """Keep the source wording and drop only HTML markup."""
    if value is None:
        return None
    text = str(value).replace("\xa0", " ")
    text = _BR.sub("\n", text)
    text = _BLOCK_END.sub("\n", text)
    text = _TAG.sub("", text)
    text = html.unescape(text).replace("\xa0", " ")
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    cleaned = "\n".join(lines).strip()
    return cleaned or None


def lookup_easy(item_seq: str) -> dict | None:
    return _lookup("easy", item_seq, _EASY_URL, "itemSeq")


def lookup_dur(item_seq: str) -> dict | None:
    return _lookup("dur", item_seq, _DUR_URL, "ITEM_SEQ")


def _lookup(source: str, item_seq: str, endpoint: str, seq_field: str) -> dict | None:
    seq = str(item_seq).strip()
    if not seq:
        return None
    key = (source, seq)
    with _lock:
        if key in _cache:
            return _cache[key]

    service_key = os.getenv("MFDS_SERVICE_KEY", "").strip()
    if not service_key:
        return None

    try:
        payload = _fetch_json(_request_url(endpoint, service_key, seq))
        row = _exact_row(payload, seq_field, seq)
    except (HTTPError, URLError, TimeoutError, OSError, ValueError, KeyError, TypeError):
        return None

    with _lock:
        _cache[key] = row
    return row


def _request_url(endpoint: str, service_key: str, item_seq: str) -> str:
    encoded_key = quote(unquote(service_key), safe="")
    return (
        f"{endpoint}?serviceKey={encoded_key}&type=json&pageNo=1&numOfRows=10"
        f"&itemSeq={quote(item_seq)}"
    )


def _fetch_json(url: str) -> dict:
    request = Request(url, headers={"Accept": "application/json"})
    with urlopen(request, timeout=10) as response:
        raw = response.read()
    data = json.loads(raw.decode("utf-8"))
    if not isinstance(data, dict):
        raise ValueError("unexpected payload")
    return data


def _exact_row(payload: dict, seq_field: str, item_seq: str) -> dict | None:
    header = payload.get("header") or {}
    if str(header.get("resultCode", "")) != "00":
        raise ValueError("upstream result")
    body = payload.get("body") or {}
    for row in _rows(body.get("items")):
        if str(row.get(seq_field, "")).strip() == item_seq:
            return row
    return None


def _rows(items: object) -> list[dict]:
    if items is None:
        return []
    if isinstance(items, list):
        return [row for row in items if isinstance(row, dict)]
    if isinstance(items, dict):
        item = items.get("item", items)
        if isinstance(item, list):
            return [row for row in item if isinstance(row, dict)]
        if isinstance(item, dict) and item is not items:
            return [item]
        if "item" not in items and any(not isinstance(value, (dict, list)) for value in items.values()):
            return [items]
    return []
