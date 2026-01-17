from PySide6.QtCore import Slot, QObject, QUrl
from PySide6.QtGui import QDesktopServices
import os
import sys
import subprocess


class FileSystemActions(QObject):

    @Slot(str)
    def showInFolder(self, path):
        if sys.platform.startswith("win"):
            subprocess.run(["explorer", "/select,", os.path.normpath(path)])
        elif sys.platform == "darwin":
            subprocess.run(["open", "-R", path])
        else:
            # Linux fallback
            QDesktopServices.openUrl(QUrl.fromLocalFile(os.path.dirname(path)))

    @Slot(str)
    def openFile(self, path):
        QDesktopServices.openUrl(QUrl.fromLocalFile(path))
