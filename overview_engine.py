"""Snapshot-only overview aggregates. No fabricated trends or forecasts."""
from __future__ import annotations

import pandas as pd


def overview_metrics(ds, scores=None, risk_threshold=65):
    empty = {
        'retainedPct': 0.0, 'churnedPct': 0.0, 'unknownPct': 0.0,
        'observedPct': 0.0, 'churnChargePct': 0.0,
        'atRiskPct': 0.0, 'atRiskCount': 0, 'scoredCount': 0,
        'retainedCharges': 0.0, 'churnedCharges': 0.0, 'knownCharges': 0.0,
        'riskBands': [],
    }
    if ds is None:
        return empty
    scores = list(scores or [])
    metrics = ds.metrics
    total = max(1, metrics['total'])
    known = metrics['known']
    output = {
        **empty,
        'retainedPct': round(100.0 * metrics['retained'] / total, 1),
        'churnedPct': round(100.0 * metrics['churned'] / total, 1),
        'unknownPct': round(100.0 * metrics['unknown'] / total, 1),
        'observedPct': round(100.0 * metrics['churned'] / known, 1) if known else 0.0,
    }
    column = ds.mapping.get('monthly_charges')
    if column:
        values = pd.to_numeric(ds.frame[column], errors='coerce')
        states = ds.churn_series
        churned = float(values.loc[states == True].sum())
        retained = float(values.loc[states == False].sum())
        known_charges = churned + retained
        output.update({
            'churnedCharges': round(churned, 2),
            'retainedCharges': round(retained, 2),
            'knownCharges': round(known_charges, 2),
            'churnChargePct': round(100.0 * churned / known_charges, 1) if known_charges > 0 else 0.0,
        })
    output['scoredCount'] = len(scores)
    output['atRiskCount'] = sum(1 for item in scores if float(item.get('probability', 0)) >= risk_threshold)
    output['atRiskPct'] = round(100.0 * output['atRiskCount'] / len(scores), 1) if scores else 0.0
    ranges = [(0, 25, '0–24%'), (25, 50, '25–49%'), (50, 75, '50–74%'), (75, 101, '75–100%')]
    output['riskBands'] = [{
        'label': label,
        'count': sum(1 for item in scores if lo <= float(item.get('probability', 0)) < hi),
    } for lo, hi, label in ranges] if scores else []
    return output
