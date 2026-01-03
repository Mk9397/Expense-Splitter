# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QSettings

import resources_rc
from src.trip_manager import TripManager

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Bells Uni")
    app.setApplicationName("ExpenseSplitter")

    trip_manager = TripManager()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("tripManager", trip_manager)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
