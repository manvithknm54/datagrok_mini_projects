# Week 3 Mini Project — ETL Pipeline with Unit Tests

**Track:** Python (Week 3 — Advanced)
**Program:** DataGrokr Pre-Learning Program (PLP)

## Description

A full ETL (Extract, Transform, Load) pipeline that pulls user data from a public REST API, cleans and reshapes it with pandas, and saves the result to CSV — covering Week 3's core fundamentals: **API integration, pandas transformation, exception handling, and pytest unit testing.**

Data source: [`jsonplaceholder.typicode.com/users`](https://jsonplaceholder.typicode.com/users) — a free public test API.

## Pipeline Design

The pipeline is split into three independent, single-purpose functions — a deliberate design choice, not just structure for its own sake:

- **`extract(url)`** — makes the API call, with a timeout and `raise_for_status()` so bad HTTP responses become catchable exceptions. Wrapped in try/except so a network failure returns `None` instead of crashing the whole program.
- **`transform(raw_data)`** — flattens the API's nested `company` field into a plain column, drops incomplete rows, normalizes column names to lowercase, and adds a derived `email_domain` column computed from each email (not stored redundantly — computed fresh from the source data).
- **`load(df, output_path)`** — writes the final cleaned DataFrame to CSV.

**Why split into three functions:** each stage can be tested in isolation — `transform()` is tested with fixed sample data, with no dependency on the API actually being reachable. This also means a change to the API's response format only requires touching `extract()`/`transform()`, not the whole pipeline. If the API is down, `extract()` fails gracefully and the pipeline stops cleanly instead of crashing mid-run.

## Tests (`test_etl_pipeline.py`)

7 tests, covering:
- Company field correctly flattened from nested dict to plain string
- Rows with missing required fields are dropped
- Column names are lowercased
- Derived `email_domain` column is computed correctly
- `transform(None)` raises `ValueError` as expected
- `extract()` returns `None` (not a crash) when the network request fails — verified using a mocked failure, not a real dropped connection
- `extract()` correctly returns parsed JSON on a successful response — verified using a mocked successful response

Network calls are **mocked** in the test suite (`unittest.mock.patch`) rather than hitting the real API — this is standard practice, since unit tests should be fast, reliable, and not depend on an external service being online at test time.

## How to Run

```bash
pip install -r requirements.txt

# Run the actual pipeline (hits the real API, needs internet)
python etl_pipeline.py

# Run the test suite (uses mocked data, no internet needed)
pytest test_etl_pipeline.py -v
```

## Files

```
week3_etl_pipeline/
├── etl_pipeline.py       # extract / transform / load
├── test_etl_pipeline.py  # pytest suite (7 tests)
├── requirements.txt
└── README.md
```

## Sample Test Output

```
============================= test session starts ==============================
collected 7 items

test_etl_pipeline.py::test_transform_flattens_company PASSED             [ 14%]
test_etl_pipeline.py::test_transform_drops_incomplete_rows PASSED        [ 28%]
test_etl_pipeline.py::test_transform_lowercases_columns PASSED           [ 42%]
test_etl_pipeline.py::test_transform_adds_email_domain PASSED            [ 57%]
test_etl_pipeline.py::test_transform_raises_on_none_input PASSED         [ 71%]
test_etl_pipeline.py::test_extract_handles_request_failure PASSED        [ 85%]
test_etl_pipeline.py::test_extract_returns_json_on_success PASSED        [100%]

============================== 7 passed in 0.50s ===============================
```

## Author

Manvith — DataGrokr PLP, Week 3
