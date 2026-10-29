"""Observed, descriptive analytics only: never manufacture longitudinal trends."""
from __future__ import annotations

import pandas as pd
from data_engine import CustomerDataset


def quality_report(ds: CustomerDataset) -> dict:
    frame = ds.frame
    ids = frame[ds.mapping['customer_id']]
    return {
        'rows': len(frame), 'columns': len(frame.columns),
        'missingCells': int(frame.isna().sum().sum()),
        'duplicateIds': int(ids.astype(str).duplicated().sum()),
        'unlabeled': int(ds.churn_series.isna().sum()),
        'recognized': len(ds.mapping),
    }


def segmentation(ds: CustomerDataset, dimension: str) -> list[dict]:
    frame = ds.frame
    churn = ds.churn_series
    if dimension == 'Contract':
        field = ds.mapping.get('contract')
        if not field: return []
        group = frame[field].fillna('Missing').astype(str)
    elif dimension == 'Payment method':
        field = ds.mapping.get('payment_method')
        if not field: return []
        group = frame[field].fillna('Missing').astype(str)
    elif dimension == 'Tenure':
        field = ds.mapping.get('tenure')
        if not field: return []
        values = pd.to_numeric(frame[field], errors='coerce')
        group = pd.cut(values, bins=[-float('inf'), 6, 12, 24, 48, float('inf')], labels=['0–6 months','7–12 months','13–24 months','25–48 months','49+ months']).astype(object).fillna('Missing')
    elif dimension == 'Monthly charges':
        field = ds.mapping.get('monthly_charges')
        if not field: return []
        values = pd.to_numeric(frame[field], errors='coerce')
        # Fixed bins in original source units, not a currency assertion.
        group = pd.cut(values, bins=[-float('inf'), 35, 65, 95, float('inf')], labels=['≤35','35–65','65–95','>95']).astype(object).fillna('Missing')
    else:
        return []
    results = []
    for name in group.drop_duplicates():
        mask = group == name
        observed = churn[mask].dropna()
        if observed.empty: continue
        churned = int((observed == True).sum())
        results.append({'name': str(name), 'count': len(observed), 'churned': churned, 'retained': int(len(observed)-churned), 'rate': round(100 * churned / len(observed), 1)})
    return sorted(results, key=lambda item: item['rate'], reverse=True)[:12]
