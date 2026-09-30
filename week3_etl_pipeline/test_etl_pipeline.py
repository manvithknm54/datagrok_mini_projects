import pytest
from unittest.mock import patch, Mock
from etl_pipeline import transform, extract


@pytest.fixture
def sample_raw_users():
    """Mimics the real shape of jsonplaceholder's /users response."""
    return [
        {
            "id": 1,
            "name": "Asha Rao",
            "email": "asha@example.com",
            "company": {"name": "Datagrokr Inc"},
        },
        {
            "id": 2,
            "name": "Ravi Kumar",
            "email": "ravi@testmail.com",
            "company": {"name": "TechCorp"},
        },
        {
            "id": 3,
            "name": None,          # deliberately incomplete row — should get dropped
            "email": "nobody@nowhere.com",
            "company": {"name": "Ghost LLC"},
        },
    ]


def test_transform_flattens_company(sample_raw_users):
    df = transform(sample_raw_users)
    assert "Datagrokr Inc" in df["company"].values
    assert df["company"].apply(lambda x: isinstance(x, dict)).any() == False


def test_transform_drops_incomplete_rows(sample_raw_users):
    df = transform(sample_raw_users)
    # the row with name=None should be dropped
    assert len(df) == 2
    assert df["name"].isnull().sum() == 0


def test_transform_lowercases_columns(sample_raw_users):
    df = transform(sample_raw_users)
    assert "name" in df.columns
    assert "Name" not in df.columns


def test_transform_adds_email_domain(sample_raw_users):
    df = transform(sample_raw_users)
    asha_row = df[df["name"] == "Asha Rao"].iloc[0]
    assert asha_row["email_domain"] == "example.com"


def test_transform_raises_on_none_input():
    with pytest.raises(ValueError):
        transform(None)


def test_extract_handles_request_failure():
    # Simulate the API being unreachable — extract() should catch it, not crash.
    # Must raise the SAME exception type extract() actually catches (RequestException),
    # not a generic Exception — otherwise the except block in extract() won't fire.
    import requests
    with patch("etl_pipeline.requests.get", side_effect=requests.exceptions.ConnectionError("network down")):
        result = extract("https://fake-url.example.com")
        assert result is None


def test_extract_returns_json_on_success():
    mock_response = Mock()
    mock_response.json.return_value = [{"id": 1, "name": "Test User"}]
    mock_response.raise_for_status.return_value = None

    with patch("etl_pipeline.requests.get", return_value=mock_response):
        result = extract("https://fake-url.example.com")
        assert result == [{"id": 1, "name": "Test User"}]
