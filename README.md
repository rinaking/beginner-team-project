<div align="center">

# [초급] 팀 프로젝트

**Git · GitHub 협업을 처음 하는 팀이 함께 쓰는 기준 저장소**

![python](https://img.shields.io/badge/python-3.13-3776AB?logo=python&logoColor=white)
![env](https://img.shields.io/badge/env-conda-44A833?logo=anaconda&logoColor=white)
![workflow](https://img.shields.io/badge/workflow-GitHub%20Flow-181717?logo=github&logoColor=white)
![license](https://img.shields.io/badge/license-MIT-green)

</div>

---

## 📋 목차

- [프로젝트 개요](#-프로젝트-개요)
- [빠른 시작](#-빠른-시작)
- [프로젝트 구조](#-프로젝트-구조)
- [협업 방법](#-협업-방법)
- [브랜치 · 커밋 규칙](#-브랜치--커밋-규칙)
- [Pull Request 규칙](#-pull-request-규칙)
- [문서](#-문서)
- [팀](#-팀)
- [라이선스](#-라이선스)

---

## 🎯 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| **목적** | Git·GitHub 을 처음 쓰는 팀원들이 **같은 환경, 같은 규칙**으로 하나의 프로젝트를 완성한다 |
| **대상** | Git·GitHub 경험이 거의 없는 팀원 |
| **얻는 것** | 브랜치 기반 협업 · Pull Request 리뷰 · 충돌 해결 · 재현 가능한 개발 환경 |
| **진행 방식** | `main` 보호 + `feature/*` 브랜치 + PR 리뷰 1인 승인 + Squash 병합 |

> 프로젝트의 구체적 주제·기능은 팀에서 정합니다. 이 저장소는 **협업의 뼈대**를 제공합니다.

---

## 🚀 빠른 시작

### 1. 사전 준비 (한 번만)

| 프로그램 | 받는 곳 |
| --- | --- |
| Git | Windows [git-scm.com/download/win](https://git-scm.com/download/win) · macOS 터미널에서 `git --version` |
| Miniforge (conda) | [github.com/conda-forge/miniforge](https://github.com/conda-forge/miniforge) |
| VS Code | [code.visualstudio.com](https://code.visualstudio.com) |

```bash
git config --global user.name  "본인 이름"
git config --global user.email "GitHub 이메일"
git config --global core.autocrlf input   # Windows 는 true
```

### 2. 저장소 받기 + 환경 구성

```bash
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project
conda env create -f environment.yml
conda activate beginner-team-project
```

### 3. 정상 동작 확인

```bash
python -m src        # "초급 팀 프로젝트 준비 완료" 출력
pytest -q            # 테스트 통과
```

> ✅ 위 두 명령이 오류 없이 끝나면 준비 완료입니다.

---

## 📁 프로젝트 구조

```text
beginner-team-project/
├── README.md                     이 문서
├── LICENSE                       MIT
├── CONTRIBUTING.md               기여 방법 (요약)
├── CHANGELOG.md                  변경 이력
├── environment.yml               conda 환경 정의 (의존성 단일 소스)
├── .env.example                  환경 변수 키 목록 (값은 .env 에, 커밋 금지)
├── .gitignore / .gitattributes / .editorconfig
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md  PR 본문 서식
│   ├── CODEOWNERS                기본 리뷰어
│   └── ISSUE_TEMPLATE/           버그 · 기능 요청 양식
├── docs/
│   ├── README.md                 문서 색인
│   ├── 협업-가이드.md            팀원용 — 개념부터 실전까지
│   └── 팀장-가이드.md            팀장용 — 저장소 구축 + 운영
├── src/                          소스 코드
└── tests/                        테스트
```

---

## 🤝 협업 방법

**브랜치 전략: GitHub Flow** — `main` 은 항상 정상 동작, 모든 작업은 `feature/*` 브랜치 → PR.

```text
main 최신화 → feature 브랜치 생성 → 작업 · 커밋 → push → PR 생성
→ 리뷰 1인 승인 → Squash 병합 → 브랜치 삭제 → 다시 처음
```

각 단계의 명령·화면은 **[docs/협업-가이드.md](docs/협업-가이드.md)** 4장에 있습니다. Git 이 처음이면 1장부터 읽으세요.

---

## 🌿 브랜치 · 커밋 규칙

**브랜치명** — `<타입>/<요약>` (소문자·하이픈)

| 타입 | 용도 | 예 |
| --- | --- | --- |
| `feat` | 기능 추가 | `feat/data-loader` |
| `fix` | 버그 수정 | `fix/login-error` |
| `docs` | 문서 | `docs/readme-badge` |
| `refactor` `test` `chore` | 정리 · 테스트 · 잡일 | |

**커밋 메시지** — [Conventional Commits](https://www.conventionalcommits.org/ko/)

```text
<타입>: <무엇을 왜 바꿨는지 — 명령형, 72자 이내>
```

예: `feat: CSV 로더에 결측치 보간 옵션 추가`

- 커밋은 **의미 단위로 자주**. 하루치를 한 커밋에 몰지 않습니다.
- `main` 직접 push 금지 · `git push --force` 금지.

---

## ✅ Pull Request 규칙

1. PR 본문에 **작업 내용 · 구현한 기능 · 테스트 결과** (템플릿이 자동으로 뜹니다)
2. 리뷰어 **1명 이상** 지정 — 리뷰 요청은 24시간 내 응답
3. **승인 1개 + 검사 통과 + 대화 해결** → **Squash and merge** → **Delete branch**
4. 본인 PR은 본인이 승인할 수 없습니다
5. 병합 후 로컬 정리: `git switch main && git pull && git branch -d <브랜치>`

---

## 📚 문서

| 문서 | 대상 | 내용 |
| --- | --- | --- |
| [docs/협업-가이드.md](docs/협업-가이드.md) | 팀원 전원 | 개념 → 준비 → 첫걸음 → 작업 사이클 → 충돌 → 규칙 → GitHub 기능 → 부록(명령어·오류·용어·Fork) |
| [docs/팀장-가이드.md](docs/팀장-가이드.md) | 팀장 | 저장소 구축(Rulesets·Collaborators·PR 템플릿) · 스프린트 운영 · 코드 리뷰 · 함정 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 기여자 | 작업 흐름 요약 |

---

## 👥 팀

| 이름 | GitHub | 역할 | 담당 |
| --- | --- | --- | --- |
| (팀장) | @rinaking | 저장소·일정·병합 관리 | 전체 조율 |
| | | | |
| | | | |
| | | | |
| | | | |

> 담당 파일·폴더가 서로 겹치지 않도록 나눕니다 (겹치면 충돌).

---

## 📄 라이선스

[MIT](LICENSE) © 2026
