from PySide6.QtCore import QSettings, QStandardPaths
from PySide6.QtSql import QSqlDatabase, QSqlQuery
import json
from pathlib import Path
from typing import List, Dict


class TripRepository:
    def __init__(self, qsettings: QSettings):
        self.settings = qsettings
        self._open_db()
        self._migrate_trips()

    def _open_db(self):
        base = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
        Path(base).mkdir(parents=True, exist_ok=True)

        db_path = Path(base) / "app.db"

        self.db = QSqlDatabase.addDatabase("QSQLITE", "app_connection")
        self.db.setDatabaseName(str(db_path))

        if not self.db.open():
            raise RuntimeError("Failed to open SQLite database")

        query = QSqlQuery(self.db)
        query.exec(
            """
            CREATE TABLE IF NOT EXISTS app_data (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
        """
        )
        query.exec(
            """
            INSERT OR IGNORE INTO app_data (key, value)
            VALUES ('schema_version', '1');
        """
        )

    def _migrate_trips(self):
        if self.settings.value("tripsMigrated", False):
            return

        trips_json = self.settings.value("trips", "[]")

        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT OR REPLACE INTO app_data (key, value)
            VALUES ('trips', ?)
        """
        )
        query.addBindValue(trips_json)
        query.exec()

        self.settings.setValue("tripsMigrated", True)

    # ── Public API ─────────────────────────────────
    def load_trips(self) -> List[Dict]:
        query = QSqlQuery(self.db)
        query.prepare("SELECT value FROM app_data WHERE key = 'trips'")

        if query.exec() and query.next():
            try:
                return json.loads(query.value(0))
            except json.JSONDecodeError:
                return []
        return []

    def save_trips(self, trips: List[Dict]) -> None:
        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT OR REPLACE INTO app_data (key, value)
            VALUES ('trips', ?)
        """
        )
        query.addBindValue(json.dumps(trips))
        self.db.transaction()
        query.exec()
        self.db.commit()
