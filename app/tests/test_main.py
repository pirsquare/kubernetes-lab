"""
Test suite for FastAPI application.
Run with: pytest app/tests/
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """Fixture for FastAPI test client"""
    return TestClient(app)


class TestHealthEndpoints:
    """Test health check endpoints"""

    def test_health_check(self, client):
        """Test health endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_readiness_check(self, client):
        """Test readiness endpoint"""
        response = client.get("/readiness")
        assert response.status_code == 200
        assert response.json()["status"] == "ready"


class TestRootEndpoints:
    """Test root endpoints"""

    def test_root(self, client):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()

    def test_docs(self, client):
        """Test docs endpoint"""
        response = client.get("/docs")
        assert response.status_code == 200


class TestAPIEndpoints:
    """Test API endpoints"""

    def test_app_info(self, client):
        """Test app info endpoint"""
        response = client.get("/api/v1/info")
        assert response.status_code == 200
        data = response.json()
        assert "app_name" in data
        assert "version" in data

    def test_get_data(self, client):
        """Test get data endpoint"""
        response = client.get("/api/v1/data/123")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == 123

    def test_get_data_invalid_id(self, client):
        """Test get data with invalid ID"""
        response = client.get("/api/v1/data/-1")
        assert response.status_code == 400

    def test_create_data(self, client):
        """Test create data endpoint"""
        payload = {
            "id": 1,
            "name": "Test Item",
            "description": "Test Description"
        }
        response = client.post("/api/v1/data", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Test Item"


class TestMetrics:
    """Test metrics endpoint"""

    def test_metrics(self, client):
        """Test metrics endpoint"""
        response = client.get("/metrics")
        assert response.status_code == 200
        data = response.json()
        assert "app_name" in data
        assert "status" in data
