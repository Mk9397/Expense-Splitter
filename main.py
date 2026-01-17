# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import resources_rc
from src.file_actions import FileSystemActions
from src.settings_manager import SettingsManager
from src.trip_manager import TripManager

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Bells Uni")
    app.setApplicationName("ExpenseSplitter")

    settings_manager = SettingsManager()
    trip_manager = TripManager()
    file_actions = FileSystemActions()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("settingsManager", settings_manager)
    engine.rootContext().setContextProperty("fileActions", file_actions)
    engine.rootContext().setContextProperty("tripManager", trip_manager)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
