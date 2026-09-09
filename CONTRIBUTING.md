# 기여 방법

환경 준비는 [README 빠른 시작](README.md#-빠른-시작), 자세한 규칙은 [docs/협업-가이드.md](docs/협업-가이드.md).

## 작업 흐름

1. `main` 최신화 후 브랜치 생성
   ```bash
   git switch main && git pull origin main
   git switch -c feat/xxx
   ```
2. 작업 → 로컬 검사 (`ruff check .`, `pytest`)
3. 의존성을 바꿨으면 `environment.yml` 수정 + `conda env update -f environment.yml --prune`, 커밋에 포함
4. `git push -u origin feat/xxx` → GitHub 에서 PR 생성 (`gh pr create --fill --web` 도 가능)
5. CI 통과 + 리뷰 1인 승인 → **Squash and merge** → 병합 후 `git branch -d feat/xxx`

## 커밋 메시지

Conventional Commits: `feat:` `fix:` `docs:` `refactor:` `test:` `chore:`

## 보고

버그·제안은 [Issues](../../issues) 에 템플릿으로 등록합니다.
