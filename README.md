# Retention Intelligence — v0.4 (functional workspace)

A Windows-first, Python + PySide6/QML customer churn analysis, exploratory prediction, and retention-case desktop app. The UI follows the white / blue / orange visual style.

## What works

| Screen | Features |
|---|---|
| Overview | Real imported totals, observed churn rate, contract breakdown |
| Customers | ID search, status filter, pagination, CSV export |
| Churn Analytics | Data-backed segmentation by contract, tenure, charges, payment method, coverage checks, CSV export |
| Prediction Studio | Customer risk rankings and per-customer inspection after model training, CSV export |
| Retention | Local SQLite case creation, status updates, notes, dataset-isolated case history |
| Data Sources | CSV/Excel import, data summary, local copy and removal |
| Model Lab | Background training, 25% stratified holdout metrics, feature-coefficient inspection |
| Reports | PDF summary, CSV segments, exploratory risk CSV |
| Settings | Persisted risk threshold, compact rows, financial display label |

## Upgrade from v0.3 — PowerShell

Close Retention Intelligence first. From `C:\Users\nooklyweb\Documents`:

```powershell
Copy-Item .\retention-intelligence .\retention-intelligence-backup-v03 -Recurse -Force
Expand-Archive "$HOME\Downloads\retention-intelligence-v0.4-functional.zip" -DestinationPath . -Force
cd .\retention-intelligence
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
.\.venv\Scripts\python.exe main.py
```

Do not delete `.venv` or `%LOCALAPPDATA%\RetentionIntelligence`; the latter stores the current imported dataset and retention cases. Model training runs in RAM, so retrain after restarting the app.

If Python 3.12 or 3.13 is installed but `.venv` doesn't exist, run `py -m venv .venv` then install requirements.

## Recommended first test

1. **Overview**: verify the 180-record synthetic demo still appears.
2. **Churn Analytics**: change segmentation from Contract to Tenure and Payment method.
3. **Model Lab**: click **Train baseline**. On the bundled demo, expect 135 training rows and 45 holdout rows; the precise metrics depend on package versions.
4. **Prediction Studio**: review ranked customers (synthetic-only exploratory scores).
5. **Retention**: create a case for `DEMO-0001`, select **Support callback**, then change its status to **Contacted**.
6. **Reports**: export a PDF and a CSV, and inspect the actual files.
7. **Settings**: move the threshold slider and enable compact customer rows.

## Data requirements

A nonempty `.csv` or `.xlsx` with an identifiable customer ID. Optional recognized columns: Churn, Contract, tenure, MonthlyCharges, TotalCharges and PaymentMethod. For model training, at least 50 labeled rows, 10 rows per class, 2 recognized safe feature columns, and no duplicate customer IDs are required.

For the baseline, features are restricted to an explicit allowlist of service, contract and billing columns. Customer IDs, churn labels, churn reasons, satisfaction outcomes, and other potentially post-churn columns are excluded. The model is Logistic Regression with categorical one-hot encoding and median numeric imputation.

### Interpretation limits (important)

- The included dataset is **synthetic** and must not support real business decisions.
- Predictions on the loaded customers include **in-sample model scores**. They illustrate ranking, not confirmed 30-day probabilities. Validation metrics are from a separate holdout; for real temporal forecasting we need dated historical snapshots and future churn outcomes.
- The 25% stratified holdout is a proof-of-concept evaluation, not temporal validation or probability calibration.
- Retention interventions are logged as human actions. A status of **Resolved** does not mean the intervention caused the customer to stay.
- Churned monthly charges are not measured lost revenue. Currency units originate from the imported dataset; the Settings label does not convert values.
- Do not load model files or customer datasets from untrusted sources. Model serialization is intentionally not implemented in v0.4.

## Project layout

- `main.py`: Qt application entrypoint
- `backend.py` + `backend_v04.py`: local desktop bridge
- `data_engine.py`, `analytics_engine.py`: data ingestion and descriptive analysis
- `ml_engine.py`: baseline model, evaluation, exploratory ranking
- `retention_store.py`: SQLite intervention log, keyed to dataset fingerprint
- `report_engine.py`: locally generated PDF / CSV reports
- `ui/`: QML screens, icon and controls
- `tests/`: pure Python integration and unit tests
