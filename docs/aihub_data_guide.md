# AI Hub 데이터 받을 때 참고

원천 이미지 zip이 하나에 19~30GB라 로컬로 받으면 용량 순삭됨. 대신 `aihubshell`이라는 CLI로 코랩에서 바로 받으면 됨.

## 설치
```bash
curl -o "aihubshell" https://api.aihub.or.kr/api/aihubshell.do
chmod +x aihubshell
```

## 쓰는 법
```bash
# 파일 목록 + filekey 확인
./aihubshell -mode l -datasetkey 576 -aihubapikey <자기 API KEY>

# 필요한 파일만 골라서 다운
./aihubshell -mode d -datasetkey 576 -filekey <filekey> -aihubapikey <자기 API KEY>

# 여러 개 한번에도 됨
./aihubshell -mode d -datasetkey 576 -filekey 111,222,333 -aihubapikey <자기 API KEY>
```

datasetkey 576 = 경구약제 이미지 데이터. filekey는 `-mode l`로 조회하면 나옴.

API KEY는 각자 aihub.or.kr 로그인해서 개인 발급받아야 함 (공유 X, 코드에 그대로 적지 말고 Colab Secrets에).

## 용량 안 터지게 받는 순서
1. 라벨(JSON)은 용량 작으니까 먼저 다 받아서, 우리한테 필요한 클래스가 어느 zip에 있는지부터 확인
2. 그거 찾으면 그 zip만 filekey로 골라서 다운 (절대 전체 다운로드 누르지 말기 — 3.65TB 통째로 받힘)
3. 압축 풀고 필요한 파일만 빼놓은 다음, zip은 바로 삭제
4. 최종적으로 골라낸 이미지+라벨만 레포에 올리기 (원본 zip은 절대 커밋 금지)

## 참고
- https://www.aihub.or.kr/devsport/apishell/list.do?currMenu=403&topMenu=100
- https://devocean.sk.com/blog/techBoardDetail.do?ID=166594&boardType=techBlog
