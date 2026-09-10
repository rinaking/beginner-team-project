# 초급 팀 프로젝트

> Git · GitHub 협업을 처음 시작하는 팀이 함께 쓰는 공동 저장소.

강의 **Git/Github (1)** 에서 배운 범위 — 브랜치, Pull Request, 병합, `.gitignore` — 만으로
하나의 프로젝트를 완성하는 것을 목표로 합니다.

---

## 개요

| 항목 | 내용 |
| --- | --- |
| 목적 | 팀원 전원이 **같은 규칙**으로 브랜치를 나눠 작업하고, Pull Request 로 합친다 |
| 대상 | Git · GitHub 를 이제 막 시작한 팀원 |
| 범위 | 저장소 복제 → 브랜치 → 커밋 → Push → Pull Request → 병합 → 충돌 해결 |
| 제외 | 별도 빌드 도구 · 패키지 설정 · 자동화(CI)는 쓰지 않는다 (강의 범위 밖) |

프로젝트의 구체적인 주제와 기능은 팀에서 정합니다. 이 저장소는 **협업의 뼈대**만 제공합니다.

---

## 시작하기

```bash
# 1. 저장소 복제
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 2. 최초 1회, 본인 정보 설정 (이미 했다면 생략)
git config --global user.name  "본인 이름"
git config --global user.email "GitHub 이메일"
```

---

## 협업 방법

`main` 은 항상 정상 동작하는 상태로 두고, 모든 작업은 별도 브랜치에서 합니다.

```text
main 최신화 → 작업 브랜치 생성 → 작업 · 커밋 → Push → Pull Request → 리뷰 → 병합 → 브랜치 삭제
```

```bash
git switch main && git pull origin main      # 1. main 최신화
git switch -c feat/기능이름                    # 2. 작업 브랜치 생성
#    ... 작업 ...
git add . && git commit -m "feat: 변경 내용"  # 3. 커밋
git push -u origin feat/기능이름               # 4. Push
#    5. GitHub 에서 Pull Request 생성 → 리뷰 → 병합
git switch main && git pull                   # 6. 병합분 내려받기
git branch -d feat/기능이름                    # 7. 로컬 브랜치 정리
```

---

## 브랜치 · 커밋 규칙

**브랜치 이름** — `<타입>/<요약>` (소문자, 하이픈으로 구분)

| 타입 | 용도 | 예 |
| --- | --- | --- |
| `feat` | 기능 추가 | `feat/login-form` |
| `fix` | 버그 수정 | `fix/typo-header` |
| `docs` | 문서 | `docs/update-readme` |

**커밋 메시지** — `<타입>: <무엇을 왜 바꿨는지>` 를 한 줄로, 명령형으로.

```text
feat: 회원가입 폼에 이메일 형식 검사 추가
```

- 커밋은 의미 단위로 자주 남깁니다.
- `main` 에 직접 커밋하거나 `git push --force` 하지 않습니다.

---

## Pull Request

1. 제목은 브랜치의 목적이 드러나게 씁니다.
2. 본문에 **바꾼 내용**과 **확인 방법**을 적습니다.
3. 팀원 **1명 이상**에게 리뷰를 요청합니다.
4. 대화가 모두 해결되면 **Squash and merge** 로 병합하고 브랜치를 삭제합니다.
5. 충돌이 나면 `main` 을 브랜치로 가져와 해결한 뒤 다시 Push 합니다.

```bash
git switch feat/기능이름
git merge main        # 충돌 표시 부분을 직접 수정
git add . && git commit
git push
```

---

## 팀

| 이름 | GitHub | 역할 |
| --- | --- | --- |
| 김혜린 | [@rinaking](https://github.com/rinaking) | 팀장 · 저장소 · 병합 관리 |
| 강인호 | [@Inhoooooo](https://github.com/Inhoooooo) | 팀원 |
| 유영관 | [@TheMostEvident](https://github.com/TheMostEvident) | 팀원 |

> 담당 파일이 서로 겹치지 않도록 나눕니다. 겹치면 충돌이 납니다.

---

## 라이선스

[MIT](LICENSE) © 2026 초급 팀 프로젝트
