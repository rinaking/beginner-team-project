# Health Eat — 경구약제 이미지 객체 탐지

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)
![PyTorch](https://img.shields.io/badge/PyTorch-torchvision-orange.svg)
![Kaggle](https://img.shields.io/badge/Kaggle-Private%20Competition-20BEFF.svg)
![Best Score](https://img.shields.io/badge/Public%20Score-0.35127-brightgreen.svg)

사용자가 촬영한 알약 사진 한 장에서 최대 4개 약제의 종류(class)와 위치(bounding box)를 함께 인식하는 Object Detection 프로젝트입니다. 코드잇 AI 엔지니어링 14기 2팀이 Kaggle Private Competition(`ai14-level-project`)에 참가하며 진행했습니다.

| | |
| --- | --- |
| **최종 모델** | YOLO26s |
| **Kaggle 리더보드 최고 Public Score** | 0.35127 (RetinaNet ResNet50-FPN v2 제출 기준) |
| **평가 지표** | mAP@[0.75:0.95] |
| **데이터 규모** | 232장 → 10,732장 (AI-Hub 확장) |
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

> **최종 모델 YOLO26s** — Local mAP 0.986~0.988 (validation 한계로 일반화 성능으로는 해석하지 않음), NMS-Free End-to-End 구조·학습 안정성·배포 용이성을 근거로 최종 채택. Kaggle 리더보드 최고 Public Score는 0.35127(RetinaNet ResNet50-FPN v2 제출 기준).

| 발견 | 내용 |
| --- | --- |
| 데이터 확장 | 원본 232장 → AI-Hub 통합으로 10,732장까지 확장. 통제 실험으로 "데이터 양보다 클래스 다양성이 3배 이상 기여"함을 정량 검증 |
| 파이프라인 버그 | 로컬 mAP와 Kaggle Public Score 사이의 이상한 격차를 추적해 제출 파이프라인의 top-4 강제 출력 버그를 발견·수정 |
| YOLO26 최종 채택 | mAP 수치만이 아니라 작은 알약 탐지(STAL + Multi-scale)·후처리 단순화(NMS-Free End-to-End)·서비스 연동(ProgLoss·MuSGD·DFL-free)까지 함께 고려해 최종 모델로 선택. Local mAP 0.986~0.988은 validation 한계로 일반화 성능으로는 해석하지 않음 |

자세한 과정은 [모델 실험 결과](#모델-실험-결과)와 [`docs/최종발표자료임.pdf`](docs/최종발표자료임.pdf)를 참고하세요.

---

## 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| 목표 | 알약 이미지 1장당 최대 4개 객체의 class + bounding box 검출 |
| 데이터셋 | 대회 제공 232장(56클래스) + AI-Hub 외부 데이터로 확장한 10,732장 |
| 평가 지표 | mAP@[0.75:0.95] (Kaggle Private Leaderboard) |
| 주요 모델 | SSD300+VGG16(baseline), RetinaNet ResNet50-FPN v2(Kaggle 리더보드 최고 Public Score), Faster R-CNN ResNet50-FPN v2, RTMDet-l, **YOLO26s(최종 채택)** |
| 팀 구성 | 김혜린(PM · RetinaNet), 강인호(Data · 서비스 앱), 유영관(Model · YOLO26s), 최순우(중도 하차), 멘토 문상준 |

---

## 폴더 구조

```
beginner-team-project/
├── YOLO26_AIHub_Pill_Detection_RTX5060.ipynb         최종 채택 모델 (YOLO26s)
├── RetinaNet_ResNet50_FPN_v2_final.ipynb             Kaggle 리더보드 최고 Public Score 제출 모델
├── RFDETR_XLarge_AIHub_Pill_Detection_RTX5060.ipynb  추가 실험 모델
├── 최초 모델링.ipynb                                  SSD300+VGG16 baseline
├── application/                                      실제 서비스 데모 (FastAPI 백엔드 + Flutter 모바일 앱)
├── bbox_tightening.py                                bbox 품질 검증·보정 도구
├── docs/                                             보고서 · 가이드 · 발표자료
├── models/ utils/ main.py                            초기 Git 협업 실습용 스캐폴드 (본 프로젝트 코드 아님)
└── .github/ISSUE_TEMPLATE/                           문서 · 버그 · 실험 이슈 템플릿
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

최종 채택 모델은 노트북(`YOLO26_AIHub_Pill_Detection_RTX5060.ipynb`)으로 학습·평가합니다. Kaggle 리더보드 제출에 사용된 모델은 `RetinaNet_ResNet50_FPN_v2_final.ipynb`를 참고하세요.

```bash
# 1. 저장소 복제
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 2. 패키지 설치 (가상환경 권장)
pip install -r requirements.txt

# 3. YOLO26_AIHub_Pill_Detection_RTX5060.ipynb 실행
#    (대회 데이터 + AI-Hub 확장 데이터 경로 설정 후 셀 순서대로 실행)
```

---

## 모델 실험 결과

| 모델 | 백본(Backbone) | 주요 결과 (mAP@0.75:0.95) | 비고 |
| --- | --- | --- | --- |
| SSD300 | VGG16 | 0.5637 (local) | Baseline |
| RetinaNet | ResNet50-FPN | 0.35127 (public) | 분류형/멀티스케일 |
| Faster R-CNN | ResNet50-FPN v2 | 0.7986 (local) | 2-stage 비교 |
| RTMDet-l | RTMDet | 0.506 (local) | 다른 one-stage |
| **YOLO26s** | YOLO26 | **0.986~0.988 (local)** | Validation 한계로 일반화 성능으로 해석 X |

> 다양한 모델을 비교하고, 데이터 특성에 맞는 최적의 모델을 선택했습니다. 공개/로컬 점수를 모두 고려하여 신뢰할 수 있는 성능을 분석했고, 단순한 수치가 아닌 실제 서비스 환경을 고려한 성능을 평가하여 **최종적으로 YOLO26s를 프로젝트의 핵심 모델로 선택**했습니다.

### 왜 YOLO26을 최종 모델로 선택했는가

프로젝트에서 실제로 관찰한 탐지 문제를 모델 설계 요소에 연결해 최종 모델을 정했습니다.

| 관찰 | 설계(Design) | 내용 |
| --- | --- | --- |
| Small / Multi-scale Objects | STAL + Multi-scale | 작은 알약에 학습 신호를 더 주는 라벨 할당(STAL)과 다중 스케일 특징 활용 |
| Post-processing Simplicity | NMS-Free End-to-End | NMS 없이 최종 결과를 바로 출력해 후처리 단계를 단순화 |
| Training Stability / Deployment | ProgLoss · MuSGD · DFL-free | 안정적인 학습과 가벼운 헤드로 서비스 배포 · 연동에 유리 |

> YOLO26은 mAP 수치만이 아니라, 작은 알약 탐지 · 후처리 단순화 · 서비스 연동까지 함께 고려해 선택했습니다. SSD300 · RetinaNet · Faster R-CNN · RTMDet과 비교한 실험 결과를 바탕으로 최종 모델로 선정했습니다.

---

## 협업 내용

### 역할

| 팀원 | 역할 | 담당 |
| --- | --- | --- |
| 김혜린 | 팀장 · PM | 일정 관리, RetinaNet 모델, 데이터·모델 검증, 보고서 작성 |
| 강인호 | Data Engineer | EDA, 데이터 전처리 · 라벨링, 통제 실험 설계, 실제 서비스 앱(FastAPI 백엔드 + Flutter 모바일) 개발 |
| 유영관 | Model Architect | AI-Hub 데이터 확장 파이프라인, RTMDet·YOLO26s(최종 채택) 모델 개발 |
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
