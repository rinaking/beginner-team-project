"""저장소가 정상적으로 설치·실행되는지 확인하는 스모크 테스트."""

from __future__ import annotations

import src
from src.__main__ import main


def test_version_exists() -> None:
    assert src.__version__ == "0.1.0"


def test_main_prints(capsys) -> None:  # type: ignore[no-untyped-def]
    main()
    assert "준비 완료" in capsys.readouterr().out
