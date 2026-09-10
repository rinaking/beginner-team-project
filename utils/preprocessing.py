"""데이터 전처리 파이프라인 — 팀원 A 담당 (feature/preprocessing).

이미지를 모델에 넣기 전에 거치는 기본 변환을 정의한다.
지금은 sprint-ai-ex 와 동일한 최소 전처리(텐서 변환 + 표준 정규화)만 들어 있다.

개선 아이디어:
    - 결측치/손상 이미지 필터링
    - 데이터셋 통계로 계산한 정규화 값 사용
    - 리사이즈·그레이스케일 변환 등 데이터 클렌징
"""

from torchvision import transforms

# MNIST 전체 평균/표준편차 (sprint-ai-ex 기본값)
MNIST_MEAN = (0.1307,)
MNIST_STD = (0.3081,)


def get_preprocess_ops():
    """전처리 transform 들의 리스트를 돌려준다.

    DataLoader 는 이 리스트를 증강(augmentation) 뒤에 이어 붙여 사용한다.
    """
    return [
        transforms.ToTensor(),
        transforms.Normalize(MNIST_MEAN, MNIST_STD),
    ]
