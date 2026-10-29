"""Thin QML bridge; numerical logic stays in data_engine.py."""
from __future__ import annotations

import json
import os
from pathlib import Path
import shutil

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtWidgets import QFileDialog

from data_engine import CustomerDataset


def _app_dir() -> Path:
    base = Path(os.environ.get("LOCALAPPDATA", str(Path.home())))
    return base / "RetentionIntelligence"


class Backend(QObject):
    changed = Signal()

    def __init__(self):
        super().__init__()
        self._data: CustomerDataset | None = None
        self._query = ""
        self._filter = "All customers"
        self._page = 0
        self._error = ""
        self._app_path = _app_dir()
        self._settings_file = self._app_path / "settings.json"
        try:
            if self._settings_file.exists():
                saved = json.loads(self._settings_file.read_text(encoding="utf-8"))
                path = Path(saved.get("dataset_path", ""))
                if path.is_file():
                    self._data = CustomerDataset.from_file(path)
                    self._data.file_name = saved.get("original_name", path.name)
        except Exception as exc:
            self._error = f"Previous dataset could not be restored: {exc}"

    @Property(bool, notify=changed)
    def hasData(self):
        return self._data is not None

    @Property(bool, notify=changed)
    def isDemo(self):
        return bool(self._data and self._data.file_name.startswith("DEMO_SYNTHETIC"))

    @Property(str, notify=changed)
    def dataName(self):
        return self._data.file_name if self._data else "No dataset imported"

    @Property(str, notify=changed)
    def errorText(self):
        return self._error

    @Property(str, notify=changed)
    def totalCustomers(self):
        return f"{self._data.metrics['total']:,}" if self._data else "—"

    @Property(str, notify=changed)
    def churnRate(self):
        if not self._data or self._data.metrics['rate'] is None:
            return "—"
        return f"{self._data.metrics['rate']:.1f}%"

    @Property(str, notify=changed)
    def churnedCustomers(self):
        if not self._data or not self._data.metrics['known']:
            return "—"
        return f"{self._data.metrics['churned']:,}"

    @Property(str, notify=changed)
    def monthlyAssociated(self):
        """Currency intentionally omitted; source dataset units may vary."""
        if not self._data or self._data.metrics['monthly_associated'] is None:
            return "—"
        return f"{self._data.metrics['monthly_associated']:,.2f}"

    @Property('QVariantMap', notify=changed)
    def summary(self):
        return self._data.metrics if self._data else {"total": 0, "known": 0, "churned": 0, "retained": 0, "unknown": 0, "columns": 0}

    @Property('QVariantList', notify=changed)
    def contractStats(self):
        return self._data.contract_stats if self._data else []

    @Property('QVariantList', notify=changed)
    def visibleCustomers(self):
        if not self._data:
            return []
        return self._data.preview(self._query, self._filter, self._page)[0]

    @Property(int, notify=changed)
    def pageNumber(self):
        if not self._data:
            return 0
        _, _, _ = self._data.preview(self._query, self._filter, self._page)
        return self._page + 1

    @Property(int, notify=changed)
    def pageCount(self):
        return self._data.preview(self._query, self._filter, self._page)[1] if self._data else 0

    @Property(int, notify=changed)
    def filteredCount(self):
        return self._data.preview(self._query, self._filter, self._page)[2] if self._data else 0

    @Slot()
    def openDataset(self):
        name, _ = QFileDialog.getOpenFileName(None, "Select customer dataset", str(Path.home()), "Data files (*.csv *.xlsx *.xlsm)")
        if name:
            self.importPath(name)

    @Slot(str)
    def importPath(self, path: str):
        try:
            source = Path(path)
            # Validate before changing the existing working dataset.
            CustomerDataset.from_file(source)
            self._app_path.mkdir(parents=True, exist_ok=True)
            dest = self._app_path / ("current_dataset" + source.suffix.lower())
            if source.resolve() != dest.resolve():
                shutil.copy2(source, dest)
            loaded = CustomerDataset.from_file(dest)
            for old_file in self._app_path.glob("current_dataset.*"):
                if old_file != dest and old_file.is_file():
                    old_file.unlink(missing_ok=True)
            self._settings_file.write_text(json.dumps({"dataset_path": str(dest), "original_name": source.name}), encoding="utf-8")
            self._data = loaded
            self._data.file_name = source.name
            self._query = ""
            self._filter = "All customers"
            self._page = 0
            self._error = ""
            self.changed.emit()
        except Exception as exc:
            self._error = str(exc)
            self.changed.emit()

    @Slot(str)
    def searchCustomers(self, value):
        self._query = value
        self._page = 0
        self.changed.emit()

    @Slot(str)
    def filterCustomers(self, value):
        self._filter = value
        self._page = 0
        self.changed.emit()

    @Slot(int)
    def movePage(self, amount):
        if self._data:
            last = self._data.preview(self._query, self._filter, self._page)[1] - 1
            self._page = max(0, min(last, self._page + amount))
            self.changed.emit()

    @Slot()
    def exportCustomers(self):
        if not self._data:
            return
        name, _ = QFileDialog.getSaveFileName(None, "Export filtered customers", "customers_export.csv", "CSV files (*.csv)")
        if name:
            try:
                self._data.subset(self._query, self._filter).to_csv(name, index=False)
                self._error = ""
            except Exception as exc:
                self._error = f"Export failed: {exc}"
            self.changed.emit()

    @Slot()
    def clearDataset(self):
        # Avoid deleting customer files without explicit user action in the UI.
        self._data = None
        self._query = ""
        self._filter = "All customers"
        self._page = 0
        self._error = ""
        if self._settings_file.exists():
            try:
                config = json.loads(self._settings_file.read_text(encoding="utf-8"))
                path = Path(config.get("dataset_path", ""))
                if path.parent == self._app_path and path.name.startswith("current_dataset"):
                    path.unlink(missing_ok=True)
                self._settings_file.unlink(missing_ok=True)
            except OSError as exc:
                self._error = f"Could not remove persisted file: {exc}"
        self.changed.emit()
