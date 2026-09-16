#@title Train 이미지 + Bounding Box 시각화 (bbox 형식 수정본)
# 기존 코드는 bbox를 [x1,y1,x2,y2]로 해석해서 잘못 그려짐.
# 실제 형식은 COCO 방식 [x, y, width, height] (캐글 Data 탭에 명시됨).

import json

n_samples = 5
sample_paths = np.random.choice(image_dir, size=n_samples, replace=False)

fig, axes = plt.subplots(1, n_samples, figsize=(5 * n_samples, 5))

for ax, img_path in zip(axes, sample_paths):
    img_stem = os.path.splitext(os.path.basename(img_path))[0]

    ann_path = next(
        (p for p in annotation_dir if os.path.splitext(os.path.basename(p))[0] == img_stem),
        None
    )

    train_image = cv2.imread(img_path)
    train_image = cv2.cvtColor(train_image, cv2.COLOR_BGR2RGB)

    if ann_path is not None:
        with open(ann_path, "r", encoding="utf-8") as f:
            ann = json.load(f)

        boxes = []
        if "annotations" in ann:
            for obj in ann["annotations"]:
                if "bbox" in obj:
                    x, y, w, h = obj["bbox"]
                    boxes.append([x, y, x + w, y + h])  # x,y,w,h -> x1,y1,x2,y2 변환
        elif "shapes" in ann:
            for obj in ann["shapes"]:
                if "points" in obj:
                    xs = [p[0] for p in obj["points"]]
                    ys = [p[1] for p in obj["points"]]
                    boxes.append([min(xs), min(ys), max(xs), max(ys)])

        for box in boxes:
            x1, y1, x2, y2 = map(int, box)
            cv2.rectangle(train_image, (x1, y1), (x2, y2), (255, 0, 0), 2)
    else:
        print(f"'{img_stem}'에 해당하는 annotation을 찾지 못했습니다.")

    ax.imshow(train_image)
    ax.set_title(img_stem, fontsize=10)
    ax.axis("off")

plt.tight_layout()
plt.show()


#@title 잘못된 라벨(bbox 범위 이탈) 제외
# build_image_records() 바로 다음에 실행. image_records를 정제된 버전으로 덮어씀.
def filter_invalid_annotations(image_records):
    cleaned = {}
    removed = []

    for stem, rec in image_records.items():
        W, H = rec["width"], rec["height"]
        valid_anns = []

        for ann in rec["annotations"]:
            x, y, w, h = ann["bbox"]
            if w <= 0 or h <= 0 or x < 0 or y < 0 or x + w > W or y + h > H:
                removed.append((stem, ann["bbox"]))
                continue
            valid_anns.append(ann)

        if valid_anns:
            new_rec = dict(rec)
            new_rec["annotations"] = valid_anns
            cleaned[stem] = new_rec
        else:
            removed.append((stem, "이미지 전체 제외(유효 annotation 없음)"))

    print(f"제외된 annotation/이미지: {len(removed)}건")
    for stem, info in removed:
        print(f"  {stem}: {info}")

    return cleaned


image_records = filter_invalid_annotations(image_records)
