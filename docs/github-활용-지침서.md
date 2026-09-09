# GitHub 활용 지침서 (2팀)

> Git 명령과 GitHub 기능을 실무에서 어떻게 쓰는지 정리한 참고서입니다.
> 처음이라면 [github-처음-안내.md](github-처음-안내.md) 부터. 팀 규칙은 [협업-가이드.md](협업-가이드.md).

---

## PART 1. Git 명령 활용

### 1.1 브랜치

| 목적 | 명령 |
| --- | --- |
| 목록 보기 | `git branch` (현재 브랜치 앞에 `*`) |
| 원격까지 보기 | `git branch -a` |
| 생성 + 이동 | `git switch -c feature/x` (= `git checkout -b feature/x`) |
| 이동만 | `git switch feature/x` |
| 직전 브랜치로 | `git switch -` |
| 이름 변경 | `git branch -m 새이름` |
| 삭제 (병합됨) | `git branch -d feature/x` |
| 강제 삭제 (미병합) | `git branch -D feature/x` — 미병합 커밋이 사라짐, 신중히 |
| 원격 브랜치 삭제 | `git push origin --delete feature/x` |

> 병합이 끝난 feature 브랜치는 로컬도 지워 저장소를 깔끔하게 유지합니다.

### 1.2 커밋 다루기

| 상황 | 명령 |
| --- | --- |
| 방금 커밋 메시지만 고침 | `git commit --amend -m "새 메시지"` (아직 push 안 했을 때만) |
| 커밋 전 변경 되돌리기 | `git restore <파일>` |
| 특정 시점 파일로 | `git restore --source <커밋해시> <파일>` |
| 최근 커밋 취소 (변경은 유지) | `git reset --soft HEAD^` |
| 최근 커밋 취소 (변경 작업폴더로) | `git reset --mixed HEAD^` |
| 최근 커밋 + 변경 전부 삭제 | `git reset --hard HEAD^` — 복구 어려움, 정말 확실할 때만 |
| 이미 push한 커밋을 되돌림 | `git revert <해시>` — "되돌리는 새 커밋"을 만든다. 공유 브랜치엔 이것 |

> 핵심: **내 반자기에만 있는 커밋 = reset OK. 남이 이미 받은 커밋 = revert.**

### 1.3 병합 및 충돌

**Fast-forward vs 3-way**

- Fast-forward: 갈라진 이후 `main` 에 새 커밋이 없으면, 포인터만 앞으로 — 깔끔.
- 3-way merge: 양쪽이 각자 진행했으면 "병합 커밋"을 만든다 — 충돌 가능.

**충돌 해결 전체 절차**

```bash
git switch feature/x
git fetch origin
git merge origin/main        # 또는 git pull origin main
# CONFLICT (content): Merge conflict in <파일>
```

1. 충돌 파일을 VS Code 로 열면:

   ```text
   <<<<<<< HEAD
   내 브랜치 내용
   =======
   main 쪽 내용
   >>>>>>> origin/main
   ```

2. **최종적으로 맞는 코드만 남기고** `<<<<<<<` `=======` `>>>>>>>` 세 줄을 모두 삭제 (VS Code 버튼: Accept Current / Incoming / Both).
3. 애매하면 임의로 지우지 말고 담당 팀원과 논의.
4. `git add <파일>` → `git commit` → `git push`.
5. 중단하려면 `git merge --abort`.

**충돌 예방**

- 담당 파일을 나눠 겹치지 않게
- 작업 전 항상 `git pull origin main`
- 브랜치를 오래 방치하지 않기 (하루·이틀 안에 PR)

### 1.4 태그 (릴리스 지점 표시)

| 목적 | 명령 |
| --- | --- |
| 간단 태그 | `git tag v1.0` |
| 설명 붙은 태그 (권장) | `git tag -a v1.0 -m "첫 릴리스"` |
| 목록 | `git tag` |
| 하나 push | `git push origin v1.0` |
| 전부 push | `git push origin --tags` |
| 삭제 (로컬/원격) | `git tag -d v1.0` / `git push origin --delete v1.0` |

### 1.5 원격 저장소

| 목적 | 명령 |
| --- | --- |
| 등록 확인 | `git remote -v` |
| 추가 | `git remote add origin <URL>` |
| 주소 교체 | `git remote set-url origin <새 URL>` |
| 이름 변경 / 삭제 | `git remote rename old new` / `git remote remove origin` |

- **HTTPS**: 매번 로그인/토큰. 처음엔 이게 간편.
- **SSH**: 키를 한 번 등록하면 인증 생략. 자주 쓰면 나중에 설정.

**push / pull / fetch**

| 명령 | 하는 일 |
| --- | --- |
| `git push -u origin feature/x` | 브랜치 첫 업로드 (이후엔 `git push`) |
| `git pull origin main` | 내려받기 + 병합 (= fetch + merge) |
| `git fetch origin` | 내려받기만. 비교 후 수동 병합 가능 |

### 1.6 이력 보기

```bash
git log --oneline --graph --all    # 브랜치 구조를 그래프로
git log --oneline -10              # 최근 10개
git show <해시>                    # 특정 커밋의 내용
git diff                          # 작업본 vs 스테이징
git diff --staged                 # 스테이징 vs 마지막 커밋
git blame <파일>                  # 줄별로 누가 언제 바꿨는지
```

### 1.7 임시 저장 (stash)

```bash
git stash            # 현재 변경을 잠깐 치움 (급히 브랜치 이동해야 할 때)
git stash pop        # 다시 꺼내기
git stash list       # 쌓인 stash 목록
```

---

## PART 2. GitHub 웹 활용

### 2.1 README 와 마크다운

저장소 첫 인상. 다음 구조 권장:

```markdown
# 프로젝트명
한 줄 설명

## 개요
## 폴더 구조
## 실행 방법
## 결과
## 팀원 및 역할
```

마크다운 기초:

| 문법 | 결과 |
| --- | --- |
| `# ## ###` | 제목 |
| `- 항목` / `1. 항목` | 목록 |
| `- [ ]` / `- [x]` | 체크박스 |
| `` `코드` `` / 백틱 3개 블록 | 인라인/블록 코드 |
| `[보이는글](URL)` | 링크 |
| `![](이미지URL)` | 이미지 |
| `> 글` | 인용문 |
| 파이프로 구분한 행 + `---` 행 | 표 |

### 2.2 Issues (할 일 · 버그 추적)

1. 저장소 **Issues → New issue**
2. 제목 + 본문 (마크다운 가능, `- [ ]` 체크리스트 유용)
3. 오른쪽 패널:
   - **Assignees** — 담당자
   - **Labels** — `bug` `feature` `blocked` 등
   - **Milestone** — "중간 점검" "발표" 같은 기한 묶음
4. PR 본문에 `Closes #12` 를 적으면 병합 시 그 이슈가 자동으로 닫힘.

### 2.3 Pull Request 깊게

| 기능 | 설명 |
| --- | --- |
| **Draft PR** | 아직 리뷰 받을 단계 아님 — "Create draft pull request". 준비되면 **Ready for review** |
| **base ← compare** | 병합 방향. base=`main`, compare=`feature/x` 가 맞는지 항상 확인 |
| **Files changed 탭** | 줄 옆 `+` 로 코멘트. 여러 줄은 드래그 |
| **Suggestion** | 코멘트창의 `±` 아이콘 → 고칠 코드를 직접 제안. 상대가 버튼으로 바로 적용 |
| **Review changes** | `Comment`(의견만) / `Approve`(승인) / `Request changes`(수정 요청) |
| **Resolve conversation** | 반영된 코멘트 스레드를 접음 (병합 조건) |
| **Re-request review** | 수정 후 리뷰어 이름 옆 순환 아이콘으로 다시 요청 |
| **Update branch** | 버튼이 보이면 누름 — `main` 최신을 내 브랜치에 반영 |
| **Squash and merge** | 팀 표준. 커밋을 하나로 합쳐 병합 → Confirm → Delete branch |

### 2.4 코드 리뷰 잘하기

- 정확성 → 엣지 케이스 → 테스트 유무 순으로 본다
- "이거 이상해요" 보다 "여기서 X면 Y 되니 Z로 바꾸면 어떨까요"
- 취향(대문자·띄어쓰기 등)은 도구(ruff 등)에 맡기고 로직에 집중
- 칭찬도 남긴다 ("이 부분 깔끔하네요")

### 2.5 Projects (칸반 보드)

1. 저장소 **Projects → New project → Board**
2. 컬럼: `Todo` / `In progress` / `In review` / `Done`
3. 이슈·PR 을 카드로 끌어 넣거나, 이슈 예로 새 카드 생성
4. 자동화: **Workflows** → PR 이 열리면 In progress, 병합되면 Done 으로 자동 이동

### 2.6 Actions (자동 검사 / CI)

- `.github/workflows/*.yml` 이 있으면 커밋·PR 마다 자동 실행 (lint·타입·테스트 등)
- 결과: 저장소 **Actions** 탭. 녹색 체크 = 통과, 빨간 X = 실패
- 빨간 X 클릭 → 실패한 step 펼쳐서 로그 읽기 → 그 오류를 로컬에서 재현해 수정
- 하단 **Re-run jobs** 로 재시도 가능

### 2.7 Releases & Tags

1. 저장소 오른쪽 **Releases → Draft a new release**
2. **Choose a tag** → 새 태그명 입력 (예 `v1.0`) 또는 기존 태그 선택
3. 제목 + 릴리스 노트 (변경점 요약). **Generate release notes** 로 자동 초안
4. 필요하면 빌드 산출물 첨부 → **Publish release**

### 2.8 그 외 유용

| 기능 | 위치 / 키 |
| --- | --- |
| 파일 빠르게 찾기 | 저장소에서 `t` |
| 웹 에디터로 열기 | `.` (메인페이지에서) → github.dev |
| 브랜치 전환 | `w` |
| 기여자·활동 보기 | **Insights** 탭 (Contributors, Network) |
| 알림 관리 | 우상단 종 아이콘 → 필요한 것만 Watch |

---

## PART 3. GUI 툴 (터미널 대신)

| 툴 | 쓰는 이유 |
| --- | --- |
| **VS Code — 소스 제어 패널** (왼쪽 가지 아이콘) | 변경 확인 → `+`로 스테이징 → 메시지 입력 → 체크모양으로 커밋 → `…` → Push |
| **VS Code — Git Graph 확장** | 브랜치·커밋 그래프를 눈으로 보며 이해 (강의에서 사용) |
| **GitHub Desktop** | Clone / Branch / Commit / Push / PR 생성을 버튼으로 |
| **VS Code — 충돌 편집기** | 충돌 구간에 Accept Current / Incoming / Both 버튼 |

> GUI 로 해도 내부에선 똑같은 Git 명령이 실행됩니다. 익숙해지면 터미널과 섞어 쓰게 됩니다.

---

## PART 4. 우리 팀에서는 언제 무엇을

| 상황 | 쓴다 |
| --- | --- |
| 기능 하나 시작 | `git switch -c feature/x` |
| 할 일·버그 기록 | GitHub **Issues** + Projects 보드 |
| 작업 공유·리뷰 | **Pull Request** (지시서 B·D) |
| 리뷰 반영 | 같은 브랜치에 push → PR 자동 갱신 |
| 병합 | 승인 1 + 검사 통과 → **Squash and merge** → Delete branch |
| 버전 기록 | 마일스톤·발표 시점에 **Tag + Release** |
| 망함 | 공유 브랜치는 `git revert` (`reset --hard` · `--force` 금지) |

---

## 부록. 자주 쓰는 조합 레시피

**아침에 작업 시작**
```bash
git switch main && git pull origin main
git switch -c feature/오늘작업
```

**작업 마무리 → 올리기**
```bash
git add .
git commit -m "feat: ..."
git push -u origin feature/오늘작업
```

**PR 열기 전 main 변화 반영**
```bash
git fetch origin
git merge origin/main       # 충돌 나면 PART 1.3 절차
git push
```

**병합 끝난 뒤 정리**
```bash
git switch main && git pull origin main
git branch -d feature/오늘작업
```

**릴리스 찍기**
```bash
git switch main && git pull origin main
git tag -a v1.0 -m "첫 발표"
git push origin v1.0
# 또는 GitHub → Releases → Draft a new release
```

---

- 팀 규칙 → [협업-가이드.md](협업-가이드.md)
- 팀장 세팅 → [팀장-가이드.md](팀장-가이드.md)
