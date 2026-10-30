"""Bridge for v0.4 operational modules; v0.3 import and explorer remain intact."""
from __future__ import annotations

import hashlib
import json
import pickle
from pathlib import Path
from PySide6.QtCore import QObject, Property, Signal, Slot, QThread
from PySide6.QtWidgets import QFileDialog
from backend import Backend
from overview_engine import overview_metrics
from analytics_engine import quality_report, segmentation, prevention_recommendations
from data_engine import CustomerDataset
from ml_engine import train_model
from report_engine import export_pdf, export_segments_csv
from retention_store import CaseStore


class TrainWorker(QObject):
    ready = Signal(object)
    failed = Signal(str)
    def __init__(self, ds):
        super().__init__()
        self.ds = ds

    @Slot()
    def run(self):
        try:
            model = train_model(self.ds)
            scores = model.predict(self.ds)
            self.ready.emit((model, scores))
        except Exception as exc:
            self.failed.emit(str(exc))


class DesktopBackend(Backend):
    stateChanged = Signal()

    def __init__(self):
        super().__init__()
        self.changed.connect(self.stateChanged)
        self._cases = CaseStore(self._app_path / 'retention_cases.sqlite')
        self._prefs_path = self._app_path / 'preferences.json'
        self._model_cache_path = self._app_path / 'cached_model.pkl'
        self._prefs = {'risk_threshold': 65, 'currency_label': 'Source units', 'compact_rows': False}
        try:
            if self._prefs_path.exists():
                saved = json.loads(self._prefs_path.read_text(encoding='utf-8'))
                for key in self._prefs:
                    if key in saved:
                        self._prefs[key] = saved[key]
        except (ValueError, OSError, TypeError):
            pass
        self._model = None
        self._scores = []
        self._training = False
        self._modelMessage = 'Train a model in Model Lab to enable customer risk scoring.'
        self._selected_customer = ''
        self._thread = None
        self._worker = None
        self._dataset_fingerprint = self._fingerprint()
        self._notice = ''
        self._restore_model_cache()

    def _fingerprint(self):
        if not self._data:
            return ''
        try:
            cfg = json.loads(self._settings_file.read_text(encoding='utf-8'))
            path = Path(cfg['dataset_path'])
            h = hashlib.sha256()
            with path.open('rb') as f:
                for part in iter(lambda: f.read(1024 * 1024), b''):
                    h.update(part)
            return h.hexdigest()[:24]
        except (OSError, KeyError, ValueError):
            return ''

    def _persist_model_cache(self):
        if not (self._model and self._dataset_fingerprint):
            return
        payload = {
            'fingerprint': self._dataset_fingerprint,
            'model': self._model,
            'scores': self._scores,
        }
        self._app_path.mkdir(parents=True, exist_ok=True)
        with self._model_cache_path.open('wb') as fh:
            pickle.dump(payload, fh)

    def _restore_model_cache(self):
        if not (self._data and self._dataset_fingerprint and self._model_cache_path.exists()):
            return
        try:
            with self._model_cache_path.open('rb') as fh:
                payload = pickle.load(fh)
            if payload.get('fingerprint') == self._dataset_fingerprint:
                self._model = payload.get('model')
                self._scores = payload.get('scores', [])
                if self._model:
                    self._modelMessage = f"Model {self._model.version} restored from local cache."
        except Exception:
            pass

    def _clear_model_cache(self):
        try:
            self._model_cache_path.unlink(missing_ok=True)
        except OSError:
            pass

    @Slot(str)
    def importPath(self, path):
        if self._training:
            self._notice = 'A training job is running. Finish training before replacing the dataset.'
            self.changed.emit()
            return
        super().importPath(path)
        if not self._error:
            self._dataset_fingerprint = self._fingerprint()
            self._model = None
            self._scores = []
            self._modelMessage = 'Dataset changed. Train or restore a model before predicting.'
            self._restore_model_cache()
            self.changed.emit()

    @Slot()
    def clearDataset(self):
        if self._training:
            self._notice = 'Finish model training before removing the dataset.'
            self.changed.emit()
            return
        super().clearDataset()
        self._dataset_fingerprint = ''
        self._model = None
        self._scores = []
        self._notice = ''
        self._clear_model_cache()
        self.changed.emit()

    @Property('QVariantMap', notify=stateChanged)
    def overviewVisuals(self):
        return overview_metrics(self._data, self._scores, self.riskThreshold)

    @Property('QVariantMap', notify=stateChanged)
    def dataQuality(self):
        return quality_report(self._data) if self._data else {'rows': 0, 'columns': 0, 'missingCells': 0, 'duplicateIds': 0, 'unlabeled': 0, 'recognized': 0}

    @Property('QVariantList', notify=stateChanged)
    def segmentationTypes(self):
        return ['Contract', 'Tenure', 'Monthly charges', 'Payment method']

    @Slot(str, result='QVariantList')
    def getSegments(self, key):
        return segmentation(self._data, key) if self._data else []

    @Property('QVariantList', notify=stateChanged)
    def contractSegments(self):
        return self.getSegments('Contract')

    @Property('QVariantList', notify=stateChanged)
    def tenureSegments(self):
        return self.getSegments('Tenure')

    @Property('QVariantList', notify=stateChanged)
    def chargeSegments(self):
        return self.getSegments('Monthly charges')

    @Property('QVariantList', notify=stateChanged)
    def paymentSegments(self):
        return self.getSegments('Payment method')

    @Property('QVariantList', notify=stateChanged)
    def preventionRecommendations(self):
        return prevention_recommendations(self._data) if self._data else []

    @Property(bool, notify=stateChanged)
    def modelReady(self):
        return self._model is not None

    @Property(bool, notify=stateChanged)
    def modelTraining(self):
        return self._training

    @Property(str, notify=stateChanged)
    def modelMessage(self):
        return self._modelMessage

    @Property('QVariantMap', notify=stateChanged)
    def modelMetrics(self):
        return self._model.metrics if self._model else {}

    @Property('QVariantList', notify=stateChanged)
    def modelDrivers(self):
        return self._model.drivers if self._model else []

    @Property(str, notify=stateChanged)
    def modelVersion(self):
        return self._model.version if self._model else 'Not trained'

    @Property(int, notify=stateChanged)
    def riskThreshold(self):
        return int(self._prefs['risk_threshold'])

    @Property(str, notify=stateChanged)
    def currencyLabel(self):
        return str(self._prefs['currency_label'])

    @Property(bool, notify=stateChanged)
    def compactRows(self):
        return bool(self._prefs['compact_rows'])

    @Property(str, notify=stateChanged)
    def noticeText(self):
        return self._notice

    @Property('QVariantList', notify=stateChanged)
    def visibleCustomers(self):
        if not self._data:
            return []
        rows, _, _ = self._data.preview(self._query, self._filter, self._page)
        risk_map = {row['customerId'].lower(): row for row in self._scores}
        merged = []
        for row in rows:
            risk = risk_map.get(row['customerId'].lower())
            row = dict(row)
            row['risk'] = risk.get('probability') if risk else None
            row['riskText'] = f"{risk['probability']:.1f}%" if risk else '—'
            merged.append(row)
        return merged

    @Property(int, notify=stateChanged)
    def riskCount(self):
        return sum(1 for c in self._scores if c['probability'] >= self.riskThreshold)

    @Property(int, notify=stateChanged)
    def scoredCount(self):
        return len(self._scores)

    @Property(str, notify=stateChanged)
    def riskPercentage(self):
        if not self._scores:
            return '—'
        return f"{(100.0 * self.riskCount / max(1, len(self._scores))):.1f}%"

    @Slot(int)
    def setRiskThreshold(self, v):
        self._prefs['risk_threshold'] = max(10, min(95, int(v)))
        self._savePrefs()

    @Slot(str)
    def setCurrencyLabel(self, label):
        if label not in {'Source units', 'USD', 'ZIG', 'EUR', 'GBP'}:
            return
        self._prefs['currency_label'] = label
        self._savePrefs()

    @Slot(bool)
    def setCompactRows(self, v):
        self._prefs['compact_rows'] = bool(v)
        self._savePrefs()

    def _savePrefs(self):
        self._prefs_path.write_text(json.dumps(self._prefs, indent=2), encoding='utf-8')
        self._notice = 'Preferences saved on this computer.'
        self.changed.emit()

    @Slot()
    def startTraining(self):
        if self._training:
            return
        if self._data is None:
            self._modelMessage = 'Import a dataset before training.'
            self.changed.emit()
            return
        self._training = True
        self._modelMessage = 'Training Logistic Regression and evaluating a 25% stratified holdout…'
        self.changed.emit()
        snapshot = CustomerDataset(self._data.frame.copy(deep=True), dict(self._data.mapping), self._data.file_name)
        thread = QThread(self)
        worker = TrainWorker(snapshot)
        worker.moveToThread(thread)
        thread.started.connect(worker.run)
        worker.ready.connect(self._trainingSucceeded)
        worker.failed.connect(self._trainingFailed)
        worker.ready.connect(thread.quit)
        worker.failed.connect(thread.quit)
        thread.finished.connect(worker.deleteLater)
        thread.finished.connect(thread.deleteLater)
        thread.finished.connect(self._releaseWorker)
        self._thread = thread
        self._worker = worker
        thread.start()

    def _releaseWorker(self):
        self._thread = None
        self._worker = None

    @Slot(object)
    def _trainingSucceeded(self, payload):
        model, scores = payload
        self._model = model
        self._scores = scores
        self._training = False
        self._modelMessage = f"Model {model.version} trained and saved locally."
        self._notice = 'Model trained successfully. It will be restored automatically the next time this same dataset is opened.'
        self._persist_model_cache()
        self.changed.emit()

    @Slot(str)
    def _trainingFailed(self, error):
        self._training = False
        self._modelMessage = 'Training failed: ' + error
        self.changed.emit()

    @Property('QVariantList', notify=stateChanged)
    def riskCustomers(self):
        return [{**item, 'riskLabel': ('High' if item['probability'] >= self.riskThreshold else 'Below threshold')} for item in self._scores[:60]]

    @Slot(str, result='QVariantMap')
    def customerRisk(self, customer_id):
        needle = customer_id.strip().lower()
        for record in self._scores:
            if record['customerId'].lower() == needle:
                return record
        return {}

    @Property('QVariantList', notify=stateChanged)
    def retentionCases(self):
        return self._cases.list(self._dataset_fingerprint) if self._dataset_fingerprint else []

    @Property(int, notify=stateChanged)
    def openCaseCount(self):
        return sum(1 for row in self.retentionCases if row['status'] in {'Open', 'Contacted'})

    @Slot(str, str, str)
    def createCase(self, customer_id, action, note):
        def normalize_customer_id(raw: str) -> str:
            raw = (raw or "").strip().upper()
            compact = "".join(ch for ch in raw if ch.isalnum())

            if compact.startswith("DEMO") and compact[4:].isdigit():
                return f"DEMO-{int(compact[4:]):04d}"

            return raw

        cleaned_id = normalize_customer_id(customer_id)

        if not self._data:
            self._notice = 'Import customer data before creating a retention case.'
        elif not cleaned_id:
            self._notice = 'Enter a customer ID.'
        elif not self._dataset_fingerprint:
            self._notice = 'Dataset identity unavailable. Reimport your dataset.'
        else:
            actual_ids = self._data.frame[self._data.mapping['customer_id']].astype(str)
            matches = actual_ids[actual_ids.str.upper() == cleaned_id]

            if matches.empty:
                self._notice = f'Customer ID not found: {cleaned_id}'
            elif self._data.churn_series.loc[matches.index[0]] == True:
                self._notice = 'This customer is already labeled churned. Retention cases are for retained or unlabeled customers.'
            else:
                self._cases.create(
                    self._dataset_fingerprint,
                    str(matches.iloc[0]),
                    action or 'Review account',
                    note[:1000]
                )
                self._notice = f'Retention case created for {matches.iloc[0]}.'

        self.changed.emit()

    @Slot(int, str)
    def updateCase(self, case_id, status):
        try:
            self._cases.change_status(self._dataset_fingerprint, case_id, status)
            self._notice = f'Case #{case_id} updated to {status}.'
        except Exception as exc:
            self._notice = str(exc)
        self.changed.emit()

    @Slot()
    def exportAnalysisPdf(self):
        if not self._data:
            self._notice = 'Import a dataset to generate a report.'
            self.changed.emit()
            return
        target, _ = QFileDialog.getSaveFileName(None, 'Export churn report', 'churn_analysis.pdf', 'PDF files (*.pdf)')
        if target:
            try:
                export_pdf(target, self._data, self.modelMetrics if self._model else None)
                self._notice = 'PDF exported: ' + target
            except Exception as exc:
                self._notice = 'PDF export failed: ' + str(exc)
            self.changed.emit()

    @Slot()
    def exportSegmentsCsv(self):
        if not self._data:
            self._notice = 'Import a dataset to export segments.'
            self.changed.emit()
            return
        target, _ = QFileDialog.getSaveFileName(None, 'Export segments', 'churn_segments.csv', 'CSV files (*.csv)')
        if target:
            try:
                export_segments_csv(target, self._data)
                self._notice = 'Segment CSV exported: ' + target
            except Exception as exc:
                self._notice = 'CSV export failed: ' + str(exc)
            self.changed.emit()

    @Slot()
    def exportRiskCsv(self):
        if not self._scores:
            self._notice = 'Train a model before exporting risk scores.'
            self.changed.emit()
            return
        target, _ = QFileDialog.getSaveFileName(None, 'Export risk ranking', 'risk_ranking.csv', 'CSV files (*.csv)')
        if target:
            import pandas as pd
            try:
                rows = [{**x, 'modelVersion': self.modelVersion, 'riskThreshold': self.riskThreshold} for x in self._scores]
                pd.DataFrame(rows).to_csv(target, index=False)
                self._notice = 'Risk CSV exported: ' + target
            except Exception as exc:
                self._notice = 'Risk export failed: ' + str(exc)
            self.changed.emit()
