# 팀원 확인 필요 사항 (김혜린 정리, 9/14)

GitHub 재현(reproduce.sh)이랑 보고서 작성에 실제로 필요한 정보 위주로 정리함. 답변 오면 requirements.md / report_outline.md에 바로 반영 예정.

## 유영관님

**1. ~~SSD300 제출 파일 생성 코드 위치~~ → 확인 완료 (9/14 오후, feature/initial-modeling 브랜치)**
- SSD300: `VGG16_SSD300.ipynb` 17번 셀 `ssd300_vgg16(..., detections_per_img=4)`가 원인 — 모델 생성 시부터 항상 4개 고정.
- RetinaNet: `RetinaNet_ResNet50_FPN_v2.ipynb` 36번 셀 `argsort(...)[:4]`가 원인 — score_thresh=0.05가 사실상 무필터라 항상 상위 4개.
- 제안: SSD300은 `detections_per_img` 제거/상향, RetinaNet은 score_thresh 0.3~0.5로 상향 — 괜찮으면 제가 고쳐서 PR 올려도 될까요?

**2. RetinaNet ResNet50 FPN v2 (Public Score 0.35127) 재현 정보**
- backbone 사전학습 가중치 (torchvision 어떤 weights 썼는지)
- conf threshold / NMS(iou) threshold / max_det 값
- epoch 수, optimizer, lr, batch size
- train/val 분할 방식 (랜덤인지, 조합 단위인지)
- 필요한 이유: 보고서 §4 모델 비교표, GitHub reproduce.sh에 넣을 정확한 커맨드

**3. GroupKFold 구현 진행 상황**
- 조합(파일명 K-XXXXX-XXXXX-XXXXX) 단위로 그룹핑해서 나누고 계신 게 맞나요?
- 참고: 제가 YOLOv8 실험에서 이미지 단위 랜덤 분할로 했다가 val 조합의 78%가 train에도 있어서 mAP가 가짜로 높게 나온 적 있어요. 같은 함정 피하시라고 공유드려요.

## 강인호님

**4. 그룹키 기준 (오늘 태스크)**
- EDA/전처리에서 잡으신 그룹키가 정확히 뭔가요? (파일명 접두어 기준 조합 코드가 맞는지)
- 필요한 이유: 유영관님 GroupKFold, 제 재분할 스크립트랑 기준이 같은지 맞춰야 함

**5. 클래스 커버리지 분석 결과**
- 오늘 하신 분석에서 제가 발견한 것(클래스 56종 중 18종이 인스턴스 5개 이하, 최다클래스가 전체의 20%)과 같은 결과 나왔는지 확인 부탁드려요.
- 다르게 나온 부분 있으면 어느 쪽이 맞는지 같이 봐야 할 것 같아요.

## 팀 전체 — 9/16 멘토링 전 확정 필요

**6. 증강 허용 범위**
- flip/rotate/mosaic 등 구체적으로 뭘 얼마나 쓸 수 있는지 멘토님께 여쭤볼 질문 목록, 같이 정리해요.

**7. 최순우님 Kaggle 팀 초대**
- 온보딩 끝나시면 말씀해주세요, 바로 초대 보낼게요.

---
답변은 디스코드에 편하게 남겨주시면 제가 정리해서 문서에 반영할게요.
