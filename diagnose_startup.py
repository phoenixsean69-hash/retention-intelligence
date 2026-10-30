"""Non-destructive subprocess probes for Retention Intelligence Qt access violations.

Run from project root: python -u diagnose_startup.py
Each case runs in its own process: a Windows native crash doesn't stop the suite.
The script does not replace app files or delete customer records.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PROJECT = Path(__file__).resolve().parent
LOADER_EXPRESSION = ('source: ["OverviewPage.qml", "CustomersPage.qml", '
                     '"AnalysisPage.qml", "PredictionPage.qml", "RetentionPage.qml", '
                     '"DataPage.qml", "ModelLabPage.qml", "ReportsPage.qml", '
                     '"SettingsPage.qml"][appWindow.activePage]')
CASES = [
    ("qt", "Qt engine / minimal QML"),
    ("old", "Original backend / minimal QML"),
    ("new", "V0.4 backend / minimal QML"),
    ("shell", "V0.4 shell without page content"),
    ("overview", "V0.4 shell with Overview page"),
    ("full", "Full V0.4 application"),
]


def probe(name: str) -> int:
    import faulthandler
    faulthandler.enable()
    import PySide6
    from PySide6.QtCore import QUrl
    from PySide6.QtQml import QQmlApplicationEngine
    from PySide6.QtWidgets import QApplication

    print(f"PySide6 {PySide6.__version__} | probe={name}", flush=True)
    app = QApplication([sys.argv[0]])
    engine = QQmlApplicationEngine()
    if name != "qt":
        if name == "old":
            from backend import Backend
            backend = Backend()
        else:
            from backend_v04 import DesktopBackend
            backend = DesktopBackend()
        engine.rootContext().setContextProperty("backend", backend)
        print("Backend initialized", flush=True)

    if name in ("qt", "old", "new"):
        expressions = {
            "qt": "property string message: 'running'",
            "old": "property string label: backend.dataName; property bool hasDataset: backend.hasData",
            "new": "property bool ready: backend.modelReady; property int count: backend.riskCount; property var segments: backend.contractSegments",
        }
        source = ("import QtQuick\nimport QtQuick.Controls\n"
                  "ApplicationWindow { visible: false; width: 320; height: 240; "
                  + expressions[name] + " }")
        print("Loading minimal QML", flush=True)
        engine.loadData(source.encode("utf-8"))
    elif name in ("shell", "overview"):
        with tempfile.TemporaryDirectory(prefix="retention-startup-") as directory:
            target = Path(directory) / "ui"
            shutil.copytree(PROJECT / "ui", target)
            qml = target / "Main.qml"
            source = qml.read_text(encoding="utf-8")
            if LOADER_EXPRESSION not in source:
                print("Diagnostic could not identify Main.qml Loader expression", flush=True)
                return 3
            replacement = 'source: ""' if name == "shell" else 'source: "OverviewPage.qml"'
            qml.write_text(source.replace(LOADER_EXPRESSION, replacement), encoding="utf-8")
            print("Loading temporarily isolated QML", flush=True)
            engine.load(QUrl.fromLocalFile(str(qml)))
            print("Root objects:", len(engine.rootObjects()), flush=True)
            app.processEvents()
            return 0 if engine.rootObjects() else 4
    else:
        print("Loading complete Main.qml", flush=True)
        engine.load(QUrl.fromLocalFile(str(PROJECT / "ui" / "Main.qml")))

    print("Root objects:", len(engine.rootObjects()), flush=True)
    app.processEvents()
    return 0 if engine.rootObjects() else 4


def main() -> int:
    if len(sys.argv) == 3 and sys.argv[1] == "--probe":
        return probe(sys.argv[2])
    if not (PROJECT / "ui" / "Main.qml").is_file():
        print("Place diagnose_startup.py beside main.py in the project root.")
        return 2
    environment = os.environ.copy()
    for key in ("QSG_RHI_BACKEND", "QT_QUICK_BACKEND", "QT_LOGGING_RULES"):
        environment.pop(key, None)
    output = []
    print("Retention Intelligence startup diagnostic\n", flush=True)
    for code, label in CASES:
        print(f"=== {label} ===", flush=True)
        command = [sys.executable, "-u", "-X", "faulthandler", str(PROJECT / "diagnose_startup.py"), "--probe", code]
        try:
            result = subprocess.run(command, cwd=PROJECT, env=environment, capture_output=True,
                                    encoding="utf-8", errors="replace", text=True, timeout=30)
            state = "PASS" if result.returncode == 0 else f"FAILED (exit {result.returncode})"
            details = (result.stdout + "\n" + result.stderr).strip()
        except subprocess.TimeoutExpired:
            state, details = "TIMED OUT", ""
        print(state, flush=True)
        if details:
            print(details[-2800:], flush=True)
        output.extend([label + ": " + state, details[-2800:]])
    (PROJECT / "startup-diagnostic.txt").write_text("\n\n".join(output), encoding="utf-8")
    print("\nSaved startup-diagnostic.txt", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
