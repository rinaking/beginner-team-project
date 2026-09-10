"""VGGNet 기반 모델 — 팀원 D 담당 (feature/model-vggnet).

VGG 스타일(3x3 Conv 를 여러 겹 쌓고 MaxPool 로 줄이는 구조)로 구현한다.
MNIST(1x28x28) 입력에 맞게 채널 수와 깊이를 줄여서 사용한다.
"""

import torch.nn as nn


class VGGNet(nn.Module):
    def __init__(self, num_classes=10):
        super().__init__()
        # TODO(팀원 D): [Conv3x3 - ReLU] * n - MaxPool 블록을 반복해 쌓는다.
        self.features = nn.Identity()
        self.classifier = nn.Identity()

    def forward(self, x):
        raise NotImplementedError("팀원 D 가 feature/model-vggnet 에서 구현")
