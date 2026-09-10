# 초급 팀 프로젝트 — MNIST 이미지 분류

Git · GitHub 협업을 처음 하는 팀이 **같은 저장소 · 같은 규칙**으로
하나의 딥러닝 프로젝트를 완성하는 실습 저장소입니다.
기준 예제: [Sprint-Seokmin/sprint-ai-ex](https://github.com/Sprint-Seokmin/sprint-ai-ex)

---

## 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| 목적 | 각 팀원이 `feature/*` 브랜치에서 전처리 · 증강 · 모델링을 나눠 맡고, PR 리뷰를 거쳐 `main` 에 병합한다 |
| 데이터셋 | MNIST (손글씨 숫자 0–9, 1×28×28) — 실행 시 `data/` 에 자동 다운로드 |
| 주요 기능 | 모델 선택 학습/평가(`main.py`), 전처리 파이프라인, 데이터 증강, 3종 모델(From Scratch · VGGNet · ResNet) |
| 협업 방식 | GitHub Flow — `main` 보호 + `feature/*` 브랜치 + Pull Request + Squash 병합 |

---

## 폴더 구조

```
beginner-team-project/
├── main.py                  학습·평가 진입점 (--model 로 모델 선택)
├── requirements.txt         torch, torchvision
├── data/                    MNIST 저장 위치 (git 제외)
├── models/
│   ├── mlp.py               기준 베이스라인 (바로 학습됨)
│   ├── from_scratch.py      팀원 C — feature/model-fromscratch
│   ├── vggnet.py            팀원 D — feature/model-vggnet
│   └── resnet.py            팀원 E — feature/model-resnet
└── utils/
    ├── data_loader.py       MNIST DataLoader
    ├── preprocessing.py     팀원 A — feature/preprocessing
    └── augmentation.py      팀원 B — feature/augmentation
```

---

## 실행 방법

```bash
# 1. 저장소 복제
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 2. 패키지 설치 (가상환경 권장)
pip install -r requirements.txt

# 3. 학습 + 평가
python main.py                      # 베이스라인(MLP), 5 epochs
python main.py --model mlp --epochs 3
python main.py --model resnet --augment
```

> `models/mlp.py` 만 바로 학습됩니다. `from_scratch` · `vggnet` · `resnet` 은
> 담당 팀원이 구현을 채우기 전까지 `NotImplementedError` 를 냅니다.

---

## 모델 설명 및 결과

| 모델 | 담당 | 구현 내용 | Test Accuracy |
| --- | --- | --- | --- |
| SimpleMLP (베이스라인) | — | FC(784→128) → ReLU → FC(128→10) | _채우기_ |
| From Scratch CNN | 팀원 C | _Conv/Pool/FC 직접 구성_ | _채우기_ |
| VGGNet | 팀원 D | _3×3 Conv 반복 + MaxPool_ | _채우기_ |
| ResNet | 팀원 E | _잔차 블록 스택_ | _채우기_ |

---

## 협업 내용

### 역할 · 브랜치

| 팀원 | 역할 | 브랜치 |
| --- | --- | --- |
| _이름_ | 데이터 전처리 파이프라인 개선 | `feature/preprocessing` |
| _이름_ | 데이터 증강 기능 추가 | `feature/augmentation` |
| _이름_ | 모델링 – From Scratch | `feature/model-fromscratch` |
| _이름_ | 모델링 – VGGNet | `feature/model-vggnet` |
| _이름_ | 모델링 – ResNet | `feature/model-resnet` |

> 팀원 수가 5명보다 적으면 한 사람이 여러 역할을 맡습니다.

### 작업 흐름

```bash
# 1. main 최신화 후 feature 브랜치 생성
git switch main && git pull
git switch -c feature/preprocessing

# 2. 작업 → 커밋 → 푸시
git add .
git commit -m "Implement 전처리 feature"
git push -u origin feature/preprocessing

# 3. GitHub 에서 PR 생성 → 리뷰 → Approve → Squash 병합
# 4. 병합된 브랜치 정리
git switch main && git pull
git branch -d feature/preprocessing
```

### PR 작성 규칙

PR 제목·본문에 아래 세 가지를 적습니다.

- **작업 내용** — 무엇을 바꿨는지
- **구현한 기능** — 새로 추가/개선된 기능
- **테스트 결과** — 실행 명령과 정확도 등 간단한 결과

### 규칙

- `main` 직접 push 금지 — 반드시 PR 로 병합
- 병합 방식은 **Squash and merge**
- 충돌이 나면 브랜치에서 `git pull origin main` 후 해결하고 다시 push

---

## 라이선스

[MIT](LICENSE)
