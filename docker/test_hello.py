from falcon import testing

from hello import app


def test_root_returns_service_metadata():
    client = testing.TestClient(app)

    result = client.simulate_get("/")

    assert result.status_code == 200
    assert result.json["service"] == "pipeline-demo"
    assert result.json["version"] == "local"


def test_health_endpoint_returns_ok():
    client = testing.TestClient(app)

    result = client.simulate_get("/health")

    assert result.status_code == 200
    assert result.json == {"status": "ok"}


def test_ready_endpoint_returns_checks():
    client = testing.TestClient(app)

    result = client.simulate_get("/ready")

    assert result.status_code == 200
    assert result.json["status"] == "ready"
    assert result.json["checks"]["app_loaded"] is True
