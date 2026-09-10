"""ResNet 기반 모델 — 팀원 E 담당 (feature/model-resnet).

잔차 연결(residual connection)을 쓰는 블록을 정의하고 이를 쌓아 구현한다.
MNIST(1x28x28) 입력에 맞게 얕은 ResNet 으로 시작하는 것을 권장한다.
"""

import torch.nn as nn


class ResidualBlock(nn.Module):
    def __init__(self, in_channels, out_channels, stride=1):
        super().__init__()
        # TODO(팀원 E): Conv-BN-ReLU-Conv-BN + shortcut 을 구성한다.
        raise NotImplementedError("팀원 E 가 feature/model-resnet 에서 구현")

    def forward(self, x):
        raise NotImplementedError


class ResNet(nn.Module):
    def __init__(self, num_classes=10):
        super().__init__()
        self.stem = nn.Identity()
        self.layers = nn.Identity()
        self.head = nn.Identity()

    def forward(self, x):
        raise NotImplementedError("팀원 E 가 feature/model-resnet 에서 구현")
