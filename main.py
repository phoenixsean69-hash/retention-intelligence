"""Retention Intelligence desktop entry point.

Run normally: python main.py
Detailed startup output: python -u -X faulthandler main.py --debug-startup
For isolated native crash probes: python -u diagnose_startup.py
"""
from __future__ import annotations

import faulthandler
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QFont, QIcon
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


def main() -> int:
    # Native C++ exceptions (0xC0000005) are not catchable using Python try/except.
    # faulthandler helps locate the last Python frame, while milestones show progress.
    faulthandler.enable()
    debug = "--debug-startup" in sys.argv
    args = [x for x in sys.argv if x != "--debug-startup"]

    def milestone(message: str) -> None:
        if debug:
            print("[Retention startup] " + message, flush=True)

    milestone("Creating QApplication")
    app = QApplication(args)
    app.setApplicationName("Retention Intelligence")
    app.setOrganizationName("Retention Intelligence")
    app.setFont(QFont("Segoe UI", 10))

    root = Path(__file__).resolve().parent
    app.setWindowIcon(QIcon(str(root / "assets" / "retention.svg")))
    milestone("Creating QML engine")
    engine = QQmlApplicationEngine()

    # Delayed import keeps scikit-learn and ReportLab out of the GUI startup path.
    milestone("Initializing Python backend")
    from backend_v04 import DesktopBackend
    bridge = DesktopBackend()
    engine.rootContext().setContextProperty("backend", bridge)
    milestone("Backend attached to QML context")

    qml_path = root / "ui" / "Main.qml"
    if not qml_path.is_file():
        print(f"QML entry file not found: {qml_path}", file=sys.stderr)
        return 1

    milestone("Loading QML: " + str(qml_path))
    engine.load(QUrl.fromLocalFile(str(qml_path)))
    milestone("QML load returned")
    if not engine.rootObjects():
        print("QML failed to create a root window. Check Qt messages above.", file=sys.stderr)
        return 1
    milestone("Entering Qt event loop")
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
