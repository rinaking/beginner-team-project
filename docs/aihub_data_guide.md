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

## 클래스 식별자는 반드시 dl_mapping_code로 쓸 것 (9/22 검증)

AI Hub json의 `categories`/`category_id`는 전부 `{"id":1,"name":"Drug"}`로 고정이라
못 쓰고, `images[0]` 안에 `dl_idx`랑 `dl_mapping_code` 둘 다 있어서 헷갈리기 쉬운데
실제로 원본 데이터 폴더명(`K-000123` 형태, 진짜 약 코드)과 직접 대조해봤다.

- `dl_mapping_code`: 1,000개 → 14,181개(전수) 전부 폴더코드와 100% 일치
- `dl_idx`: 5.5%만 일치, 나머지는 -1 ~ +76,992까지 편차가 제각각(단순 off-by-one도 아님)

**결론: `dl_mapping_code`만 쓸 것.** `dl_idx`를 쓴 노트북은 AI Hub 데이터 비중이 큰
학습에서는 클래스 라벨이 사실상 랜덤이었을 가능성이 큼(FasterRCNN/RTMDet/RetinaNet
final_wandb 전부 이 문제 있었고 로컬에서 dl_mapping_code로 수정본 만들어둠).

```python
import re
def parse_dl_mapping_code(code):
    m = re.fullmatch(r"K-(\d+)", str(code).strip())
    if m is None:
        raise ValueError(f"예상하지 못한 dl_mapping_code 형식: {code!r}")
    return int(m.group(1))

drug_id = parse_dl_mapping_code(file_img["dl_mapping_code"])  # 이렇게, dl_idx 말고
```

## 라벨 인덱스는 매번 재계산하지 말고 파일로 고정할 것

`category_to_label = {cid: i+1 for i, cid in enumerate(sorted(...))}` 방식은 데이터가
조금만 바뀌어도(클래스 하나 추가/제외) 라벨 번호가 밀려서, 예전 체크포인트로 추론하면
모델 성능과 무관하게 예측이 조용히 다른 약으로 나올 수 있음(실제로 클래스 1개 추가만으로
기존 118개 중 118개 전부 밀리는 걸 재현함). 학습/추론 양쪽에서 같은
`category_label_map.json`을 불러써서 고정하고, 새 클래스는 기존 번호를 안 건드리고
뒤에 추가하는 방식으로 관리할 것.

## 참고
- https://www.aihub.or.kr/devsport/apishell/list.do?currMenu=403&topMenu=100
- https://devocean.sk.com/blog/techBoardDetail.do?ID=166594&boardType=techBlog
