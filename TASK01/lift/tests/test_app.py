# tests/test_app.py
# Project: Lift — Hill Valley Tech
# Purpose: Unit tests for the Flask application routes.
# Variables used:
#   API_KEY — set to a test value via environment before the test client is created.

import os
import pytest

os.environ.setdefault("DATABASE_URL", "postgresql://test:test@localhost:5432/lift_test")
os.environ.setdefault("API_KEY", "test-secret-key")

from TASK01.lift.app import app  # noqa: E402


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_health_returns_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_items_requires_auth(client):
    response = client.get("/items")
    assert response.status_code == 401


def test_items_with_valid_key(client, monkeypatch):
    monkeypatch.setattr("lib.storage.fetch_all", lambda q, p=(): [])
    response = client.get(
        "/items",
        headers={"Authorization": "Bearer test-secret-key"},
    )
    assert response.status_code == 200
    assert "items" in response.get_json()
