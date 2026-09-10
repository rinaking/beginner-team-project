"""MNIST 이미지 분류 — 학습·평가 메인 스크립트.

sprint-ai-ex 의 main.py 를 팀 프로젝트 구조(모델 선택 + 전처리/증강 조합)에 맞게 확장한 것.

사용 예:
    python main.py                       # 베이스라인(MLP), 5 epochs
    python main.py --model mlp --epochs 3
    python main.py --model resnet --augment
"""

import argparse

import torch
import torch.nn as nn
import torch.optim as optim

from models import build_model
from utils.data_loader import get_mnist_data_loader


def run(model_name, epochs, batch_size, lr, use_augmentation):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"model={model_name}  device={device}  augment={use_augmentation}")

    train_loader = get_mnist_data_loader(batch_size, train=True, use_augmentation=use_augmentation)
    test_loader = get_mnist_data_loader(batch_size, train=False)

    model = build_model(model_name).to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(model.parameters(), lr=lr)

    for epoch in range(1, epochs + 1):
        model.train()
        for batch_idx, (data, target) in enumerate(train_loader):
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            loss = criterion(model(data), target)
            loss.backward()
            optimizer.step()
            if batch_idx % 100 == 0:
                print(f"epoch {epoch}  batch {batch_idx}  loss {loss.item():.4f}")

    model.eval()
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            pred = model(data).argmax(dim=1)
            correct += pred.eq(target).sum().item()
    acc = 100.0 * correct / len(test_loader.dataset)
    print(f"test accuracy: {acc:.2f}%")
    return acc


def main():
    parser = argparse.ArgumentParser(description="Train an image classifier on MNIST")
    parser.add_argument("--model", default="mlp",
                        choices=["mlp", "from_scratch", "vggnet", "resnet"],
                        help="사용할 모델 (default: mlp)")
    parser.add_argument("--epochs", type=int, default=5)
    parser.add_argument("--batch-size", type=int, default=64)
    parser.add_argument("--lr", type=float, default=0.01)
    parser.add_argument("--augment", action="store_true", help="학습셋에 데이터 증강 적용")
    args = parser.parse_args()
    run(args.model, args.epochs, args.batch_size, args.lr, args.augment)


if __name__ == "__main__":
    main()
