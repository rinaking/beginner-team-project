"""기준 베이스라인 모델 — sprint-ai-ex 의 SimpleMLP.

바로 학습이 되는 유일한 모델이라, 팀원 C·D·E 는 이 구조를 참고해
자신의 아키텍처를 채우면 된다.
"""

import torch.nn as nn


class SimpleMLP(nn.Module):
    def __init__(self, input_size=784, hidden_size=128, num_classes=10):
        super().__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, num_classes)

    def forward(self, x):
        x = x.view(x.size(0), -1)  # (N, 1, 28, 28) -> (N, 784)
        x = self.fc1(x)
        x = self.relu(x)
        return self.fc2(x)
