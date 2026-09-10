"""From Scratch CNN — 팀원 C 담당 (feature/model-fromscratch).

라이브러리의 사전 정의 아키텍처를 쓰지 않고 Conv/Pool/FC 를 직접 쌓아
분류기를 구현한다. 아래 골격을 채워 넣으면 된다.
"""

import torch.nn as nn


class FromScratchNet(nn.Module):
    def __init__(self, num_classes=10):
        super().__init__()
        # TODO(팀원 C): Conv - ReLU - Pool 블록을 직접 쌓아 특징 추출부를 만든다.
        self.features = nn.Identity()
        # TODO(팀원 C): Flatten 후 FC 로 num_classes 로짓을 낸다.
        self.classifier = nn.Identity()

    def forward(self, x):
        raise NotImplementedError("팀원 C 가 feature/model-fromscratch 에서 구현")
