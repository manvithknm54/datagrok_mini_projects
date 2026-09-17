# Week 2 Mini Project — OOP Bank Account + Pandas Dataset Analysis

**Track:** Python (Week 2 — Intermediate)
**Program:** DataGrokr Pre-Learning Program (PLP)

## Description

Two-part mini project covering Week 2's core fundamentals: **OOP (classes, inheritance, `super()`), and pandas (`groupby`, filtering, derived columns)**.

## Part 1 — OOP Bank Account (`bank_account.py`)

A `BankAccount` base class with `deposit()` and `withdraw()`, and a `SavingsAccount` subclass that inherits from it and adds `add_interest()`.

**Design notes:**
- `SavingsAccount` uses `super().__init__()` to reuse the parent's setup instead of duplicating `owner`/`balance` assignment logic.
- `withdraw()` raises a `ValueError` on insufficient funds or invalid (negative/zero) amounts — this is deliberately triggered once in the demo run to prove the exception path actually works, not just assumed to work.
- `__str__` is overridden in both classes so `print(account)` gives a readable summary instead of a generic object reference.

**Run it:**
```bash
python bank_account.py
```

## Part 2 — Pandas Dataset Analysis (`pandas_analysis.py`)

Reads `students.csv` (name, subject, marks across Python/SQL/Git) and performs:

1. **Derived column** — a `grade` column computed via `.apply()` using the same grade-banding logic from the Week 1 project, applied fresh to each row rather than stored redundantly.
2. **`groupby` aggregation** — average marks per subject (directly maps to SQL's `GROUP BY`, coming in Week 4).
3. **Filtering** — students who scored above their own subject's average, using `.transform()` to compare each row against its group's mean.
4. **Multi-aggregation** — mean/max/min per subject in a single `.agg()` call.

**Run it:**
```bash
python pandas_analysis.py
```

## Files

```
week2_oop_pandas/
├── bank_account.py       # Part 1 — OOP
├── pandas_analysis.py    # Part 2 — pandas
├── students.csv           # sample dataset used by pandas_analysis.py
└── README.md
```

## Sample Output — Bank Account

```
Manvith's savings account — Balance: 1000.00 | Rate: 5.0%
After deposit of 500: 1500.00
After withdrawal of 200: 1300.00
Expected error caught: Insufficient funds: balance is 1300, tried to withdraw 999999
After interest applied: 1365.00
Manvith's savings account — Balance: 1365.00 | Rate: 5.0%
```

## Sample Output — Pandas Analysis (excerpt)

```
----- Average Marks per Subject -----
subject
Git       72.333333
Python    72.600000
SQL       68.000000
Name: marks, dtype: float64

----- Students Scoring Above Their Subject Average -----
      name subject  marks  subject_avg               grade
0     Asha  Python     88    72.600000           Excellent
2    Priya  Python     92    72.600000           Excellent
4  Manvith  Python     78    72.600000  Strong Performance
6    Divya     SQL     90    68.000000           Excellent
8    Meera     SQL     85    68.000000           Excellent
9   Suresh     SQL     70    68.000000            On Track
10   Anita     Git     95    72.333333           Excellent
```

## Author

Manvith — DataGrokr PLP, Week 2
