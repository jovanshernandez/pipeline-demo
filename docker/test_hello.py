from falcon import testing

from hello import app


def test_root_returns_service_metadata():
    client = testing.TestClient(app)

    result = client.simulate_get("/")

    assert result.status_code == 200
    assert result.json["service"] == "pipeline-demo"


def test_health_endpoint_returns_ok():
    client = testing.TestClient(app)

    result = client.simulate_get("/health")

    assert result.status_code == 200
    assert result.json == {"status": "ok"}
