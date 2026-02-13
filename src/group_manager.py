# This Python file uses the following encoding: utf-8
from PySide6.QtCore import Property, QObject, QStandardPaths, Signal, Slot
from PySide6.QtQml import QmlElement
from datetime import datetime
from pathlib import Path
import uuid

from .app_state import AppState
from .data.group_repository import GroupRepository
from .data.models import (
    ExpenseSqlModel,
    GroupFilterProxy,
    GroupSqlModel,
    ParticipantSqlModel,
    SettlementModel,
)
from .services.settlement_service import (
    get_participant_balances,
    get_settlement_transactions,
)
from .services.share_service import create_pdf
from .settings_manager import SettingsManager

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class GroupManager(QObject):
    """Backend manager for groups with model integration"""

    # ── Signals ───────────────────────────────────────
    groupsChanged = Signal()
    activeGroupChanged = Signal()
    expensesChanged = Signal()
    participantsChanged = Signal()
    settlementsChanged = Signal()

    def __init__(
        self, settings: SettingsManager, repo: GroupRepository, app_state: AppState
    ):
        super().__init__()
        self.settings = settings
        self.repo = repo
        self.app_state = app_state

        self._active_group_id = ""

        # ── Models ────────────────────────────────────────────
        self._group_model = GroupSqlModel(self.repo.db)

        self._proxy_model = GroupFilterProxy()
        self._proxy_model.setSourceModel(self._group_model)

        self._expense_model = ExpenseSqlModel(self.repo.db)
        self._participant_model = ParticipantSqlModel(self.repo.db)
        self._settlement_model = SettlementModel()

        # ── Auto Sync State Change ────────────────────────────
        self.activeGroupChanged.connect(self._sync_app_state)
        self.expensesChanged.connect(self._sync_app_state)
        self.participantsChanged.connect(self._sync_app_state)
        self.settlementsChanged.connect(self._sync_app_state)

    # ── Helper Methods ─────────────────────────────────────
    def _refresh_all(self):
        """Refresh all models"""
        self._group_model.select()
        self.groupsChanged.emit()

    def _update_active_group_models(self):
        """Update models for the active group"""
        if not self._active_group_id:
            return

        # Set SQL models to filter by active group
        self._expense_model.setGroup(self._active_group_id)
        self._participant_model.setGroup(self._active_group_id)

        # Load data for settlements (still requires in-memory calculation)
        group = self.repo.load_group(self._active_group_id)
        if group:
            participants = group.get("participants", [])
            expenses = group.get("expenses", [])
            balances = get_participant_balances(participants, expenses)
            settlements = get_settlement_transactions(balances)
            self._settlement_model.setSettlements(settlements)

        # Emit signals
        self.expensesChanged.emit()
        self.participantsChanged.emit()
        self.settlementsChanged.emit()

    def _sync_app_state(self):
        """Sync current state to AppState"""
        if not self._active_group_id:
            self.app_state.reset()
            return

        group = self.repo.load_group(self._active_group_id)
        if not group:
            self.app_state.reset()
            return

        self.app_state.groupId = self._active_group_id
        self.app_state.groupName = group.get("name", "")
        self.app_state.groupCurrency = group.get("currency", "")
        self.app_state.currencySymbol = self.settings.getCurrencySymbol(
            group.get("currency", "")
        )

        participants = group.get("participants", [])
        expenses = group.get("expenses", [])

        self.app_state.participantCount = self._participant_model.rowCount()
        self.app_state.totalSpent = sum(expense["amount"] for expense in expenses)
        self.app_state.participantList = participants

        balances = get_participant_balances(participants, expenses)
        self.app_state.participantBalances = balances

        if balances:
            total_should_pay = sum(data["should_pay"] for data in balances.values())
            self.app_state.averageShare = total_should_pay / len(balances)
        else:
            self.app_state.averageShare = 0.0

        # Model references
        self.app_state.participantModel = self._participant_model
        self.app_state.expenseModel = self._expense_model
        self.app_state.settlementModel = self._settlement_model

    # ── Active Group Management ────────────────────────────
    @Slot(str)
    def setActiveGroup(self, group_id: str):
        """Load a group and update AppState"""
        self._active_group_id = group_id
        self.settings.setLastGroupId(group_id)
        self.activeGroupChanged.emit()
        self._update_active_group_models()

    @Slot(str)
    def setFilter(self, text: str):
        """QML search field"""
        self._proxy_model.setFilterFixedString(text)

    @Property(int, notify=groupsChanged)
    def groupCount(self):
        """Get total number of groups"""
        return self._group_model.rowCount()

    @Property(QObject, notify=groupsChanged)
    def proxyModel(self):
        """Get the proxy model for groups"""
        return self._proxy_model

    @Slot(str, result="QVariantList")
    def getParticipants(self, group_id: str):
        """Get participants for a specific group"""
        group = self.repo.load_group(group_id)
        return group.get("participants", []) if group else []

    # ── Group Operations ───────────────────────────────────
    @Slot(str, result=str)
    def addGroup(self, name: str) -> str:
        """Add a new group"""
        group = {
            "id": str(uuid.uuid4()),
            "name": name.strip(),
            "currency": self.settings.currency,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
        }
        self.repo.insert_group(group)
        self._refresh_all()
        return group["id"]

    @Slot(str, result=bool)
    def deleteGroup(self, group_id: str) -> bool:
        """Delete a group"""
        self.repo.delete_group(group_id)
        self._refresh_all()

        if self._active_group_id == group_id:
            self._active_group_id = ""
            self.activeGroupChanged.emit()
            self._update_active_group_models()
        return True

    @Slot(str, str, "QVariantList", str, result=bool)
    def editGroup(
        self, group_id: str, name: str, participants: list, currency: str
    ) -> bool:
        """Edit a group's details"""
        group = {
            "id": group_id,
            "name": name.strip(),
            "currency": currency,
            "updated_at": datetime.now().isoformat(),
        }
        self.repo.update_group(group)
        self.repo.replace_participants(group_id, participants)
        self._refresh_all()

        if self._active_group_id == group_id:
            self.activeGroupChanged.emit()
            self._update_active_group_models()
        return True

    @Slot(str, result=str)
    def shareGroup(self, group_id: str) -> str:
        """Share a group's details"""
        group = self.repo.load_group(group_id)
        if not group:
            return ""

        base = Path(QStandardPaths.writableLocation(QStandardPaths.DocumentsLocation))
        path = base / "ExpenseSplitter" / "Shared" / f"{group['name']}.pdf"
        path.parent.mkdir(parents=True, exist_ok=True)

        balances = get_participant_balances(
            group.get("participants", []), group.get("expenses", [])
        )
        settlements = get_settlement_transactions(balances)
        create_pdf(group, balances, settlements, path)
        return str(path)

    # ── Expense Operations ─────────────────────────────────
    @Slot(str, float, str, str, "QVariantList", result=str)
    def addExpense(
        self,
        title: str,
        amount: float,
        participant_id: str,
        split_type: str,
        excluded: list = [],
    ) -> str:
        """Add an expense to a specific group"""
        if not self._active_group_id:
            return ""

        expense = {
            "id": str(uuid.uuid4()),
            "title": title,
            "amount": amount,
            "paid_by": participant_id,
            "split_type": split_type,
            "excluded": excluded,
            "created_at": datetime.now().isoformat(),
        }
        self.repo.insert_expense(self._active_group_id, expense)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return expense["id"]

    @Slot(str, result=bool)
    def deleteExpense(self, expense_id: str) -> bool:
        """Delete an expense from a group"""
        if not self._active_group_id:
            return False

        self.repo.delete_expense(expense_id)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return True

    @Slot(str, str, float, str, str, "QVariantList", result=bool)
    def editExpense(
        self,
        expense_id: str,
        title: str,
        amount: float,
        participant_id: str,
        split_type: str,
        excluded: list,
    ) -> bool:
        """Edit an expense in a specific group"""
        if not self._active_group_id:
            return False

        expense = {
            "id": expense_id,
            "title": title,
            "amount": amount,
            "paid_by": participant_id,
            "split_type": split_type,
            "excluded": excluded,
        }
        self.repo.update_expense(expense)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return True

    # ── Participant Operations ─────────────────────────────
    @Slot(str, result=str)
    def addParticipant(self, name: str) -> str:
        """Add a participant to a specific group"""
        if not self._active_group_id:
            return ""

        participant = {"id": str(uuid.uuid4()), "name": name}
        self.repo.insert_participant(self._active_group_id, participant)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return participant["id"]

    @Slot(str, result=bool)
    def deleteParticipant(self, participant_id: str) -> bool:
        """Delete a participant from a group"""
        if not self._active_group_id:
            return False

        # Load group to update expenses
        group = self.repo.load_group(self._active_group_id)
        if not group:
            return False

        # Remove participant from expense exclusions
        for expense in group.get("expenses", []):
            if "excluded" in expense and participant_id in expense["excluded"]:
                expense["excluded"].remove(participant_id)
                self.repo.update_expense(expense)

        self.repo.delete_participant(participant_id)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return True

    @Slot(str, str, result=bool)
    def editParticipant(self, participant_id: str, name: str) -> bool:
        """Edit a participant in a specific group"""
        if not self._active_group_id:
            return False

        participant = {"id": participant_id, "name": name}
        self.repo.update_participant(participant)
        self.repo.update_group_timestamp(self._active_group_id)

        self._refresh_all()
        self._update_active_group_models()
        return True

    @Slot(result=str)
    def generateId(self) -> str:
        return str(uuid.uuid4())

    # ── Data Management Operations ─────────────────────────────
    @Slot(result=bool)
    def deleteAllGroups(self) -> bool:
        """Delete all groups from the database"""
        success = self.repo.delete_all_groups()

        if success:
            # Clear active group
            self._active_group_id = ""
            self.activeGroupChanged.emit()

            # Clear last group from settings
            self.settings.setLastGroupId("")

            # Refresh all models
            self._refresh_all()
            self._update_active_group_models()

        return success

    @Slot(str, result=bool)
    def exportDataAsJson(self, file_path: str) -> bool:
        """Export all data to a JSON file"""
        return self.repo.export_data_json(file_path)

    @Slot(str, result=bool)
    def exportDatabaseFile(self, file_path: str) -> bool:
        """Export the SQLite database file"""
        return self.repo.export_database_file(file_path)
