# 아주 초보자용 GitHub 안내 (초급 팀 프로젝트)

> GitHub 를 한 번도 안 써본 사람을 위한 문서입니다. 용어를 모르는 게 정상입니다.
> 터미널이 무서워도 괜찮습니다 — 아래에 마우스로만 하는 방법도 있습니다.
> 다음 단계: [협업-가이드.md](협업-가이드.md) · [github-활용-지침서.md](github-활용-지침서.md)

---

## 1. 이게 다 뭐예요?

### Git 과 GitHub 는 다릅니다

| | 무엇 | 비유 |
| --- | --- | --- |
| **Git** | 내 컴퓨터에서 파일의 변경 이력을 저장하는 도구 | 무한 되돌리기가 되는 세이브 버튼 |
| **GitHub** | 그 이력을 인터넷에 올려 팀원과 공유하는 사이트 | 구글 드라이브 + 댓글·리뷰 기능 |

### 왜 써요?

- 팀원 A와 B가 같은 파일을 고쳐도 서로 덮어쓰지 않게 합쳐줍니다.
- 잘 돌던 시점으로 언제든 되돌릴 수 있습니다.
- 누가 언제 무엇을 바꿨는지 전부 남습니다.

### 큰 그림 (이 순서가 전부입니다)

내 컴퓨터에서 파일 수정 → `add`(변경을 고른다) → `commit`(한 버전으로 기록) → `push`(GitHub 에 올린다) → GitHub 에서 팀원과 합친다

---

## 2. 딱 3가지 개념만

| 개념 | 한 줄 설명 |
| --- | --- |
| **저장소 (repository / 레포)** | 프로젝트 폴더 하나 + 그 안 모든 변경 이력 |
| **커밋 (commit)** | "여기까지를 한 번으로 저장" + 짧은 메모(메시지) |
| **브랜치 (branch)** | 나만의 작업 갈래. 남 것과 안 섞이고 따로 개발하다가 나중에 합친다 |

> 나머지 용어(push, pull, merge, PR ...)는 하다 보면 자연스럽게 익혀집니다. 지금은 위 3개만.

---

## 3. 설치 (한 번만)

### 3.1 Git 설치

| OS | 방법 |
| --- | --- |
| Windows | <https://git-scm.com/download/win> 다운로드 → 설치 마법사 **기본값으로 Next** 만 누름 → 설치 후 시작메뉴의 **Git Bash** 실행 |
| macOS | 터미널(Terminal) 열고 `git --version` → 없으면 설치 팝업 → **설치** 클릭 |

확인: `git --version` → `git version 2.xx.x` 가 나오면 성공.

### 3.2 (선택) 터미널이 무서우면 — GitHub Desktop

<https://desktop.github.com> 에서 설치. 버튼 클릭으로 commit·push 를 하는 앱입니다. 처음엔 이걸로 시작해도 됩니다.

### 3.3 VS Code 설치

<https://code.visualstudio.com> — 코드 편집 + 충돌 해결 + Git 화면이 내장되어 편합니다.

---

## 4. GitHub 계정 만들기

1. <https://github.com> → **Sign up**
2. 이메일 · 비밀번호 · 사용자명(username) 입력
   - **username 은 공개됩니다.** 단정하게 (예: `hyerin-kim`, `hrkim-dev`)
3. 이메일 인증(메일박스의 링크 클릭)
4. 로그인 후, 오른쪽 위 프로필 → **Your profile** 에서 내 username 확인
5. **팀장에게 내 username 을 알려줍니다** (팀 저장소에 초대받기 위해 필요)

> 팀장이 초대하면 메일 또는 `github.com/notifications` 에 초대가 옵니다. **Accept** 를 눌러야 저장소에 코드를 올릴 수 있습니다.

---

## 5. 처음 해보기 — 아주 작게

> 세 가지 방법 중 **하나만** 골라 따라 해보세요. 익숙해지면 C 방법(터미널)으로 옮깁니다.

### 방법 A — GitHub 웹에서만 (터미널 0)

1. 팀 저장소 페이지에서 아무 문서 파일(예: `README.md`) 클릭
2. 오른쪽 위 **연필 아이콘(Edit this file)** 클릭
3. 내용을 한 줄 고침
4. 오른쪽 위 **Commit changes…** 클릭
5. **중요**: "Commit directly to the main branch" 가 아니라 **"Create a new branch… and start a pull request"** 선택 → 브랜치명 입력 → **Propose changes**
6. 다음 화면에서 **Create pull request**

→ 터미널 없이 PR 까지 만들었습니다.

### 방법 B — GitHub Desktop (버튼 클릭)

1. GitHub Desktop 열기 → **File → Clone repository** → 팀 저장소 선택 → **Clone**
2. 왼쪽 상단 **Current Branch → New Branch** → `feature/연습-내이름` 입력 → Create
3. VS Code 로 파일 몇 글자 수정 후 저장
4. GitHub Desktop 으로 돌아오면 왼쪽에 변경된 파일이 보임
5. 왼쪽 아래 **Summary** 칸에 `feat: 연습 커밋` 입력 → **Commit to feature/…**
6. 상단 **Push origin** 클릭
7. 뜨는 **Create Pull Request** 버튼 클릭 → 브라우저에서 PR 작성

### 방법 C — 터미널 (익숙해지면 이걸로)

```bash
# 1) 최초 1회 내 정보 등록
git config --global user.name "내 이름"
git config --global user.email "GitHub 이메일"

# 2) 저장소 받기 (Code 버튼 → HTTPS 주소 복사)
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 3) 내 브랜치 만들기
git switch -c feature/연습-내이름

# 4) 파일 몇 글자 수정·저장 후
git add .
git commit -m "feat: 연습 커밋"
git push -u origin feature/연습-내이름
```

→ 터미널에 뜨는 `pull/new/...` 링크를 클릭하면 PR 화면으로 갑니다. **Create pull request**.

---

## 6. 방금 한 것을 말로 풀면

- `clone` = GitHub 의 프로젝트를 내 컴퓨터로 복사해 온 것
- `브랜치 생성` = "`main` 을 건드리지 않고 내 갈래에서 작업하겠다"
- `add` → `commit` = 변경을 골라서 → 한 버전으로 기록
- `push` = 그 버전을 GitHub 에 올림
- `PR (Pull Request)` = "내 브랜치를 `main` 에 합쳐 주세요" 라는 요청 + 리뷰 공간

---

## 7. 이럴 때는 이렇게 (미니 FAQ)

| 상황 | 해결 |
| --- | --- |
| `git` 이 명령어가 아니라고 나와요 | Git 설치 안 됨, 또는 터미널을 새로 안 열음. 새 창에서 다시 |
| push 했는데 `Permission denied` / `403` | 팀 저장소 초대를 아직 수락 안 함 → `github.com/notifications` 확인 |
| 비밀번호를 물어보는데 안 들어가요 | GitHub 는 비밀번호 대신 토큰을 씀. 웹 팝업이 뜨면 거기서 로그인, 안 뜨면 팀장에게 "토큰 설정" 도움 요청 |
| 뭐가 바뀌었는지 모르겠어요 | `git status` 치면 변경된 파일 목록이 나옵니다 |
| 실수로 많이 고쳤어요, 되돌리고 싶어요 (커밋 전) | `git restore <파일명>` — 마지막 저장 상태로 돌아감 |
| 겁나요 | 읽기 명령(`git status`, `git log`, `git branch`)은 아무것도 망가뜨리지 않아요. 마음대로 쳐보세요 |

---

## 8. 용어 카드 (딱 필요한 것만)

| 용어 | 뜻 |
| --- | --- |
| 레포 / 저장소 | 프로젝트 폴더 + 이력 |
| 로컬 / 원격 | 내 컴퓨터 / GitHub |
| 커밋 | 변경 한 번분을 메시지와 함께 기록 |
| 브랜치 | 작업 갈래. `main` 은 팀의 정답 |
| `origin` | clone 하면 자동으로 붙는 "GitHub 의 그 저장소" 별명 |
| push / pull | 올리기 / 내려받기 |
| PR | 합쳐달라는 요청 + 리뷰 |
| 병합(merge) | 브랜치를 합침 |
| 충돌(conflict) | 같은 줄을 둘이 다르게 고쳐 자동으로 못 합칠 때 |

---

## 9. 다음 단계

1. [협업-가이드.md](협업-가이드.md) — 팀이 지키는 규칙 (브랜치명·커밋 메시지·PR·병합·충돌)
2. [github-활용-지침서.md](github-활용-지침서.md) — Issues·PR·리뷰·Projects·Actions 자세히 쓰는 법
3. 협업 지시서 부록 3의 "연습 PR 1회 완주" 체크리스트 끝내기
