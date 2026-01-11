# This Python file uses the following encoding: utf-8
from PySide6.QtCore import (
    Property,
    QAbstractListModel,
    QModelIndex,
    QObject,
    QSettings,
    QSortFilterProxyModel,
    QStandardPaths,
    Qt,
    Signal,
    Slot,
)
from PySide6.QtQml import QmlElement
from datetime import datetime
import json
import uuid

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


class TripModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    MembersRole = Qt.UserRole + 3
    CurrencyRole = Qt.UserRole + 4

    def __init__(self, trips_list, parent=None):
        super().__init__(parent)
        self._trips = trips_list

    def rowCount(self, parent=QModelIndex()):
        return len(self._trips)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._trips)):
            return None

        trip = self._trips[index.row()]
        if role == self.IdRole:
            return trip["id"]
        if role == self.NameRole:
            return trip["name"]
        if role == self.MembersRole:
            return trip["members"]
        if role == self.CurrencyRole:
            return trip["currency"]
        return None

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.MembersRole: b"members",
            self.CurrencyRole: b"currency",
        }

    def refresh(self):
        self.beginResetModel()
        self.endResetModel()


class ExpenseModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    TitleRole = Qt.UserRole + 2
    AmountRole = Qt.UserRole + 3
    PaidByRole = Qt.UserRole + 4
    CreatedAtRole = Qt.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._expenses = []

    def setExpenses(self, expenses):
        """Update the expense list"""
        self.beginResetModel()
        self._expenses = expenses
        self.endResetModel()

    def rowCount(self, parent=QModelIndex()):
        return len(self._expenses)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._expenses)):
            return None

        expense = self._expenses[index.row()]
        if role == self.IdRole:
            return expense["id"]
        if role == self.TitleRole:
            return expense["title"]
        if role == self.AmountRole:
            return expense["amount"]
        if role == self.PaidByRole:
            return expense["paid_by"]
        if role == self.CreatedAtRole:
            return expense.get("created_at", "")
        return None

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.TitleRole: b"title",
            self.AmountRole: b"amount",
            self.PaidByRole: b"paid_by",
            self.CreatedAtRole: b"created_at",
        }


class TripFilterProxy(QSortFilterProxyModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterRole(TripModel.NameRole)


@QmlElement
class TripManager(QObject):
    """Backend manager for trips with model integration"""

    tripsChanged = Signal()
    expensesChanged = Signal()

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")
        self._trips = []
        self._current_trip_id = ""

        self.load_trips()

        self._source_model = TripModel(self._trips)
        self._proxy_model = TripFilterProxy()
        self._proxy_model.setSourceModel(self._source_model)

        self._expense_model = ExpenseModel()

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
            self._expense_model.setExpenses(trip.get("expenses", []))
            self.expensesChanged.emit()

    @Property(list, notify=tripsChanged)
    def trips(self):
        """Get all trips"""
        return self._trips

    @Property(int, notify=tripsChanged)
    def tripCount(self):
        """Get total number of trips"""
        return len(self._trips)

    @Property(QObject, notify=tripsChanged)
    def proxyModel(self):
        """Get the proxy model for trips"""
        return self._proxy_model

    @Property(QObject, notify=expensesChanged)
    def expenseModel(self):
        """Get the model for expenses"""
        return self._expense_model

    @Slot(str, int, result=str)
    def addTrip(self, name: str, members: int):
        """Add a new trip"""
        trip = {
            "id": str(uuid.uuid4()),
            "name": name.strip(),
            "currency": self.settings.value("currency", "NGN"),
            "members": members,
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
                return True
        return False

    @Slot(str, str, int, str, result=bool)
    def editTrip(self, trip_id: str, name: str, members: int, currency: str):
        """Edit a trip's details"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                trip["name"] = name.strip()
                trip["currency"] = currency
                trip["members"] = members
                trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()
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

    @Slot(str, str, float, str)
    def addExpense(self, trip_id, title, amount, paid_by):
        """Add an expense to a specific trip"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                expense = {
                    "id": str(uuid.uuid4()),
                    "title": title,
                    "amount": amount,
                    "paid_by": paid_by,
                    "created_at": datetime.now().isoformat(),
                }
                trip["expenses"].append(expense)
                trip["updated_at"] = datetime.now().isoformat()
                self.save_trips()

                if trip_id == self._current_trip_id:
                    self._expense_model.setExpenses(trip["expenses"])
                    self.expensesChanged.emit()

                return expense["id"]
        return ""

    @Slot(str, str, result=bool)
    def deleteExpense(self, trip_id, expense_id):
        """Delete an expense from a trip"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                for i, expense in enumerate(trip["expenses"]):
                    if expense["id"] == expense_id:
                        trip["expenses"].pop(i)
                        self.save_trips()

                        if trip_id == self._current_trip_id:
                            self._expense_model.setExpenses(trip["expenses"])
                            self.expensesChanged.emit()

                        return True
        return False

    @Slot(str, str, str, float, str, result=bool)
    def editExpense(self, trip_id, expense_id, title, amount, paid_by):
        """Edit an expense in a specific trip"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                for expense in trip["expenses"]:
                    if expense["id"] == expense_id:
                        expense["title"] = title
                        expense["amount"] = amount
                        expense["paid_by"] = paid_by
                        trip["updated_at"] = datetime.now().isoformat()
                        self.save_trips()

                        if trip_id == self._current_trip_id:
                            self._expense_model.setExpenses(trip["expenses"])
                            self.expensesChanged.emit()

                        return True
        return False

    @Property(float, notify=expensesChanged)
    def tripTotal(self):
        """Get total expenses for a trip"""
        trip = self.getTripById(self._current_trip_id)
        if trip:
            return sum(expense["amount"] for expense in trip.get("expenses", []))
        return 0.0
