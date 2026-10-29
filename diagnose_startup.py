"""Isolate Windows PySide6/QML startup crashes without editing application files.

Run: python -u diagnose_startup.py
Each probe is a separate process so native access violations do not stop the suite.
This diagnostic does not remove or replace customer data. It may initialize the
existing local application database, as DesktopBackend normally does.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
QML_SOURCE = 'source: ["OverviewPage.qml", "CustomersPage.qml", "AnalysisPage.qml", "PredictionPage.qml", "RetentionPage.qml", "DataPage.qml", "ModelLabPage.qml", "ReportsPage.qml", "SettingsPage.qml"][appWindow.activePage]'
CASES = [
    ("qt", "Minimal Qt/QML runtime"),
    ("base", "V0.3 backend with minimal QML"),
    ("v04", "V0.4 backend with minimal QML"),
    ("shell", "V0.4 main shell, without a page"),
    ("overview", "V0.4 shell with Overview page"),
    ("full_base", "V0.4 QML with old backend"),
    ("full", "Complete V0.4 application"),
]


def child(case: str) -> int:
    import faulthandler
    faulthandler.enable()
    import PySide6
    from PySide6.QtCore import QUrl
    from PySide6.QtQml import QQmlApplicationEngine
    from PySide6.QtWidgets import QApplication

    print("PySide6:", PySide6.__version__, "| case:", case, flush=True)
    app = QApplication([sys.argv[0]])
    engine = QQmlApplicationEngine()

    if case != "qt":
        from backend import Backend
        if case in ("base", "full_base"):
            backend = Backend()
        else:
            from backend_v04 import DesktopBackend
            backend = DesktopBackend()
        print("Backend constructed:", type(backend).__name__, flush=True)
        engine.rootContext().setContextProperty("backend", backend)

    if case in ("qt", "base", "v04"):
        if case == "qt":
            qml = b'import QtQuick\nimport QtQuick.Controls\nApplicationWindow { visible: false; width: 300; height: 200 }'
        elif case == "base":
            qml = b'import QtQuick\nimport QtQuick.Controls\nApplicationWindow { visible: false; property bool hasDataset: backend.hasData; property string dataset: backend.dataName }'
        else:
            qml = b'import QtQuick\nimport QtQuick.Controls\nApplicationWindow { visible: false; property bool trained: backend.modelReady; property int count: backend.riskCount; property var segments: backend.contractSegments }'
        print("Before QML loadData", flush=True)
        engine.loadData(qml)
    elif case in ("shell", "overview"):
        with tempfile.TemporaryDirectory(prefix="ri_startup_") as directory:
            target = Path(directory) / "ui"
            shutil.copytree(ROOT / "ui", target)
            main = target / "Main.qml"
            source = main.read_text(encoding="utf-8")
            if QML_SOURCE not in source:
                print("Probe cannot match Main.qml page source; update the diagnostic.", flush=True)
                return 3
            replacement = 'source: ""' if case == "shell" else 'source: "OverviewPage.qml"'
            main.write_text(source.replace(QML_SOURCE, replacement), encoding="utf-8")
            print("Before QML load:", case, flush=True)
            engine.load(QUrl.fromLocalFile(str(main)))
            print("QML objects:", len(engine.rootObjects()), flush=True)
            app.processEvents()
            return 0 if engine.rootObjects() else 4
    else:
        print("Before QML load: full Main.qml", flush=True)
        engine.load(QUrl.fromLocalFile(str(ROOT / "ui" / "Main.qml")))

    print("QML objects:", len(engine.rootObjects()), flush=True)
    app.processEvents()
    return 0 if engine.rootObjects() else 4


def main() -> int:
    if len(sys.argv) == 3 and sys.argv[1] == "--case":
        return child(sys.argv[2])

    if not (ROOT / "ui" / "Main.qml").exists():
        print("Run this script from the Retention Intelligence project root.")
        return 2

    print("STARTUP DIAGNOSTIC |", ROOT, flush=True)
    report = ["Retention Intelligence Windows startup diagnostic"]
    environment = os.environ.copy()
    for key in ("QSG_RHI_BACKEND", "QT_QUICK_BACKEND", "QT_LOGGING_RULES"):
        environment.pop(key, None)

    for code, description in CASES:
        print("\n==", description, "==", flush=True)
        try:
            result = subprocess.run(
                [sys.executable, "-u", "-X", "faulthandler", str(ROOT / "diagnose_startup.py"), "--case", code],
                cwd=ROOT,
                env=environment,
                encoding="utf-8", errors="replace",
                capture_output=True, text=True, timeout=25,
            )
            status = "PASS" if result.returncode == 0 else f"FAILED (exit {result.returncode})"
            message = (result.stdout + "\n" + result.stderr).strip()[-2400:]
        except subprocess.TimeoutExpired:
            status = "TIMED OUT"
            message = ""
        print(status, flush=True)
        if message:
            print(message, flush=True)
        report.extend([description + ": " + status, message])

    output = ROOT / "startup-diagnostic.txt"
    output.write_text("\n\n".join(report), encoding="utf-8")
    print("\nSaved:", output, flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
