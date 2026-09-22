"""루즈한 GT bbox를 알약 경계에 맞게 타이트하게 잡아주는 도구.

사용법:
  python3 bbox_tightening.py            전체 자동 타이트닝 (기존 방식)
  python3 bbox_tightening.py review     사람 검수 파이프라인
    1) 이상 bbox 후보 탐지
    2) tighten_bbox + findContours로 보정안 계산
    3) 4x5 그리드 이미지로 원본/제안 검수용 저장 (review_grids/page_*.png)
    4) 검수자가 approved_ids.txt에 승인할 후보 번호를 적어넣음
    5) corrections.csv에 승인된 보정만 저장
    6) image_records_corrected에 반영 + YOLO 라벨 재생성
"""
import os
import sys
import csv
import json
import glob
import re

import numpy as np
import cv2


def parse_dl_mapping_code(code):
    m = re.fullmatch(r"K-(\d+)", str(code).strip())
    return int(m.group(1)) if m else None


def tighten_bbox(image, bbox, pad=15, margin=4, min_area_ratio=0.15, bg_sample=6):
    H, W = image.shape[:2]
    x, y, w, h = bbox
    cx0, cy0 = x + w / 2, y + h / 2

    x0, y0 = max(0, int(x - pad)), max(0, int(y - pad))
    x1, y1 = min(W, int(x + w + pad)), min(H, int(y + h + pad))
    crop = image[y0:y1, x0:x1]
    if crop.size == 0:
        return bbox

    border_px = np.concatenate([
        crop[:bg_sample, :].reshape(-1, 3), crop[-bg_sample:, :].reshape(-1, 3),
        crop[:, :bg_sample].reshape(-1, 3), crop[:, -bg_sample:].reshape(-1, 3),
    ], axis=0)
    bg_color = np.median(border_px, axis=0)

    dist = np.linalg.norm(crop.astype(np.float32) - bg_color.astype(np.float32), axis=2)
    thresh = max(20.0, np.std(dist) * 0.5 + np.median(dist))
    mask = (dist > thresh).astype(np.uint8) * 255
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return bbox

    def score(c):
        area = cv2.contourArea(c)
        if area < min_area_ratio * crop.shape[0] * crop.shape[1]:
            return -1
        bx, by, bw, bh = cv2.boundingRect(c)
        center_dist = np.hypot((x0 + bx + bw / 2) - cx0, (y0 + by + bh / 2) - cy0)
        return area / (1 + center_dist)

    best = max(contours, key=score)
    if score(best) <= 0:
        return bbox

    cx, cy, cw, ch = cv2.boundingRect(best)
    new_x = max(0, x0 + cx - margin)
    new_y = max(0, y0 + cy - margin)
    new_x2 = min(W, x0 + cx + cw + margin)
    new_y2 = min(H, y0 + cy + ch + margin)
    tight = [new_x, new_y, new_x2 - new_x, new_y2 - new_y]

    if (tight[2] * tight[3]) < min_area_ratio * (w * h):
        return bbox
    return tight


DATA_ROOT = "/Users/codeit/Desktop/데이터/sprint_ai_project1_data"


def load_records(data_root=DATA_ROOT):
    ann_paths = glob.glob(os.path.join(data_root, "train_annotations", "**", "*.json"), recursive=True)
    records = {}
    for p in ann_paths:
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        img = d["images"][0]
        cid = parse_dl_mapping_code(img["dl_mapping_code"])
        stem = os.path.splitext(img["file_name"])[0]
        rec = records.setdefault(stem, {
            "file_name": img["file_name"], "width": img["width"], "height": img["height"], "annotations": [],
        })
        for ann in d.get("annotations", []):
            if len(ann.get("bbox", [])) == 4:
                rec["annotations"].append({"bbox": ann["bbox"], "category_id": cid})
    return records


def main():
    records = load_records()
    image_dir = os.path.join(DATA_ROOT, "train_images")

    n_changed = 0
    for stem, rec in records.items():
        image = cv2.imread(os.path.join(image_dir, rec["file_name"]))
        if image is None:
            continue
        for ann in rec["annotations"]:
            old = ann["bbox"]
            new = tighten_bbox(image, old)
            if new != old:
                n_changed += 1
            ann["bbox"] = new

    out_path = os.path.join(DATA_ROOT, "tightened_annotations.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False)

    print(f"타이트닝된 박스: {n_changed}개, 저장 완료: {out_path}")


# ---------------------------------------------------------------------------
# 사람 검수 파이프라인 (이상 bbox 후보 탐지 -> 검수 -> 승인분만 반영 -> YOLO 라벨 재생성)
# ---------------------------------------------------------------------------

def detect_suspect_boxes(records, image_dir, area_ratio_threshold=0.5):
    """tighten_bbox 적용 시 면적이 threshold 이하로 줄어드는 후보만 추린다.
    0.5(절반 이상 줄어듦) 기준: 대부분의 정상적인 타이트닝은 70~80%대라 여기 안 걸리고,
    실제로 잘라먹을 위험이 있는 "많이 줄어든" 경우만 걸러서 검수 대상으로 삼는다."""
    candidates = []
    for stem, rec in records.items():
        image = cv2.imread(os.path.join(image_dir, rec["file_name"]))
        if image is None:
            continue
        for idx, ann in enumerate(rec["annotations"]):
            old = ann["bbox"]
            new = tighten_bbox(image, old)
            old_area = old[2] * old[3]
            new_area = new[2] * new[3]
            ratio = new_area / old_area if old_area else 1.0
            if ratio < area_ratio_threshold:
                candidates.append({
                    "id": len(candidates), "stem": stem, "ann_index": idx,
                    "category_id": ann["category_id"], "old_bbox": old, "new_bbox": new, "ratio": ratio,
                })
    return candidates


def save_review_grids(candidates, image_dir, records, out_dir="review_grids", per_page=20, cols=4):
    os.makedirs(out_dir, exist_ok=True)
    rows = per_page // cols

    for page_start in range(0, len(candidates), per_page):
        page = candidates[page_start:page_start + per_page]
        tiles = []
        for cand in page:
            rec = records[cand["stem"]]
            image = cv2.imread(os.path.join(image_dir, rec["file_name"]))
            ox, oy, ow, oh = [int(v) for v in cand["old_bbox"]]
            nx, ny, nw, nh = [int(v) for v in cand["new_bbox"]]
            cv2.rectangle(image, (ox, oy), (ox + ow, oy + oh), (0, 0, 255), 2)   # 빨강 = 원본
            cv2.rectangle(image, (nx, ny), (nx + nw, ny + nh), (0, 255, 0), 2)   # 초록 = 제안
            crop = image[max(0, oy - 30):oy + oh + 30, max(0, ox - 30):ox + ow + 30]
            tile = cv2.resize(crop, (240, 240)) if crop.size else np.zeros((240, 240, 3), np.uint8)
            cv2.putText(tile, f"#{cand['id']}", (5, 20), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
            tiles.append(tile)

        while len(tiles) < per_page:
            tiles.append(np.zeros((240, 240, 3), np.uint8))

        grid_rows = [np.hstack(tiles[r * cols:(r + 1) * cols]) for r in range(rows)]
        grid = np.vstack(grid_rows)
        page_idx = page_start // per_page
        cv2.imwrite(os.path.join(out_dir, f"page_{page_idx}.png"), grid)

    print(f"검수용 그리드 {len(range(0, len(candidates), per_page))}장 저장: {out_dir}/page_*.png")
    print(f"각 그리드의 #번호를 보고 승인할 번호를 {DATA_ROOT}/approved_ids.txt에 한 줄씩 적어주세요.")


def read_approved_ids(path=None):
    path = path or os.path.join(DATA_ROOT, "approved_ids.txt")
    if not os.path.exists(path):
        return set()
    with open(path, encoding="utf-8") as f:
        return {int(line.strip()) for line in f if line.strip().isdigit()}


def save_corrections_csv(candidates, approved_ids, out_path=None):
    out_path = out_path or os.path.join(DATA_ROOT, "corrections.csv")
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["stem", "category_id", "old_bbox", "new_bbox"])
        n = 0
        for cand in candidates:
            if cand["id"] not in approved_ids:
                continue
            writer.writerow([cand["stem"], cand["category_id"], cand["old_bbox"], cand["new_bbox"]])
            n += 1
    print(f"승인된 보정 {n}건 저장: {out_path}")
    return out_path


def apply_corrections(records, corrections_csv):
    corrected = json.loads(json.dumps(records))  # deep copy
    with open(corrections_csv, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            stem, cid = row["stem"], int(row["category_id"])
            new_bbox = json.loads(row["new_bbox"])
            for ann in corrected[stem]["annotations"]:
                if ann["category_id"] == cid and ann["bbox"] == json.loads(row["old_bbox"]):
                    ann["bbox"] = new_bbox
    return corrected


def regenerate_yolo_labels(records_corrected, yolo_root="yolo_dataset", split="train"):
    label_map_path = os.path.join(DATA_ROOT, "yolo_category_label_map.json")
    category_to_label = {int(k): v for k, v in json.load(open(label_map_path))["category_to_label"].items()}

    label_dir = os.path.join(yolo_root, "labels", split)
    n = 0
    for stem, rec in records_corrected.items():
        label_path = os.path.join(label_dir, f"{stem}.txt")
        if not os.path.exists(label_path):
            continue  # 이 split에 없는 이미지
        w, h = rec["width"], rec["height"]
        lines = []
        for ann in rec["annotations"]:
            x, y, bw, bh = ann["bbox"]
            cls_id = category_to_label[ann["category_id"]]
            lines.append(f"{cls_id} {(x + bw/2)/w:.6f} {(y + bh/2)/h:.6f} {bw/w:.6f} {bh/h:.6f}")
        with open(label_path, "w") as f:
            f.write("\n".join(lines))
        n += 1
    print(f"YOLO 라벨 재생성 완료: {n}개 파일 ({label_dir})")


def review_pipeline():
    records = load_records()
    image_dir = os.path.join(DATA_ROOT, "train_images")

    candidates = detect_suspect_boxes(records, image_dir)
    print(f"이상 bbox 후보: {len(candidates)}개")

    save_review_grids(candidates, image_dir, records)

    approved_ids = read_approved_ids()
    if not approved_ids:
        print("approved_ids.txt가 비어있습니다. 그리드를 확인하고 승인 번호를 적은 뒤 다시 실행하세요.")
        return

    corrections_csv = save_corrections_csv(candidates, approved_ids)
    records_corrected = apply_corrections(records, corrections_csv)
    regenerate_yolo_labels(records_corrected)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "review":
        review_pipeline()
    else:
        main()
