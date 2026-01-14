# This Python file uses the following encoding: utf-8
from PySide6.QtCore import Property, QObject, QSettings, QStandardPaths, Signal, Slot
from PySide6.QtQml import QmlElement
from datetime import datetime
import json
import uuid

from .models import ExpenseModel, MemberModel, TripFilterProxy, TripModel

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class TripManager(QObject):
    """Backend manager for trips with model integration"""

    tripsChanged = Signal()
    currentTripChanged = Signal()
    expensesChanged = Signal()
    membersChanged = Signal()

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")
        self._trips = []
        self._current_trip_id = ""
        self._current_trip = {}

        self.load_trips()

        self._source_model = TripModel(self._trips)
        self._proxy_model = TripFilterProxy()
        self._proxy_model.setSourceModel(self._source_model)

        self._expense_model = ExpenseModel()
        self._member_model = MemberModel()

    def load_trips(self):
        """Load trips from storage"""
        trips_json = self.settings.value("trips", "[]")
        try:
            self._trips = json.loads(trips_json)
            for trip in self._trips:
                if "member_count" not in trip:
                    trip["member_count"] = trip["members"]
                    trip["members"] = []
            self.save_trips()
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

    @Slot(str)
    def setFilter(self, text: str):
        """QML search field"""
        self._proxy_model.setFilterFixedString(text)

    @Slot(str)
    def setCurrentTrip(self, trip_id: str):
        """Set the current trip and update expense model"""
        self._current_trip_id = trip_id
        trip = self.getTripById(trip_id)
        if trip:
            self._current_trip = trip
            self.currentTripChanged.emit()

            self._expense_model.setExpenses(trip.get("expenses", []))
            self.expensesChanged.emit()

            self._member_model.setMembers(trip.get("members", []))
            self.membersChanged.emit()

    @Property(list, notify=tripsChanged)
    def trips(self):
        """Get all trips"""
        return self._trips

    @Property(int, notify=tripsChanged)
    def tripCount(self):
        """Get total number of trips"""
        return len(self._trips)

    @Property("QVariantMap", notify=currentTripChanged)
    def currentTrip(self):
        """Get current trip"""
        return self._current_trip

    @Property(QObject, notify=tripsChanged)
    def proxyModel(self):
        """Get the proxy model for trips"""
        return self._proxy_model

    @Property(QObject, notify=expensesChanged)
    def expenseModel(self):
        """Get the model for expenses"""
        return self._expense_model

    @Property(QObject, notify=membersChanged)
    def memberModel(self):
        """Get the model for members"""
        return self._member_model

    @Property("QVariantList", notify=membersChanged)
    def membersList(self):
        """Get the list of members"""
        if not self._current_trip:
            return []
        return self._current_trip.get("members", [])

    @Property(int, notify=membersChanged)
    def memberCount(self):
        """Get the model for members"""
        return self._member_model.rowCount() if self._member_model else 0

    @Slot(str, result=str)
    def addTrip(self, name: str):
        """Add a new trip"""
        trip = {
            "id": str(uuid.uuid4()),
            "name": name.strip(),
            "currency": self.settings.value("currency", "NGN"),
            "members": [],
            "expenses": [],
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
        }
        self._trips.append(trip)
        self.save_trips()
        return trip["id"]

    @Slot(str, result=bool)
    def deleteTrip(self, trip_id: str):
        """Delete a trip"""
        for i, trip in enumerate(self._trips):
            if trip["id"] == trip_id:
                self._trips.pop(i)
                self.save_trips()

                if self._current_trip_id == trip_id:
                    self._current_trip = {}
                    self._current_trip_id = ""
                    self.currentTripChanged.emit()
                return True
        return False

    @Slot(str, str, "QVariantList", str, result=bool)
    def editTrip(self, trip_id: str, name: str, members: list, currency: str):
        """Edit a trip's details"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                trip["name"] = name.strip()
                trip["currency"] = currency
                trip["members"] = members
                trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()

                if self._current_trip_id == trip_id:
                    self.currentTripChanged.emit()
                    self._member_model.setMembers(trip["members"])
                    self.membersChanged.emit()
                return True
        return False

    @Slot(str, result="QVariantMap")
    def getTrip(self, name):
        """Get a specific trip by name"""
        for trip in self._trips:
            if trip["name"] == name:
                return trip
        return {}

    @Slot(str, result="QVariantMap")
    def getTripById(self, trip_id):
        """Get a specific trip by ID"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                return trip
        return {}

    @Slot(str, float, str, result=str)
    def addExpense(self, title: str, amount: float, member_id: str):
        """Add an expense to a specific trip"""
        if not self._current_trip:
            return ""

        expense = {
            "id": str(uuid.uuid4()),
            "title": title,
            "amount": amount,
            "paid_by": member_id,
            "created_at": datetime.now().isoformat(),
        }
        self._current_trip["expenses"].append(expense)
        self._current_trip["updated_at"] = datetime.now().isoformat()
        self.save_trips()

        self._expense_model.setExpenses(self._current_trip["expenses"])
        self.expensesChanged.emit()

        return expense["id"]

    @Slot(str, result=bool)
    def deleteExpense(self, expense_id: str):
        """Delete an expense from a trip"""
        if not self._current_trip:
            return False

        for i, expense in enumerate(self._current_trip["expenses"]):
            if expense["id"] == expense_id:
                self._current_trip["expenses"].pop(i)
                self.save_trips()

                self._expense_model.setExpenses(self._current_trip["expenses"])
                self.expensesChanged.emit()
                return True
        return False

    @Slot(str, str, float, str, result=bool)
    def editExpense(self, expense_id: str, title: str, amount: float, paid_by: str):
        """Edit an expense in a specific trip"""
        if not self._current_trip:
            return False

        for expense in self._current_trip["expenses"]:
            if expense["id"] == expense_id:
                expense["title"] = title
                expense["amount"] = amount
                expense["paid_by"] = paid_by
                self._current_trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()

                self._expense_model.setExpenses(self._current_trip["expenses"])
                self.expensesChanged.emit()
                return True
        return False

    @Property(float, notify=expensesChanged)
    def tripTotal(self):
        """Get total expenses for current trip"""
        if not self._current_trip:
            return 0.0
        return sum(
            expense["amount"] for expense in self._current_trip.get("expenses", [])
        )

    @Slot(str, result=str)
    def addMember(self, name: str):
        """Add a member to a specific trip"""
        if not self._current_trip:
            return ""

        member = {"id": str(uuid.uuid4()), "name": name}
        self._current_trip["members"].append(member)

        # Auto-exclude new member from all existing expenses
        # new_member_id = member["id"]
        # for expense in self._current_trip.get("expenses", []):
        #     if "excluded" not in expense:
        #         expense["excluded"] = []
        #     if new_member_id not in expense["excluded"]:
        #         expense["excluded"].append(new_member_id)

        self._current_trip["updated_at"] = datetime.now().isoformat()
        self.save_trips()

        self._member_model.setMembers(self._current_trip["members"])
        self.membersChanged.emit()

        # self.expensesChanged.emit()
        return member["id"]

    @Slot(str, result=bool)
    def deleteMember(self, member_id: str):
        """Delete a member from a trip"""
        deleted = False
        if not self._current_trip:
            return deleted

        for i, member in enumerate(self._current_trip["members"]):
            if member["id"] == member_id:
                self._current_trip["members"].pop(i)
                self.save_trips()

                self._member_model.setMembers(self._current_trip["members"])
                self.membersChanged.emit()
                deleted = True

        if deleted:
            for expense in self._current_trip.get("expenses", []):
                if "excluded" in expense and member_id in expense["excluded"]:
                    expense["excluded"].remove(member_id)
            self.save_trips()
            self.expensesChanged.emit()
        return deleted

    @Slot(str, str, result=bool)
    def editMember(self, member_id: str, name: str):
        """Edit a member in a specific trip"""
        if not self._current_trip:
            return False

        for member in self._current_trip["members"]:
            if member["id"] == member_id:
                member["name"] = name
                self._current_trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()

                self._member_model.setMembers(self._current_trip["members"])
                self.membersChanged.emit()
                return True
        return False
