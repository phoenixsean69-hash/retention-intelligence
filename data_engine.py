"""Dataset processing; no Qt dependencies so analytics can be tested independently."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import pandas as pd


def _key(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", str(value).lower())

ALIASES = {
    "customer_id": ("customerID", "customer_id", "customer id", "accountid", "id"),
    "churn": ("Churn", "Churn Value", "Churn Label", "churned", "is_churned"),
    "tenure": ("tenure", "tenure months", "tenure_months"),
    "contract": ("Contract", "contract_type", "contract type"),
    "monthly_charges": ("MonthlyCharges", "Monthly Charges", "monthly_charges"),
    "total_charges": ("TotalCharges", "Total Charges", "total_charges"),
    "payment_method": ("PaymentMethod", "Payment Method", "payment_method"),
}


def _churn_value(value: object) -> bool | None:
    if pd.isna(value):
        return None
    text = str(value).strip().lower()
    if text in {"yes", "1", "true", "churned", "left", "y"}:
        return True
    if text in {"no", "0", "false", "retained", "stayed", "n"}:
        return False
    return None


@dataclass
class CustomerDataset:
    frame: pd.DataFrame
    mapping: dict[str, str]
    file_name: str

    @classmethod
    def from_file(cls, path: str | Path) -> "CustomerDataset":
        path = Path(path)
        if path.suffix.lower() == ".csv":
            try:
                frame = pd.read_csv(path, low_memory=False, encoding="utf-8-sig")
            except UnicodeDecodeError:
                frame = pd.read_csv(path, low_memory=False, encoding="cp1252")
        elif path.suffix.lower() in {".xlsx", ".xlsm"}:
            frame = pd.read_excel(path, engine="openpyxl")
        else:
            raise ValueError("Please select a CSV or Excel (.xlsx/.xlsm) file.")
        if frame.empty:
            raise ValueError("The selected dataset has no customer rows.")
        if len(frame.columns) < 2:
            raise ValueError("At least two columns are required.")
        if len(frame) > 1_000_000:
            raise ValueError("This starter build accepts up to 1,000,000 rows.")
        normalized = {_key(name): name for name in frame.columns}
        mapping = {}
        for canonical, alternatives in ALIASES.items():
            for alias in alternatives:
                column = normalized.get(_key(alias))
                if column is not None:
                    mapping[canonical] = column
                    break
        if "customer_id" not in mapping:
            raise ValueError("Customer ID column not detected (e.g. customerID, Customer ID).")
        return cls(frame, mapping, path.name)

    @property
    def churn_series(self) -> pd.Series:
        if "churn" not in self.mapping:
            return pd.Series([None] * len(self.frame), index=self.frame.index, dtype=object)
        return self.frame[self.mapping["churn"]].map(_churn_value)

    @property
    def metrics(self) -> dict:
        series = self.churn_series
        known = series.notna()
        churned = (series == True).sum()  # noqa: E712
        retained = (series == False).sum()  # noqa: E712
        monthly_total = None
        if "monthly_charges" in self.mapping:
            charges = pd.to_numeric(self.frame[self.mapping["monthly_charges"]], errors="coerce")
            if known.any():
                monthly_total = float(charges[series == True].sum())  # noqa: E712
        return {
            "total": int(len(self.frame)),
            "known": int(known.sum()),
            "churned": int(churned),
            "retained": int(retained),
            "unknown": int((~known).sum()),
            "rate": (float(churned) / int(known.sum()) * 100) if known.any() else None,
            "monthly_associated": monthly_total,
            "columns": int(len(self.frame.columns)),
        }

    @property
    def contract_stats(self) -> list[dict]:
        if "contract" not in self.mapping or "churn" not in self.mapping:
            return []
        result = []
        values = self.frame[self.mapping["contract"]].fillna("Missing").astype(str)
        series = self.churn_series
        for label, subset in values.groupby(values, sort=False):
            indices = subset.index
            observed = series.loc[indices].dropna()
            count = len(observed)
            if count:
                result.append({
                    "name": str(label),
                    "count": int(count),
                    "churned": int((observed == True).sum()),  # noqa: E712
                    "rate": round(float((observed == True).mean() * 100), 1),  # noqa: E712
                })
        return sorted(result, key=lambda row: row["rate"], reverse=True)[:7]

    def subset(self, query: str = "", churn_filter: str = "All customers") -> pd.DataFrame:
        frame = self.frame
        query = query.strip()
        if query:
            identifiers = frame[self.mapping["customer_id"]].fillna("").astype(str)
            mask = identifiers.str.contains(query, case=False, regex=False)
            # Search is intentionally limited to IDs in V0.1 for performance and privacy.
            frame = frame.loc[mask]
        if "churn" in self.mapping:
            values = self.churn_series.loc[frame.index]
            if churn_filter == "Churned":
                frame = frame.loc[values == True]  # noqa: E712
            elif churn_filter == "Retained":
                frame = frame.loc[values == False]  # noqa: E712
        return frame

    def preview(self, query: str = "", churn_filter: str = "All customers", page: int = 0, page_size: int = 12) -> tuple[list[dict], int, int]:
        frame = self.subset(query, churn_filter)
        total = len(frame)
        pages = max(1, (total + page_size - 1) // page_size)
        page = max(0, min(page, pages - 1))
        selected = frame.iloc[page * page_size:(page + 1) * page_size]
        churn = self.churn_series
        result = []
        for idx, row in selected.iterrows():
            def cell(column: str, missing="—"):
                key = self.mapping.get(column)
                value = row.get(key) if key else None
                return missing if pd.isna(value) else str(value)
            status = churn.loc[idx]
            result.append({
                "customerId": cell("customer_id"),
                "contract": cell("contract"),
                "tenure": cell("tenure"),
                "monthly": cell("monthly_charges"),
                "status": "Unknown" if pd.isna(status) else ("Churned" if status else "Retained"),
            })
        return result, pages, total
