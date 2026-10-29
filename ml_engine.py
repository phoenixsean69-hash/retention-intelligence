"""Conservative tabular baseline: outcomes held out, customer IDs excluded.

A single cross-sectional dataset cannot validate a 30-day churn forecast.
The probability here measures model-estimated similarity to historical churn.
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score, average_precision_score, precision_score, recall_score, f1_score, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from data_engine import CustomerDataset, _key

# Explicit allowlist. Churn-related output/reason/label columns are not eligible.
SAFE_FEATURES = {
    'tenure', 'monthlycharges', 'totalcharges', 'contract', 'paymentmethod',
    'internetservice', 'techsupport', 'onlinesecurity', 'onlinebackup',
    'deviceprotection', 'paperlessbilling', 'seniorcitizen', 'partner',
    'dependents', 'multiplelines', 'streamingtv', 'streamingmovies',
    'phoneservice', 'deviceprotectiononlinebackup'
}
NUMERIC_FEATURES = {'tenure', 'monthlycharges', 'totalcharges', 'seniorcitizen'}


@dataclass
class TrainedModel:
    pipeline: Any
    feature_names: list[str]
    numeric: list[str]
    categorical: list[str]
    metrics: dict
    drivers: list[dict]
    version: str

    def _feature_frame(self, frame: pd.DataFrame) -> pd.DataFrame:
        X = frame[self.feature_names].copy()
        for col in self.numeric:
            X[col] = pd.to_numeric(X[col], errors='coerce')
        for col in self.categorical:
            X[col] = X[col].astype('string').fillna('Missing').astype(str)
        return X

    def predict(self, ds: CustomerDataset, limit: int = 50000) -> list[dict]:
        if len(ds.frame) > limit:
            raise ValueError(f'Bulk scoring capped at {limit:,} records in this version.')
        X = self._feature_frame(ds.frame)
        scores = self.pipeline.predict_proba(X)[:, 1]
        ids = ds.frame[ds.mapping['customer_id']].astype(str).values
        churn = ds.churn_series.values
        charges_col = ds.mapping.get('monthly_charges')
        charges = pd.to_numeric(ds.frame[charges_col], errors='coerce').fillna(0).values if charges_col else np.zeros(len(ds.frame))
        records = []
        for i, score in enumerate(scores):
            val = churn[i]
            # Those already known as churned are excluded from active retention queues.
            if val is True or val == True: continue
            records.append({'customerId': str(ids[i]), 'probability': round(float(score) * 100, 1), 'monthly': round(float(charges[i]), 2), 'outcome': 'Unknown' if pd.isna(val) else 'Retained'})
        return sorted(records, key=lambda x: x['probability'], reverse=True)


def train_model(ds: CustomerDataset) -> TrainedModel:
    if ds.frame[ds.mapping['customer_id']].astype(str).duplicated().any():
        raise ValueError('Duplicate customer IDs detected. Resolve duplicates before model training to avoid data leakage.')
    if 'churn' not in ds.mapping:
        raise ValueError('Training requires a recognized Churn column.')
    frame = ds.frame
    labels = ds.churn_series
    known = labels.notna()
    if int(known.sum()) < 50:
        raise ValueError('At least 50 labeled customers are required to train a model.')
    y = labels[known].astype(int)
    if len(y.value_counts()) != 2 or int(y.value_counts().min()) < 10:
        raise ValueError('At least 10 churned and 10 retained records are required.')
    # The common IBM sample contains derived post-outcome attributes. Exclude them.
    cols = [str(c) for c in frame.columns if _key(c) in SAFE_FEATURES and c not in {ds.mapping['churn'], ds.mapping['customer_id']}]
    if len(cols) < 2:
        raise ValueError('At least two usable pre-outcome customer feature columns are required.')
    nums = [c for c in cols if _key(c) in NUMERIC_FEATURES]
    cats = [c for c in cols if c not in nums]
    X = frame.loc[known, cols].copy()
    for c in nums: X[c] = pd.to_numeric(X[c], errors='coerce')
    for c in cats: X[c] = X[c].astype('string').fillna('Missing').astype(str)
    transformers = []
    if nums: transformers.append(('number', Pipeline([('impute', SimpleImputer(strategy='median', keep_empty_features=True)), ('scale', StandardScaler())]), nums))
    if cats: transformers.append(('category', Pipeline([('impute', SimpleImputer(strategy='most_frequent')), ('encode', OneHotEncoder(handle_unknown='ignore'))]), cats))
    estimator = Pipeline([('prep', ColumnTransformer(transformers)), ('classifier', LogisticRegression(max_iter=1000, class_weight='balanced', random_state=42))])
    Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, test_size=.25, random_state=42, stratify=y)
    estimator.fit(Xtrain, ytrain)
    p = estimator.predict_proba(Xtest)[:, 1]
    predictions = (p >= 0.5).astype(int)
    tn, fp, fn, tp = confusion_matrix(ytest, predictions, labels=[0,1]).ravel()
    score = {
        'rocAuc': round(float(roc_auc_score(ytest, p)), 3),
        'prAuc': round(float(average_precision_score(ytest, p)), 3),
        'precision': round(float(precision_score(ytest, predictions, zero_division=0)), 3),
        'recall': round(float(recall_score(ytest, predictions, zero_division=0)), 3),
        'f1': round(float(f1_score(ytest, predictions, zero_division=0)), 3),
        'trainRows': int(len(ytrain)), 'testRows': int(len(ytest)),
        'tp': int(tp), 'tn': int(tn), 'fp': int(fp), 'fn': int(fn),
        'features': len(cols), 'model': 'Logistic Regression',
        'trainedAt': datetime.now().strftime('%Y-%m-%d %H:%M'),
    }
    names = estimator.named_steps['prep'].get_feature_names_out()
    coefficients = estimator.named_steps['classifier'].coef_[0]
    ranked = sorted(zip(names, coefficients), key=lambda e: abs(e[1]), reverse=True)
    drivers = [{'name': str(n).replace('number__','').replace('category__',''), 'effect': 'Higher estimated churn' if float(w)>0 else 'Lower estimated churn', 'weight': round(float(abs(w)), 3)} for n,w in ranked[:10]]
    return TrainedModel(estimator, cols, nums, cats, score, drivers, datetime.now().strftime('%Y%m%d-%H%M%S'))
