"""MNIST 데이터 로더.

sprint-ai-ex 의 기본 로더를 팀 프로젝트 구조에 맞게 옮긴 것.
전처리(preprocessing)와 증강(augmentation) 단계를 조합해 transform 을 만든다.
"""

import torch
from torchvision import datasets, transforms

from utils.augmentation import get_augment_ops
from utils.preprocessing import get_preprocess_ops


def _build_transform(train, use_augmentation):
    ops = []
    if train and use_augmentation:
        ops += get_augment_ops()          # 팀원 B: 회전·플립·크롭 등 (학습셋 전용)
    ops += get_preprocess_ops()           # 팀원 A: 텐서 변환·정규화 등
    return transforms.Compose(ops)


def get_mnist_data_loader(batch_size=64, train=True, use_augmentation=False):
    """MNIST DataLoader 를 돌려준다.

    Args:
        batch_size: 배치 크기
        train: True 면 학습셋, False 면 테스트셋
        use_augmentation: True 면 학습셋에 증강을 적용한다 (테스트셋에는 무시)
    """
    dataset = datasets.MNIST(
        root="./data/mnist",
        train=train,
        transform=_build_transform(train, use_augmentation),
        download=True,
    )
    return torch.utils.data.DataLoader(dataset, batch_size=batch_size, shuffle=train)
