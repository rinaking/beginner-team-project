"""모델 정의 모음.

역할 분담 (노션 'Git/Github (1)' 실습):
    - models/mlp.py           기준 베이스라인 (sprint-ai-ex)
    - models/from_scratch.py  팀원 C — feature/model-fromscratch
    - models/vggnet.py        팀원 D — feature/model-vggnet
    - models/resnet.py        팀원 E — feature/model-resnet

모든 모델은 입력으로 (N, 1, 28, 28) 텐서를 받아 (N, 10) 로짓을 돌려준다.
필요한 flatten/reshape 은 각 모델 forward 안에서 처리한다.
"""

from models.from_scratch import FromScratchNet
from models.mlp import SimpleMLP
from models.resnet import ResNet
from models.vggnet import VGGNet

MODELS = {
    "mlp": SimpleMLP,
    "from_scratch": FromScratchNet,
    "vggnet": VGGNet,
    "resnet": ResNet,
}


def build_model(name):
    """이름으로 모델 인스턴스를 만든다."""
    if name not in MODELS:
        raise ValueError(f"알 수 없는 모델: {name!r}. 가능한 값: {list(MODELS)}")
    return MODELS[name]()
