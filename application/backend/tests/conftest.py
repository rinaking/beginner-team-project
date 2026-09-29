import os
import tempfile
from pathlib import Path

db_path = Path(tempfile.mkdtemp()) / "test.db"
os.environ["DATABASE_URL"] = f"sqlite:///{db_path}"
os.environ["SKIP_MODEL_LOAD"] = "1"
os.environ["INTERACTION_API_BASE_URL"] = ""
os.environ["INTERACTION_API_KEY"] = ""

import pytest
from fastapi.testclient import TestClient

from database.database import engine
from database.models import Base
from main import app


@pytest.fixture
def client():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    with TestClient(app) as test_client:
        yield test_client
