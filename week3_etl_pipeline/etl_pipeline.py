import requests
import pandas as pd


API_URL = "https://jsonplaceholder.typicode.com/users"
OUTPUT_PATH = "clean_users.csv"


def extract(url):
    """Pull raw JSON data from the API. Returns None on any failure."""
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Extraction failed: {e}")
        return None


def transform(raw_data):
    """Clean and reshape the raw user data into a usable DataFrame."""
    if raw_data is None:
        raise ValueError("No data to transform")

    df = pd.DataFrame(raw_data)

    # The API nests company info as a dict — flatten it into a plain column
    df["company"] = df["company"].apply(
        lambda c: c["name"] if isinstance(c, dict) else c
    )

    # Keep only the columns we actually care about
    df = df[["id", "name", "email", "company"]]

    # Drop any row missing required fields
    df = df.dropna()

    # Normalize column names
    df.columns = [c.lower() for c in df.columns]

    # Derived column — domain part of the email, computed fresh, not stored redundantly
    df["email_domain"] = df["email"].apply(lambda e: e.split("@")[-1])

    return df


def load(df, output_path):
    """Save the final cleaned data to CSV."""
    df.to_csv(output_path, index=False)
    print(f"Saved {len(df)} rows to {output_path}")


def run_pipeline(url, output_path):
    raw = extract(url)
    if raw is None:
        print("Pipeline stopped — extraction failed")
        return
    clean_df = transform(raw)
    load(clean_df, output_path)


if __name__ == "__main__":
    run_pipeline(API_URL, OUTPUT_PATH)
