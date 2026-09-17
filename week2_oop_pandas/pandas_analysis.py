import pandas as pd


def classify_marks(marks):
    """Same grade-banding logic used in Week 1 — reused here as a derived column."""
    if marks >= 85:
        return "Excellent"
    elif marks >= 75:
        return "Strong Performance"
    elif marks >= 60:
        return "On Track"
    else:
        return "Revisit"


def main():
    df = pd.read_csv("students.csv")

    print("----- Raw Data -----")
    print(df)

    print("\n----- Basic Info -----")
    print(f"Total students: {len(df)}")
    print(f"Subjects: {df['subject'].unique()}")

    # Derived column — computed from existing data, not stored redundantly at entry time
    df["grade"] = df["marks"].apply(classify_marks)
    print("\n----- With Derived 'grade' Column -----")
    print(df)

    # groupby — average marks per subject (maps directly to SQL's GROUP BY, coming in Week 4)
    subject_avg = df.groupby("subject")["marks"].mean()
    print("\n----- Average Marks per Subject -----")
    print(subject_avg)

    # Filter — students who scored above their OWN subject's average
    df["subject_avg"] = df.groupby("subject")["marks"].transform("mean")
    above_avg = df[df["marks"] > df["subject_avg"]]
    print("\n----- Students Scoring Above Their Subject Average -----")
    print(above_avg[["name", "subject", "marks", "subject_avg", "grade"]])

    # Multiple aggregations at once
    print("\n----- Full Aggregation per Subject (mean, max, min) -----")
    print(df.groupby("subject")["marks"].agg(["mean", "max", "min"]))


if __name__ == "__main__":
    main()
