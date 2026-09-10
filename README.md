<div align="center">

# 🌱 초급 팀 프로젝트

**Git과 GitHub, 우리 다 같이 처음이니까 — 천천히, 함께** 🐣

`clone` → `branch` → `commit` → `push` → `pull request` → `merge`

<sub>강의 · <b>Git/Github (1)</b> 에서 배운 범위만으로 하나의 프로젝트를 완성해요.</sub>

</div>

---

## 🧸 이 저장소는요

| | |
| --- | --- |
| 🎯 **목적** | 팀원 모두가 **같은 규칙**으로 브랜치를 나눠 작업하고, Pull Request 로 합쳐요 |
| 👶 **대상** | Git · GitHub 를 이제 막 시작한 팀원 |
| 🗺️ **범위** | 저장소 복제 → 브랜치 → 커밋 → Push → PR → 병합 → 충돌 해결 |
| 🙅 **안 해요** | 빌드 도구 · 패키지 설정 · 자동화(CI) — 강의 범위 밖이에요 |

> 💡 프로젝트의 주제와 기능은 팀에서 정해요. 이 저장소는 **협업의 뼈대**만 준비해 뒀어요.

---

## 🚀 시작하기

```bash
# 1. 저장소 내 컴퓨터로 가져오기
git clone https://github.com/rinaking/beginner-team-project.git
cd beginner-team-project

# 2. 처음 딱 한 번, 내 정보 등록하기 (이미 했으면 건너뛰기)
git config --global user.name  "본인 이름"
git config --global user.email "GitHub 이메일"
```

> ✅ `git status` 를 쳤을 때 `working tree clean` 이 보이면 준비 끝! 🎉

---

## 🌿 작업하는 순서

`main` 은 항상 잘 돌아가는 상태로 두고, 모든 작업은 **내 브랜치**에서 해요.

```text
main 최신화  →  브랜치 만들기  →  작업 · 커밋  →  Push  →  PR  →  리뷰  →  병합  →  브랜치 정리
```

```bash
git switch main && git pull origin main       # 1. main 최신 상태로
git switch -c feat/기능이름                     # 2. 내 브랜치 만들기

#    ✏️  ... 작업 ...

git add . && git commit -m "feat: 바꾼 내용"   # 3. 커밋
git push -u origin feat/기능이름                # 4. GitHub 로 올리기

#    🔀  GitHub 에서 Pull Request 만들기 → 리뷰 받기 → 병합

git switch main && git pull                    # 5. 병합된 내용 받기
git branch -d feat/기능이름                     # 6. 다 쓴 브랜치 정리
```

---

## 🏷️ 브랜치 · 커밋 이름 규칙

**브랜치** — `<타입>/<간단요약>` · 소문자 · 하이픈(`-`)으로 띄어쓰기

| 이모지 | 타입 | 언제 쓰나요 | 예시 |
| :--: | --- | --- | --- |
| ✨ | `feat` | 새 기능을 더할 때 | `feat/login-form` |
| 🐛 | `fix` | 버그를 잡을 때 | `fix/typo-header` |
| 📝 | `docs` | 문서만 고칠 때 | `docs/update-readme` |

**커밋 메시지** — `<타입>: <무엇을 왜 바꿨는지>` 를 한 줄로, 명령하듯이

```text
feat: 회원가입 폼에 이메일 형식 검사 추가
```

> 🧹 커밋은 **의미 단위로 자주** 남겨요. `main` 에 바로 커밋하거나 `git push --force` 는 하지 않기로 해요.

---

## 🔀 Pull Request 약속

1. 📌 제목은 이 브랜치가 **무엇을 하는지** 드러나게
2. 📝 본문에 **바꾼 내용**과 **확인 방법**을 적어요
3. 🙋 팀원 **1명 이상**에게 리뷰를 부탁해요
4. ✅ 대화가 다 해결되면 **Squash and merge** → 브랜치 삭제
5. ⚔️ 충돌이 나면 당황하지 말고 아래처럼 해결해요

```bash
git switch feat/기능이름
git merge main         # <<<<  ====  >>>> 표시된 곳을 직접 골라서 정리
git add . && git commit
git push
```

---

## 👥 우리 팀

<table align="center">
<tr>
<td align="center">
  <a href="https://github.com/rinaking"><img src="https://github.com/rinaking.png" width="90" alt="rinaking"/></a><br/>
  <b>김혜린</b><br/>
  <sub>🎀 팀장</sub><br/>
  <sub><a href="https://github.com/rinaking">@rinaking</a></sub>
</td>
<td align="center">
  <a href="https://github.com/Inhoooooo"><img src="https://github.com/Inhoooooo.png" width="90" alt="Inhoooooo"/></a><br/>
  <b>강인호</b><br/>
  <sub>🧑‍💻 팀원</sub><br/>
  <sub><a href="https://github.com/Inhoooooo">@Inhoooooo</a></sub>
</td>
<td align="center">
  <a href="https://github.com/TheMostEvident"><img src="https://github.com/TheMostEvident.png" width="90" alt="TheMostEvident"/></a><br/>
  <b>유영관</b><br/>
  <sub>🧑‍💻 팀원</sub><br/>
  <sub><a href="https://github.com/TheMostEvident">@TheMostEvident</a></sub>
</td>
</tr>
</table>

> 🧩 담당 파일이 서로 겹치지 않게 나눠요. 겹치면 충돌이 나요!

---

<div align="center">
<sub>📄 <a href="LICENSE">MIT License</a> · © 2026 초급 팀 프로젝트</sub>
</div>
