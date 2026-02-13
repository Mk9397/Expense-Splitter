from PySide6.QtCore import QStandardPaths
from PySide6.QtSql import QSqlDatabase, QSqlQuery
from pathlib import Path

import shutil
import json
from datetime import datetime


class GroupRepository:
    def __init__(self):
        self._open_db()
        self._group_cache = {}

    def _open_db(self):
        base = QStandardPaths.writableLocation(QStandardPaths.AppDataLocation)
        Path(base).mkdir(parents=True, exist_ok=True)

        db_path = Path(base) / "app.db"

        self.db = QSqlDatabase.addDatabase("QSQLITE", "app_connection")
        self.db.setDatabaseName(str(db_path))

        if not self.db.open():
            raise RuntimeError("Failed to open SQLite database")

        query = QSqlQuery(self.db)

        # ── Table Schemas ──────────────────────────────
        query.exec("PRAGMA foreign_keys = ON")

        # Groups
        query.exec(
            """
            CREATE TABLE IF NOT EXISTS trips (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                currency TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            );
            """
        )
        # Participants
        query.exec(
            """
            CREATE TABLE IF NOT EXISTS participants (
                id TEXT PRIMARY KEY,
                trip_id TEXT NOT NULL,
                name TEXT NOT NULL,
                FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
            );
            """
        )
        # Expenses
        query.exec(
            """
            CREATE TABLE IF NOT EXISTS expenses (
                id TEXT PRIMARY KEY,
                trip_id TEXT NOT NULL,
                title TEXT NOT NULL,
                amount REAL NOT NULL,
                paid_by TEXT NOT NULL,
                split_type TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
            );
            """
        )
        # Expense exclusions (many-to-many)
        query.exec(
            """
            CREATE TABLE IF NOT EXISTS expense_excluded (
                expense_id TEXT NOT NULL,
                participant_id TEXT NOT NULL,
                PRIMARY KEY (expense_id, participant_id),
                FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
                FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE
            );
            """
        )

    # ── Public API ─────────────────────────────────
    def load_group(self, group_id: str) -> dict | None:
        if group_id in self._group_cache:
            return self._group_cache[group_id]

        query = QSqlQuery(self.db)
        query.prepare("SELECT * FROM trips WHERE id = ?")
        query.addBindValue(group_id)
        if not query.exec() or not query.next():
            return None

        group = {
            "id": query.value("id"),
            "name": query.value("name"),
            "currency": query.value("currency"),
            "created_at": query.value("created_at"),
            "updated_at": query.value("updated_at"),
            "participants": [],
            "expenses": [],
        }

        # participants
        query.prepare("SELECT * FROM participants WHERE trip_id = ?")
        query.addBindValue(group_id)
        query.exec()
        while query.next():
            group["participants"].append(
                {"id": query.value("id"), "name": query.value("name")}
            )

        # expenses
        query.prepare("SELECT * FROM expenses WHERE trip_id = ?")
        query.addBindValue(group_id)
        query.exec()
        while query.next():
            expense = {
                "id": query.value("id"),
                "title": query.value("title"),
                "amount": query.value("amount"),
                "paid_by": query.value("paid_by"),
                "split_type": query.value("split_type"),
                "created_at": query.value("created_at"),
                "excluded": [],
            }
            group["expenses"].append(expense)

        query.prepare(
            """
            SELECT expense_id, participant_id
            FROM expense_excluded
            WHERE expense_id IN (
                SELECT id FROM expenses WHERE trip_id = ?
            )
        """
        )
        query.addBindValue(group_id)
        query.exec()

        expense_map = {e["id"]: e for e in group["expenses"]}
        while query.next():
            eid = query.value("expense_id")
            pid = query.value("participant_id")
            if eid in expense_map:
                expense_map[eid]["excluded"].append(pid)

        if group:
            self._group_cache[group_id] = group
        return group

    def _invalidate_group_cache(self, group_id: str):
        """Remove from cache when group is modified"""
        self._group_cache.pop(group_id, None)

    def load_all_groups(self) -> list[dict]:
        """Load all groups with their full data"""
        query = QSqlQuery(self.db)
        query.exec("SELECT id FROM trips")

        groups = []
        while query.next():
            group_id = query.value("id")
            group = self.load_group(group_id)
            if group:
                groups.append(group)

        return groups

    # ── Group operations ──────────────────────────────
    def insert_group(self, group: dict):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT INTO trips (id, name, currency, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
        """
        )
        query.addBindValue(group["id"])
        query.addBindValue(group["name"])
        query.addBindValue(group["currency"])
        query.addBindValue(group["created_at"])
        query.addBindValue(group["updated_at"])
        query.exec()

    def update_group(self, group: dict):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            UPDATE trips
            SET name = ?, currency = ?, updated_at = ?
            WHERE id = ?
        """
        )
        query.addBindValue(group["name"])
        query.addBindValue(group["currency"])
        query.addBindValue(group["updated_at"])
        query.addBindValue(group["id"])
        query.exec()
        self._invalidate_group_cache(group["id"])

    def update_group_timestamp(self, group_id: str):
        """Update only the updated_at field"""
        query = QSqlQuery(self.db)
        query.prepare("UPDATE trips SET updated_at = ? WHERE id = ?")
        query.addBindValue(datetime.now().isoformat())
        query.addBindValue(group_id)
        query.exec()
        self._invalidate_group_cache(group_id)

    def delete_group(self, group_id: str):
        query = QSqlQuery(self.db)
        query.prepare("DELETE FROM trips WHERE id = ?")
        query.addBindValue(group_id)
        query.exec()  # CASCADE deletes participants/expenses automatically
        self._invalidate_group_cache(group_id)

    def delete_all_groups(self):
        """Delete all groups and related data from the database"""
        query = QSqlQuery(self.db)
        # Thanks to CASCADE, deleting groups will delete everything
        query.exec("DELETE FROM trips")
        self._group_cache.clear()
        return query.numRowsAffected() >= 0

    # ── Participants ───────────────────────────────
    def insert_participant(self, group_id: str, participant: dict):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT INTO participants (id, trip_id, name)
            VALUES (?, ?, ?)
        """
        )
        query.addBindValue(participant["id"])
        query.addBindValue(group_id)
        query.addBindValue(participant["name"])
        query.exec()
        self._invalidate_group_cache(group_id)

    def update_participant(self, participant: dict):
        query = QSqlQuery(self.db)
        query.prepare("SELECT trip_id FROM participants WHERE id = ?")
        query.addBindValue(participant["id"])
        query.exec()
        group_id = query.value(0) if query.next() else None

        query.prepare("UPDATE participants SET name = ? WHERE id = ?")
        query.addBindValue(participant["name"])
        query.addBindValue(participant["id"])
        query.exec()

        if group_id:
            self._invalidate_group_cache(group_id)

    def delete_participant(self, participant_id: str):
        query = QSqlQuery(self.db)
        query.prepare("SELECT trip_id FROM participants WHERE id = ?")
        query.addBindValue(participant_id)
        query.exec()
        group_id = query.value(0) if query.next() else None

        query.prepare("DELETE FROM participants WHERE id = ?")
        query.addBindValue(participant_id)
        query.exec()  # CASCADE deletes exclusions

        if group_id:
            self._invalidate_group_cache(group_id)

    def replace_participants(self, group_id: str, participants: list[dict]):
        query = QSqlQuery(self.db)
        query.prepare("DELETE FROM participants WHERE trip_id = ?")
        query.addBindValue(group_id)
        query.exec()

        for p in participants:
            self.insert_participant(group_id, p)
        self._invalidate_group_cache(group_id)

    # ── Expenses ───────────────────────────────
    def insert_expense(self, group_id: str, expense: dict):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT INTO expenses (id, trip_id, title, amount, paid_by, split_type, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        )
        query.addBindValue(expense["id"])
        query.addBindValue(group_id)
        query.addBindValue(expense["title"])
        query.addBindValue(expense["amount"])
        query.addBindValue(expense["paid_by"])
        query.addBindValue(expense["split_type"])
        query.addBindValue(expense["created_at"])
        query.exec()

        for pid in expense.get("excluded", []):
            self.insert_expense_exclusion(expense["id"], pid)
        self._invalidate_group_cache(group_id)

    def update_expense(self, expense: dict):
        query = QSqlQuery(self.db)
        query.prepare("SELECT trip_id FROM expenses WHERE id = ?")
        query.addBindValue(expense["id"])
        query.exec()
        group_id = query.value(0) if query.next() else None

        query.prepare(
            """
            UPDATE expenses
            SET title = ?, amount = ?, paid_by = ?, split_type = ?
            WHERE id = ?
        """
        )
        query.addBindValue(expense["title"])
        query.addBindValue(expense["amount"])
        query.addBindValue(expense["paid_by"])
        query.addBindValue(expense["split_type"])
        query.addBindValue(expense["id"])
        query.exec()

        query.prepare("DELETE FROM expense_excluded WHERE expense_id = ?")
        query.addBindValue(expense["id"])
        query.exec()

        for pid in expense.get("excluded", []):
            self.insert_expense_exclusion(expense["id"], pid)

        if group_id:
            self._invalidate_group_cache(group_id)

    def delete_expense(self, expense_id: str):
        query = QSqlQuery(self.db)
        query.prepare("SELECT trip_id FROM expenses WHERE id = ?")
        query.addBindValue(expense_id)
        query.exec()
        group_id = query.value(0) if query.next() else None

        query.prepare("DELETE FROM expenses WHERE id = ?")
        query.addBindValue(expense_id)
        query.exec()

        if group_id:
            self._invalidate_group_cache(group_id)

    def insert_expense_exclusion(self, expense_id: str, participant_id: str):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            INSERT OR IGNORE INTO expense_excluded (expense_id, participant_id)
            VALUES (?, ?)
            """
        )
        query.addBindValue(expense_id)
        query.addBindValue(participant_id)
        query.exec()

    # ── Data Management ───────────────────────────────
    def export_data_json(self, export_path: str) -> bool:
        """Export all data to a JSON file"""
        try:
            all_data = {
                "export_date": datetime.now().isoformat(),
                "version": "1.0",
                "trips": self.load_all_groups(),
            }

            with open(export_path, "w", encoding="utf-8") as f:
                json.dump(all_data, f, indent=2, ensure_ascii=False)

            return True
        except Exception as e:
            print(f"Export error: {e}")
            return False

    def export_database_file(self, export_path: str) -> bool:
        """Export the SQLite database file itself"""
        try:
            db_path = self.db.databaseName()
            # Close and reopen to ensure all data is flushed
            self.db.close()
            shutil.copy2(db_path, export_path)
            self.db.open()
            return True
        except Exception as e:
            print(f"Database export error: {e}")
            # Try to reopen the database even if copy failed
            self.db.open()
            return False
