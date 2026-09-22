"""루즈한 GT bbox를 알약 경계에 맞게 타이트하게 잡아주는 도구.
사용법: python3 bbox_tightening.py
tightened_annotations.json으로 결과 저장.
"""
import os
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


def main():
    data_root = "/Users/codeit/Desktop/데이터/sprint_ai_project1_data"
    image_dir = os.path.join(data_root, "train_images")
    ann_paths = glob.glob(os.path.join(data_root, "train_annotations", "**", "*.json"), recursive=True)

    records = {}
    for p in ann_paths:
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        img = d["images"][0]
        cid = parse_dl_mapping_code(img["dl_mapping_code"])
        stem = os.path.splitext(img["file_name"])[0]
        rec = records.setdefault(stem, {"file_name": img["file_name"], "annotations": []})
        for ann in d.get("annotations", []):
            if len(ann.get("bbox", [])) == 4:
                rec["annotations"].append({"bbox": ann["bbox"], "category_id": cid})

    n_changed = 0
    for stem, rec in records.items():
        img_path = os.path.join(image_dir, rec["file_name"])
        image = cv2.imread(img_path)
        if image is None:
            continue
        for ann in rec["annotations"]:
            old = ann["bbox"]
            new = tighten_bbox(image, old)
            if new != old:
                n_changed += 1
            ann["bbox"] = new

    out_path = os.path.join(data_root, "tightened_annotations.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False)

    print(f"타이트닝된 박스: {n_changed}개, 저장 완료: {out_path}")


if __name__ == "__main__":
    main()
