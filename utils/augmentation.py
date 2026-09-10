"""데이터 증강 — 팀원 B 담당 (feature/augmentation).

학습셋에만 적용하는 증강 transform 을 정의한다.
기본값은 '증강 없음'(빈 리스트)이며, 팀원 B 가 회전·플립·크롭 등을 추가한다.

예시:
    return [
        transforms.RandomRotation(10),
        transforms.RandomHorizontalFlip(),
        transforms.RandomResizedCrop(28, scale=(0.9, 1.0)),
    ]
"""

from torchvision import transforms  # noqa: F401  (증강 구현 시 사용)


def get_augment_ops():
    """증강 transform 들의 리스트를 돌려준다. 전처리보다 먼저 적용된다."""
    return []
