# This Python file uses the following encoding: utf-8
from PySide6.QtCore import Property, QObject, QStandardPaths, Signal, Slot
from PySide6.QtQml import QmlElement
from datetime import datetime
from pathlib import Path
import uuid

from .app_state import AppState
from .data.trip_repository import TripRepository
from .settings_manager import SettingsManager
from .models import (
    ExpenseSqlModel,
    ParticipantSqlModel,
    SettlementModel,
    TripFilterProxy,
    TripSqlModel,
)
from .services.settlement_service import (
    get_participant_balances,
    get_settlement_transactions,
)
from .services.share_service import create_pdf

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class TripManager(QObject):
    """Backend manager for trips with model integration"""

    # ── Signals ───────────────────────────────────────
    tripsChanged = Signal()
    activeTripChanged = Signal()
    expensesChanged = Signal()
    participantsChanged = Signal()
    settlementsChanged = Signal()

    def __init__(self, settings: SettingsManager, repo: TripRepository, app_state: AppState):
        super().__init__()
        self.settings = settings
        self.repo = repo
        self.app_state = app_state

        self._active_trip_id = ""

        # ── Models ────────────────────────────────────────────
        self._trip_model = TripSqlModel(self.repo.db)

        self._proxy_model = TripFilterProxy()
        self._proxy_model.setSourceModel(self._trip_model)

        self._expense_model = ExpenseSqlModel(self.repo.db)
        self._participant_model = ParticipantSqlModel(self.repo.db)
        self._settlement_model = SettlementModel()

        # ── Auto Sync State Change ────────────────────────────
        self.activeTripChanged.connect(self._sync_app_state)
        self.expensesChanged.connect(self._sync_app_state)
        self.participantsChanged.connect(self._sync_app_state)
        self.settlementsChanged.connect(self._sync_app_state)

    # ── Helper Methods ─────────────────────────────────────
    def _refresh_all(self):
        """Refresh all models"""
        self._trip_model.select()
        self.tripsChanged.emit()

    def _update_active_trip_models(self):
        """Update models for the active trip"""
        if not self._active_trip_id:
            return

        # Set SQL models to filter by active trip
        self._expense_model.setTrip(self._active_trip_id)
        self._participant_model.setTrip(self._active_trip_id)

        # Load data for settlements (still requires in-memory calculation)
        trip = self.repo.load_trip(self._active_trip_id)
        if trip:
            participants = trip.get("participants", [])
            expenses = trip.get("expenses", [])
            balances = get_participant_balances(participants, expenses)
            settlements = get_settlement_transactions(balances)
            self._settlement_model.setSettlements(settlements)

        # Emit signals
        self.expensesChanged.emit()
        self.participantsChanged.emit()
        self.settlementsChanged.emit()

    def _sync_app_state(self):
        """Sync current state to AppState"""
        if not self._active_trip_id:
            self.app_state.reset()
            return

        trip = self.repo.load_trip(self._active_trip_id)
        if not trip:
            self.app_state.reset()
            return

        self.app_state.tripId = self._active_trip_id
        self.app_state.tripName = trip.get("name", "")
        self.app_state.tripCurrency = trip.get("currency", "")
        self.app_state.currencySymbol = self.settings.getCurrencySymbol(
            trip.get("currency", "")
        )

        participants = trip.get("participants", [])
        expenses = trip.get("expenses", [])

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

    # ── Active Trip Management ─────────────────────────────
    @Slot(str)
    def setActiveTrip(self, trip_id: str):
        """Load a trip and update AppState"""
        self._active_trip_id = trip_id
        self.settings.setLastTripId(trip_id)
        self.activeTripChanged.emit()
        self._update_active_trip_models()

    @Slot(str)
    def setFilter(self, text: str):
        """QML search field"""
        self._proxy_model.setFilterFixedString(text)

    @Property(int, notify=tripsChanged)
    def tripCount(self):
        """Get total number of trips"""
        return self._trip_model.rowCount()

    @Property(QObject, notify=tripsChanged)
    def proxyModel(self):
        """Get the proxy model for trips"""
        return self._proxy_model

    @Slot(str, result="QVariantList")
    def getParticipants(self, trip_id: str):
        """Get participants for a specific trip"""
        trip = self.repo.load_trip(trip_id)
        return trip.get("participants", []) if trip else []

    # ── Trip Operations ────────────────────────────────────
    @Slot(str, result=str)
    def addTrip(self, name: str) -> str:
        """Add a new trip"""
        trip = {
            "id": str(uuid.uuid4()),
            "name": name.strip(),
            "currency": self.settings.currency,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
        }
        self.repo.insert_trip(trip)
        self._refresh_all()
        return trip["id"]

    @Slot(str, result=bool)
    def deleteTrip(self, trip_id: str) -> bool:
        """Delete a trip"""
        self.repo.delete_trip(trip_id)
        self._refresh_all()

        if self._active_trip_id == trip_id:
            self._active_trip_id = ""
            self.activeTripChanged.emit()
            self._update_active_trip_models()
        return True

    @Slot(str, str, "QVariantList", str, result=bool)
    def editTrip(
        self, trip_id: str, name: str, participants: list, currency: str
    ) -> bool:
        """Edit a trip's details"""
        trip = {
            "id": trip_id,
            "name": name.strip(),
            "currency": currency,
            "updated_at": datetime.now().isoformat(),
        }
        self.repo.update_trip(trip)
        self.repo.replace_participants(trip_id, participants)
        self._refresh_all()

        if self._active_trip_id == trip_id:
            self.activeTripChanged.emit()
            self._update_active_trip_models()
        return True

    @Slot(str, result=str)
    def shareTrip(self, trip_id: str) -> str:
        """Share a trip's details"""
        trip = self.repo.load_trip(trip_id)
        if not trip:
            return ""

        base = Path(QStandardPaths.writableLocation(QStandardPaths.DocumentsLocation))
        path = base / "ExpenseSplitter" / "Shared" / f"{trip['name']}.pdf"
        path.parent.mkdir(parents=True, exist_ok=True)

        balances = get_participant_balances(
            trip.get("participants", []), trip.get("expenses", [])
        )
        settlements = get_settlement_transactions(balances)
        create_pdf(trip, balances, settlements, path)
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
        """Add an expense to a specific trip"""
        if not self._active_trip_id:
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
        self.repo.insert_expense(self._active_trip_id, expense)

        # Update trip's updated_at
        trip = self.repo.load_trip(self._active_trip_id)
        if trip:
            trip["updated_at"] = datetime.now().isoformat()
            self.repo.update_trip(trip)

        self._refresh_all()
        self._update_active_trip_models()
        return expense["id"]

    @Slot(str, result=bool)
    def deleteExpense(self, expense_id: str) -> bool:
        """Delete an expense from a trip"""
        if not self._active_trip_id:
            return False

        self.repo.delete_expense(expense_id)
        self._refresh_all()
        self._update_active_trip_models()
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
        """Edit an expense in a specific trip"""
        if not self._active_trip_id:
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

        # Update trip's updated_at
        trip = self.repo.load_trip(self._active_trip_id)
        if trip:
            trip["updated_at"] = datetime.now().isoformat()
            self.repo.update_trip(trip)

        self._refresh_all()
        self._update_active_trip_models()
        return True

    # ── Participant Operations ─────────────────────────────
    @Slot(str, result=str)
    def addParticipant(self, name: str) -> str:
        """Add a participant to a specific trip"""
        if not self._active_trip_id:
            return ""

        participant = {"id": str(uuid.uuid4()), "name": name}
        self.repo.insert_participant(self._active_trip_id, participant)

        # Update trip's updated_at
        trip = self.repo.load_trip(self._active_trip_id)
        if trip:
            trip["updated_at"] = datetime.now().isoformat()
            self.repo.update_trip(trip)

        self._refresh_all()
        self._update_active_trip_models()
        return participant["id"]

    @Slot(str, result=bool)
    def deleteParticipant(self, participant_id: str) -> bool:
        """Delete a participant from a trip"""
        if not self._active_trip_id:
            return False

        # Load trip to update expenses
        trip = self.repo.load_trip(self._active_trip_id)
        if not trip:
            return False

        # Remove participant from expense exclusions
        for expense in trip.get("expenses", []):
            if "excluded" in expense and participant_id in expense["excluded"]:
                expense["excluded"].remove(participant_id)
                self.repo.update_expense(expense)

        self.repo.delete_participant(participant_id)
        self._refresh_all()
        self._update_active_trip_models()
        return True

    @Slot(str, str, result=bool)
    def editParticipant(self, participant_id: str, name: str) -> bool:
        """Edit a participant in a specific trip"""
        if not self._active_trip_id:
            return False

        participant = {"id": participant_id, "name": name}
        self.repo.update_participant(participant)

        # Update trip's updated_at
        trip = self.repo.load_trip(self._active_trip_id)
        if trip:
            trip["updated_at"] = datetime.now().isoformat()
            self.repo.update_trip(trip)

        self._refresh_all()
        self._update_active_trip_models()
        return True

    @Slot(result=str)
    def generateId(self) -> str:
        return str(uuid.uuid4())

    # ── Data Management Operations ─────────────────────────────
    @Slot(result=bool)
    def deleteAllTrips(self) -> bool:
        """Delete all trips from the database"""
        success = self.repo.delete_all_trips()

        if success:
            # Clear active trip
            self._active_trip_id = ""
            self.activeTripChanged.emit()

            # Clear last trip from settings
            self.settings.setLastTripId("")

            # Refresh all models
            self._refresh_all()
            self._update_active_trip_models()

        return success

    @Slot(str, result=bool)
    def exportDataAsJson(self, file_path: str) -> bool:
        """Export all data to a JSON file"""
        return self.repo.export_data_json(file_path)

    @Slot(str, result=bool)
    def exportDatabaseFile(self, file_path: str) -> bool:
        """Export the SQLite database file"""
        return self.repo.export_database_file(file_path)
