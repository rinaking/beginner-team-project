<div align="center">

# 초급 팀 프로젝트

Git · GitHub 협업을 처음 하는 팀이 같은 환경과 같은 규칙으로 하나의 결과물을 만드는 기준 저장소

[![python](https://img.shields.io/badge/python-3.13-3776AB?logo=python&logoColor=white)](environment.yml)
[![env](https://img.shields.io/badge/env-conda-44A833?logo=anaconda&logoColor=white)](environment.yml)
[![workflow](https://img.shields.io/badge/workflow-GitHub%20Flow-181717?logo=github&logoColor=white)](#협업-흐름)
[![license](https://img.shields.io/badge/license-MIT-informational)](LICENSE)

</div>

---

## 목차

| 시작하기 | 협업 규칙 | 참고 |
| --- | --- | --- |
| [개요](#개요) · [빠른 시작](#빠른-시작) · [저장소 구조](#저장소-구조) | [협업 흐름](#협업-흐름) · [브랜치 · 커밋](#브랜치--커밋-규칙) · [Pull Request](#pull-request-규칙) | [문서](#문서) · [팀](#팀) · [라이선스](#라이선스) |

---

## 개요

| 항목 | 내용 |
| --- | --- |
| **목적** | 팀원 전원이 동일한 개발 환경에서, 브랜치와 Pull Request 로만 협업해 하나의 프로젝트를 완성한다 |
| **대상** | Git · GitHub 실무 경험이 적은 팀원 |
| **다루는 것** | 재현 가능한 개발 환경 · 브랜치 기반 작업 · PR 리뷰 · 병합 · 충돌 해결 |
| **운영 방식** | `main` 보호 · `feature/*` 브랜치 · PR 리뷰 1인 승인 · Squash 병합 |

> 프로젝트의 주제와 기능은 팀에서 정합니다. 이 저장소는 그 위에서 협업할 **뼈대**만 제공합니다.

---

## 빠른 시작

### 1. 도구 설치 — 한 번만

| 도구 | 설치 |
| --- | --- |
| Git | [git-scm.com/downloads](https://git-scm.com/downloads) |
| Miniforge (conda) | [github.com/conda-forge/miniforge](https://github.com/conda-forge/miniforge) |
| VS Code | [code.visualstudio.com](https://code.visualstudio.com) |

```bash
git config --global user.name  "본인 이름"
git config --global user.email "GitHub 가입 이메일"
git config --global core.autocrlf input   # Windows 는 true
```

### 2. 저장소와 환경 준비

```bash
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project
conda env create -f environment.yml
conda activate beginner-team-project
```

### 3. 동작 확인

```bash
python -m src        # → 초급 팀 프로젝트 준비 완료
pytest -q            # → 테스트 통과
ruff check .         # → 린트 통과
```

세 명령이 오류 없이 끝나면 환경 구성이 끝난 것입니다. 이후 작업은 [협업 흐름](#협업-흐름)을 따릅니다.

---

## 저장소 구조

```text
beginner-team-project/
├── src/                     소스 코드
├── tests/                   테스트
├── docs/                    협업 문서 (색인: docs/README.md)
├── environment.yml          conda 환경 정의 — 의존성의 단일 소스
├── pyproject.toml           패키지 · 도구(ruff · pytest) 설정
├── .env.example             환경 변수 키 목록 (실제 값은 .env, 커밋 금지)
├── CONTRIBUTING.md          작업 흐름 요약
├── CHANGELOG.md             변경 이력
├── LICENSE                  MIT
└── .github/
    ├── PULL_REQUEST_TEMPLATE.md   PR 본문 서식
    ├── CODEOWNERS                 기본 리뷰어 지정
    └── ISSUE_TEMPLATE/            버그 · 기능 요청 양식
```

---

## 협업 흐름

브랜치 전략은 **GitHub Flow** 입니다. `main` 은 항상 정상 동작 상태로 두고, 모든 변경은 `feature/*` 브랜치에서 작업한 뒤 Pull Request 로 합칩니다.

```text
main 최신화  →  feature 브랜치 생성  →  작업 · 커밋  →  push  →  PR 생성
     ↑                                                              │
     └──────  브랜치 삭제  ←  Squash 병합  ←  리뷰 1인 승인  ←──────┘
```

각 단계의 명령과 화면은 [docs/협업-가이드.md](docs/협업-가이드.md) 4장에 정리돼 있습니다.

---

## 브랜치 · 커밋 규칙

**브랜치 이름** — `<타입>/<요약>` · 소문자와 하이픈만 사용

| 타입 | 용도 | 예 |
| --- | --- | --- |
| `feat` | 기능 추가 | `feat/data-loader` |
| `fix` | 버그 수정 | `fix/login-error` |
| `docs` | 문서 | `docs/readme-badge` |
| `refactor` · `test` · `chore` | 정리 · 테스트 · 잡일 | `chore/update-deps` |

**커밋 메시지** — [Conventional Commits](https://www.conventionalcommits.org/ko/)

```text
<타입>: <무엇을 왜 바꿨는지 — 명령형, 72자 이내>

예) feat: CSV 로더에 결측치 보간 옵션 추가
```

- 커밋은 의미 단위로 자주 남깁니다. 하루치 작업을 한 커밋에 몰지 않습니다.
- `main` 직접 push 와 `git push --force` 는 금지합니다.

---

## Pull Request 규칙

1. PR 본문에 **작업 내용 · 구현한 기능 · 테스트 결과** 를 적습니다. (템플릿이 자동으로 채워집니다.)
2. 리뷰어를 **1명 이상** 지정하고, 리뷰 요청에는 24시간 안에 응답합니다.
3. **승인 1개 + 로컬 검사(`ruff check .` · `pytest`) 통과 + 대화 해결** → **Squash and merge** → **Delete branch**.
4. 본인 PR 은 본인이 승인할 수 없습니다.
5. 병합 뒤 로컬을 정리합니다. `git switch main && git pull && git branch -d <브랜치>`

---

## 문서

전체 색인은 [docs/README.md](docs/README.md) 에 있습니다.

| 문서 | 대상 | 내용 |
| --- | --- | --- |
| [github-처음-안내](docs/github-처음-안내.md) | GitHub 무경험 팀원 | Git 과 GitHub 의 차이, 설치, 계정, 첫 PR |
| [협업-가이드](docs/협업-가이드.md) | 팀원 전원 | 개념 → 준비 → 작업 사이클 → 충돌 해결 → 규칙 → 부록(명령어 · 오류 · 용어 · Fork) |
| [팀장-가이드](docs/팀장-가이드.md) | 팀장 | 저장소 구축(Rulesets · Collaborators) · 스프린트 운영 · 코드 리뷰 |
| [github-활용-지침서](docs/github-활용-지침서.md) | 전원 (참고) | Git 명령과 GitHub 웹 기능 상세, GUI 툴 |
| [CONTRIBUTING](CONTRIBUTING.md) | 기여자 | 작업 흐름 요약 |

---

## 팀

| 이름 | GitHub | 역할 |
| --- | --- | --- |
| 김혜린 (팀장) | [@rinaking](https://github.com/rinaking) | 저장소 · 일정 · 병합 관리, 전체 조율 |
| _미정_ | | |

> 팀원은 위 표에 한 줄씩 추가합니다. 담당 파일과 폴더가 서로 겹치지 않게 나눠야 병합 충돌을 줄일 수 있습니다.

---

## 라이선스

[MIT](LICENSE) © 2026 beginner-team-project contributors
