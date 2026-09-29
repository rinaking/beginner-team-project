import json
from pathlib import Path

from services.mfds_client import lookup_dur, lookup_easy, plain_text

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_DIR = BASE_DIR / "model"
CLASS_MAPPING_PATH = MODEL_DIR / "class_mapping.json"
DRUG_MAPPING_PATH = MODEL_DIR / "drug_mapping.json"

with CLASS_MAPPING_PATH.open(encoding="utf-8") as mapping_file:
    class_mapping: dict[str, str] = json.load(mapping_file)

with DRUG_MAPPING_PATH.open(encoding="utf-8") as mapping_file:
    drug_mapping: dict[str, dict] = json.load(mapping_file)


def supported_count() -> int:
    return len(drug_mapping)


def k_code_for_class(class_id: int) -> str | None:
    return class_mapping.get(str(class_id))


def get_drug(k_code: str | None) -> dict | None:
    if not k_code:
        return None
    return drug_mapping.get(k_code)


def compose_drug_detail(k_code: str) -> dict | None:
    """Map first, then fill gaps from e약은요 and DUR product info.

    Official prose comes only from e약은요 text fields. DUR document URLs
    and TYPE_NAME labels are not copied into the response.
    """
    drug = get_drug(k_code)
    if drug is None:
        return None

    easy = _source(lookup_easy, drug.get("item_seq"))
    dur = _source(lookup_dur, drug.get("item_seq"))

    return {
        "k_code": k_code,
        "drug": drug,
        "basics": {
            "etc_otc": _prefer(drug.get("etc_otc"), dur.get("ETC_OTC_CODE")),
            "material": _prefer(drug.get("material"), dur.get("MATERIAL_NAME")),
            "company": _prefer(drug.get("company"), dur.get("ENTP_NAME")),
            "class_no": _prefer(drug.get("class_no"), dur.get("CLASS_NO")),
            "chart": _prefer(drug.get("chart"), dur.get("CHART")),
            "storage_method": _prefer(
                easy.get("depositMethodQesitm"),
                dur.get("STORAGE_METHOD"),
            ),
            "valid_term": plain_text(dur.get("VALID_TERM")),
        },
        "official": {
            "efficacy": plain_text(easy.get("efcyQesitm")),
            "dosage": plain_text(easy.get("useMethodQesitm")),
            "caution": plain_text(easy.get("atpnQesitm")),
            "before_use": plain_text(easy.get("atpnWarnQesitm")),
            "side_effect": plain_text(easy.get("seQesitm")),
            "interaction_note": plain_text(easy.get("intrcQesitm")),
        },
    }


def _source(lookup, item_seq: object) -> dict:
    if item_seq is None or not str(item_seq).strip():
        return {}
    try:
        return lookup(str(item_seq).strip()) or {}
    except Exception:
        return {}


def _prefer(*values: object) -> str | None:
    for value in values:
        text = plain_text(value)
        if text:
            return text
    return None


def search_drugs(query: str, limit: int = 30) -> list[dict]:
    keyword = query.strip().lower()
    if not keyword:
        return []

    starts: list[dict] = []
    contains: list[dict] = []
    for k_code, drug in drug_mapping.items():
        name = str(drug.get("name", ""))
        name_en = str(drug.get("name_en", ""))
        folded_name = name.lower()
        folded_en = name_en.lower()
        item = {"k_code": k_code, "drug": drug}
        if folded_name.startswith(keyword) or folded_en.startswith(keyword):
            starts.append(item)
        elif keyword in folded_name or keyword in folded_en:
            contains.append(item)
    return (starts + contains)[:limit]
