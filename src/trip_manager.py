# This Python file uses the following encoding: utf-8
from PySide6.QtCore import Property, QObject, QSettings, QStandardPaths, Signal, Slot
from PySide6.QtQml import QmlElement
from datetime import datetime
import json
from pathlib import Path
import uuid

from .models import (
    ExpenseModel,
    ParticipantModel,
    SettlementModel,
    TripFilterProxy,
    TripModel,
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

    # Signals
    tripsChanged = Signal()
    activeTripChanged = Signal()
    expensesChanged = Signal()
    participantsChanged = Signal()
    settlementsChanged = Signal()

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")
        self._trips = []
        self._active_trip_id = ""
        self._active_trip = {}

        self.load_trips()

        # ── Models ────────────────────────────────────────
        self._source_model = TripModel(self._trips)
        self._proxy_model = TripFilterProxy()
        self._proxy_model.setSourceModel(self._source_model)
        self._expense_model = ExpenseModel()
        self._participant_model = ParticipantModel()
        self._settlement_model = SettlementModel()

    # ── Persistence ────────────────────────────────────────
    def load_trips(self):
        """Load trips from storage"""
        trips_json = self.settings.value("trips", "[]")
        try:
            self._trips = json.loads(trips_json)
        except json.JSONDecodeError:
            self._trips = []

        if hasattr(self, "_source_model"):
            self._source_model.refresh()
        self.tripsChanged.emit()

    def save_trips(self):
        """Save trips to storage"""
        trips_json = json.dumps(self._trips)
        self.settings.setValue("trips", trips_json)
        if hasattr(self, "_source_model"):
            self._source_model.refresh()
        self.tripsChanged.emit()

    def _find_trip(self, trip_id: str):
        """Find a trip by ID"""
        for trip in self._trips:
            if trip.get("id") == trip_id:
                return trip
        return None

    def _update_active_trip_models(self):
        """Centralized method to update all models when active trip data changes"""
        if not self._active_trip:
            self._expense_model.setExpenses([])
            self._participant_model.setParticipants([])
            self._settlement_model.setSettlements([])
            return

        participants = self._active_trip.get("participants", [])
        expenses = self._active_trip.get("expenses", [])

        # Update models
        self._expense_model.setExpenses(expenses)
        self._participant_model.setParticipants(participants)

        settlements = get_settlement_transactions(
            get_participant_balances(participants, expenses)
        )
        self._settlement_model.setSettlements(settlements)

        # Emit signals once all models are updated
        self.expensesChanged.emit()
        self.participantsChanged.emit()
        self.settlementsChanged.emit()

    @Slot(str)
    def setFilter(self, text: str):
        """QML search field"""
        self._proxy_model.setFilterFixedString(text)

    @Property(list, notify=tripsChanged)
    def trips(self):
        """Get all trips"""
        return self._trips

    @Property(int, notify=tripsChanged)
    def tripCount(self):
        """Get total number of trips"""
        return len(self._trips)

    @Property("QVariantMap", notify=activeTripChanged)
    def activeTrip(self):
        """Get current active trip"""
        return self._active_trip

    @Property(QObject, notify=tripsChanged)
    def proxyModel(self):
        """Get the proxy model for trips"""
        return self._proxy_model

    @Property(QObject, notify=expensesChanged)
    def expenseModel(self):
        """Get the model for expenses"""
        return self._expense_model

    @Property(QObject, notify=participantsChanged)
    def participantModel(self):
        """Get the model for participants"""
        return self._participant_model

    @Property(QObject, notify=settlementsChanged)
    def settlementModel(self):
        """Get the model for settlements"""
        return self._settlement_model

    @Property("QVariantList", notify=participantsChanged)
    def participantsList(self):
        """Get the list of participants"""
        if not self._active_trip:
            return []
        return self._active_trip.get("participants", [])

    @Property(int, notify=participantsChanged)
    def participantCount(self):
        """Get the number of participants"""
        return self._participant_model.rowCount() if self._participant_model else 0

    # ── Trip Operations ────────────────────────────────────
    @Slot(str, result=str)
    def addTrip(self, name: str) -> str:
        """Add a new trip"""
        trip = {
            "id": str(uuid.uuid4()),
            "name": name.strip(),
            "currency": self.settings.value("currency", "NGN"),
            "participants": [],
            "expenses": [],
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
        }
        self._trips.append(trip)
        self.save_trips()
        return trip["id"]

    @Slot(str, result=bool)
    def deleteTrip(self, trip_id: str) -> bool:
        """Delete a trip"""
        for i, trip in enumerate(self._trips):
            if trip["id"] == trip_id:
                self._trips.pop(i)
                self.save_trips()

                if self._active_trip_id == trip_id:
                    self._active_trip = {}
                    self._active_trip_id = ""
                    self.activeTripChanged.emit()
                return True
        return False

    @Slot(str, str, "QVariantList", str, result=bool)
    def editTrip(
        self, trip_id: str, name: str, participants: list, currency: str
    ) -> bool:
        """Edit a trip's details"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                trip["name"] = name.strip()
                trip["currency"] = currency
                trip["participants"] = participants
                trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()

                if self._active_trip_id == trip_id:
                    self.activeTripChanged.emit()
                    self._update_active_trip_models()
                return True
        return False

    @Slot(str, result=str)
    def shareTrip(self, trip_id: str) -> str:
        """Share a trip's details"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                base = Path(
                    QStandardPaths.writableLocation(QStandardPaths.DocumentsLocation)
                )
                path = base / "ExpenseSplitter" / "Shared" / f"{trip['name']}.pdf"
                path.parent.mkdir(parents=True, exist_ok=True)

                balances = get_participant_balances(
                    trip.get("participants", []), trip.get("expenses", [])
                )
                settlements = get_settlement_transactions(balances)
                create_pdf(trip, balances, settlements, path)
                return str(path)
        return ""

    @Slot(str, result="QVariantMap")
    def getTripById(self, trip_id) -> dict:
        """Get a specific trip by ID"""
        return self._find_trip(trip_id) or {}

    # ── Active Trip Management ─────────────────────────────
    @Slot(str)
    def setActiveTrip(self, trip_id: str):
        """Set the current active trip and update expense model"""
        self._active_trip_id = trip_id
        trip = self.getTripById(trip_id)
        if trip:
            self._active_trip = trip
            self.activeTripChanged.emit()
            self._update_active_trip_models()

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
        if not self._active_trip:
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
        self._active_trip["expenses"].append(expense)
        self._active_trip["updated_at"] = datetime.now().isoformat()
        self.save_trips()
        self._update_active_trip_models()
        return expense["id"]

    @Slot(str, result=bool)
    def deleteExpense(self, expense_id: str) -> bool:
        """Delete an expense from a trip"""
        if not self._active_trip:
            return False

        for i, expense in enumerate(self._active_trip["expenses"]):
            if expense["id"] == expense_id:
                self._active_trip["expenses"].pop(i)
                self.save_trips()
                self._update_active_trip_models()
                return True
        return False

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
        if not self._active_trip:
            return False

        for expense in self._active_trip["expenses"]:
            if expense["id"] == expense_id:
                expense["title"] = title
                expense["amount"] = amount
                expense["paid_by"] = participant_id
                expense["split_type"] = split_type
                expense["excluded"] = excluded
                self._active_trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()
                self._update_active_trip_models()
                return True
        return False

    @Property(float, notify=expensesChanged)
    def totalSpent(self) -> float:
        """Get total expenses for current trip"""
        if not self._active_trip:
            return 0.0
        return sum(
            expense["amount"] for expense in self._active_trip.get("expenses", [])
        )

    # ── Participant Operations ─────────────────────────────
    @Slot(str, result=str)
    def addParticipant(self, name: str) -> str:
        """Add a participant to a specific trip"""
        if not self._active_trip:
            return ""

        participant = {"id": str(uuid.uuid4()), "name": name}
        self._active_trip["participants"].append(participant)
        self._active_trip["updated_at"] = datetime.now().isoformat()
        self.save_trips()
        self._update_active_trip_models()
        return participant["id"]

    @Slot(str, result=bool)
    def deleteParticipant(self, participant_id: str) -> bool:
        """Delete a participant from a trip"""
        if not self._active_trip:
            return False

        for i, participant in enumerate(self._active_trip["participants"]):
            if participant["id"] == participant_id:
                self._active_trip["participants"].pop(i)

                for expense in self._active_trip.get("expenses", []):
                    if "excluded" in expense and participant_id in expense["excluded"]:
                        expense["excluded"].remove(participant_id)

                self.save_trips()
                self._update_active_trip_models()
                return True
        return False

    @Slot(str, str, result=bool)
    def editParticipant(self, participant_id: str, name: str) -> bool:
        """Edit a participant in a specific trip"""
        if not self._active_trip:
            return False

        for participant in self._active_trip["participants"]:
            if participant["id"] == participant_id:
                participant["name"] = name
                self._active_trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()
                self._update_active_trip_models()
                return True
        return False

    @Slot(result=str)
    def generateId(self) -> str:
        return str(uuid.uuid4())

    @Property(dict, notify=expensesChanged)
    def participantBalances(self) -> dict:
        """Returns a dictionary with balance info for each participant"""
        if not self._active_trip:
            return {}
        participants = self._active_trip.get("participants", [])
        expenses = self._active_trip.get("expenses", [])
        return get_participant_balances(participants, expenses)

    @Property(float, notify=expensesChanged)
    def averageSharePerPerson(self) -> float:
        """Get average 'should_pay' across participants for the current trip"""
        balances = self.participantBalances
        if not balances:
            return 0.0
        total_should_pay = sum(data["should_pay"] for data in balances.values())
        return total_should_pay / len(balances) if balances else 0.0
