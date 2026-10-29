"""Retention Intelligence V0.4 desktop entrypoint."""
import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QFont, QIcon
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend_v04 import DesktopBackend


def main() -> int:
    app = QApplication(sys.argv)
    app.setApplicationName("Retention Intelligence")
    app.setOrganizationName("Retention Intelligence")
    app.setFont(QFont("Segoe UI", 10))
    app.setWindowIcon(QIcon(str(Path(__file__).resolve().parent / "assets" / "retention.svg")))
    engine = QQmlApplicationEngine()
    bridge = DesktopBackend()
    engine.rootContext().setContextProperty("backend", bridge)
    qml_path = Path(__file__).resolve().parent / "ui" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))
    if not engine.rootObjects():
        print("Could not load the desktop interface. Review the QML error messages above.", file=sys.stderr)
        return 1
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
