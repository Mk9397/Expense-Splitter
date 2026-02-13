# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import resources_rc
from src.app_state import AppState
from src.data.group_repository import GroupRepository
from src.file_actions import FileSystemActions
from src.group_manager import GroupManager
from src.settings_manager import SettingsManager

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Bells Uni")
    app.setApplicationName("ExpenseSplitter")

    app_state = AppState()
    settings_manager = SettingsManager()
    group_manager = GroupManager(settings_manager, GroupRepository(), app_state)
    file_actions = FileSystemActions()

    engine = QQmlApplicationEngine()

    root_dir = Path(__file__).resolve().parent
    qml_dir = root_dir / "qml" if (root_dir / "qml").exists() else root_dir

    engine.addImportPath(str(qml_dir))
    engine.rootContext().setContextProperty("appState", app_state)
    engine.rootContext().setContextProperty("settingsManager", settings_manager)
    engine.rootContext().setContextProperty("fileActions", file_actions)
    engine.rootContext().setContextProperty("groupManager", group_manager)

    qml_file = qml_dir / "main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
