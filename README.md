# Health Eat — 경구약제 이미지 객체 탐지

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)
![PyTorch](https://img.shields.io/badge/PyTorch-torchvision-orange.svg)
![Kaggle](https://img.shields.io/badge/Kaggle-Private%20Competition-20BEFF.svg)
![Best Score](https://img.shields.io/badge/Public%20Score-0.35127-brightgreen.svg)

사용자가 촬영한 알약 사진 한 장에서 최대 4개 약제의 종류(class)와 위치(bounding box)를 함께 인식하는 Object Detection 프로젝트입니다. 코드잇 AI 엔지니어링 14기 2팀이 Kaggle Private Competition(`ai14-level-project`)에 참가하며 진행했습니다.

| | |
| --- | --- |
| **최종 모델** | RetinaNet ResNet50-FPN v2 |
| **최종 Public Score** | 0.35127 |
| **평가 지표** | mAP@[0.75:0.95] |
| **데이터 규모** | 232장 → 8,068장 (AI-Hub 확장, 56클래스 기준) |
| **팀** | 코드잇 AI 엔지니어링 14기 2팀 (4인 → 3인) |

## 목차

- [핵심 결과](#핵심-결과)
- [프로젝트 개요](#프로젝트-개요)
- [폴더 구조](#폴더-구조)
- [실행 방법](#실행-방법)
- [모델 실험 결과](#모델-실험-결과)
- [협업 내용](#협업-내용)
- [제출물](#제출물)
- [라이선스](#라이선스)

---

## 핵심 결과

> **최종 Public Score 0.35127** (RetinaNet ResNet50-FPN v2, Kaggle Private Leaderboard)

| 발견 | 내용 |
| --- | --- |
| 데이터 확장 | 원본 232장 → AI-Hub 통합으로 8,068장까지 확장. 통제 실험으로 "데이터 양보다 클래스 다양성이 3배 이상 기여"함을 정량 검증 |
| 파이프라인 버그 | 로컬 mAP와 Kaggle Public Score 사이의 이상한 격차를 추적해 제출 파이프라인의 top-4 강제 출력 버그를 발견·수정 |
| 검증되지 않은 고득점 배제 | 로컬 mAP 0.986을 기록한 모델이 있었지만, validation split 코드를 직접 열어 근접 중복 유출(data leakage) 위험을 확인하고 최종 지표로 채택하지 않음 |

자세한 과정은 [모델 실험 결과](#모델-실험-결과)와 [`docs/최종발표자료임.pdf`](docs/최종발표자료임.pdf)를 참고하세요.

---

## 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| 목표 | 알약 이미지 1장당 최대 4개 객체의 class + bounding box 검출 |
| 데이터셋 | 대회 제공 232장(56클래스) + AI-Hub 외부 데이터로 확장한 8,068장(56클래스 기준) |
| 평가 지표 | mAP@[0.75:0.95] (Kaggle Private Leaderboard) |
| 주요 모델 | SSD300+VGG16(baseline), RetinaNet ResNet50-FPN v2(최종 채택), Faster R-CNN ResNet50-FPN v2, RTMDet-l, YOLO 계열 |
| 팀 구성 | 김혜린(PM · RetinaNet), 강인호(Data), 유영관(Model), 최순우(중도 하차), 멘토 문상준 |

---

## 폴더 구조

```
beginner-team-project/
├── RetinaNet_ResNet50_FPN_v2_final.ipynb   최종 채택 모델
├── 최초 모델링.ipynb                        SSD300+VGG16 baseline
├── bbox_tightening.py                      bbox 품질 검증·보정 도구
├── docs/                                   보고서 · 가이드 · 발표자료
├── models/ utils/ main.py                  초기 Git 협업 실습용 스캐폴드 (본 프로젝트 코드 아님)
└── .github/ISSUE_TEMPLATE/                 문서 · 버그 · 실험 이슈 템플릿
```

`docs/` 폴더 구성:

| 파일 | 내용 |
| --- | --- |
| `requirements.md` | 요구사항 명세 (실측 데이터 기반) |
| `report_outline.md` | 보고서 아웃라인 |
| `aihub_data_guide.md` | AI-Hub 외부 데이터 수집·통합 가이드 |
| `team_questions.md` | 팀 질문지 · 이슈 트래킹 |
| `최종발표자료임.pdf` | 최종 발표자료 (28슬라이드) |

> `models/`, `utils/`, `main.py`는 레포 초기 Git 협업 실습(MNIST 분류) 단계의 스캐폴드이며, 실제 알약 탐지 프로젝트에는 사용되지 않습니다.

---

## 실행 방법

핵심 모델은 노트북(`RetinaNet_ResNet50_FPN_v2_final.ipynb`)으로 학습·평가합니다.

```bash
# 1. 저장소 복제
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 2. 패키지 설치 (가상환경 권장)
pip install -r requirements.txt

# 3. RetinaNet_ResNet50_FPN_v2_final.ipynb 실행
#    (대회 데이터 + AI-Hub 확장 데이터 경로 설정 후 셀 순서대로 실행)
```

---

## 모델 실험 결과

| 모델 | 데이터 기준 | Local mAP@[0.75:0.95] | Kaggle Public Score | 비고 |
| --- | --- | --- | --- | --- |
| SSD300 + VGG16 | 232장 | 0.4150 | 0.08645 ~ 0.12368 | baseline, top-4 강제 출력 버그 있었음 |
| **RetinaNet ResNet50-FPN v2** | 232장 | — | **0.35127** | **최종 채택, 현재 최고점** |
| Faster R-CNN ResNet50-FPN v2 | 232장 | — | 0.30818 | |
| Faster R-CNN ResNet50-FPN v2 | 3,730장 / 118클래스 (통제실험 Case 2) | — | 0.48821 | 데이터 확장 효과 검증 |
| RTMDet-l | 8,068장 후보군 | 0.506 | — | |
| YOLO26S | 118클래스 전체 | 0.986 | — | validation split이 이미지 단위라 near-duplicate leakage 가능성 있어 최종 성능 지표로 미채택 |

8,068장 확장 데이터 기준 RetinaNet·YOLO 재학습은 GPU 자원 제약으로 마감 전 완료하지 못했으며, 검증되지 않은 수치 대신 위 표의 검증된 결과를 최종으로 보고합니다.

---

## 협업 내용

### 역할

| 팀원 | 역할 | 담당 |
| --- | --- | --- |
| 김혜린 | 팀장 · PM | 일정 관리, RetinaNet 모델, 데이터·모델 검증, 보고서 작성 |
| 강인호 | Data Engineer | EDA, 데이터 전처리 · 라벨링, 통제 실험 설계 |
| 유영관 | Model Architect | AI-Hub 데이터 확장 파이프라인, RTMDet 모델 개발 |
| 최순우 | (중도 하차) | 원래 실험 · 평가 · 제출 담당, 이후 위 3인이 공동 분담 |
| 문상준 | 멘토 | — |

### 브랜치 전략

`main` 보호 + `feature/*` 브랜치 + Pull Request + Squash 병합(GitHub Flow)을 기본으로 하되, 실험 성격의 대규모 작업은 `feat/*` · `fix/*` 브랜치에서 진행 후 팀 검토를 거쳐 병합합니다.

### PR 작성 규칙

PR 제목·본문에 아래 세 가지를 적습니다.

| 항목 | 내용 |
| --- | --- |
| 작업 내용 | 무엇을 바꿨는지 |
| 구현한 기능 | 새로 추가/개선된 기능 |
| 테스트 결과 | 실행 명령과 mAP · Public Score 등 결과 |

### 규칙

- `main` 직접 push 금지 — 반드시 PR로 병합
- 병합 방식은 Squash and merge
- 충돌이 나면 브랜치에서 `git pull origin main` 후 해결하고 다시 push

---

## 제출물

| 산출물 | 링크 |
| --- | --- |
| 분석 보고서 / 발표자료 PDF | [`docs/최종발표자료임.pdf`](docs/최종발표자료임.pdf) |
| 팀 협업일지(Daily Log, 전체) | [Notion](https://app.notion.com/p/73e3cd573ab04a9ca92d7ee967791205) |
| 개인 협업일지 · 김혜린 | [Notion](https://app.notion.com/p/3d8ec9abc7d6815aa7b6c9efae600a1c) |
| 개인 협업일지 · 강인호 | [Notion](https://app.notion.com/p/3d8ec9abc7d681919933fd2d44822175) |
| 개인 협업일지 · 유영관 | [Notion](https://app.notion.com/p/3d8ec9abc7d6811ab93fca2c40aedade) |

---

## 라이선스

[MIT](LICENSE)
