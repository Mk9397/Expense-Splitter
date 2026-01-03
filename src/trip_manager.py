# This Python file uses the following encoding: utf-8
from PySide6.QtCore import QObject, Signal, Slot, Property, QSettings
from PySide6.QtQml import QmlElement
import json

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class TripManager(QObject):
    tripsChanged = Signal()

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")
        self._trips = []
        self.load_trips()

    def load_trips(self):
        """Load trips from storage"""
        trips_json = self.settings.value("trips", "[]")
        try:
            self._trips = json.loads(trips_json)
        except json.JSONDecodeError:
            self._trips = []
        self.tripsChanged.emit()

    def save_trips(self):
        """Save trips to storage"""
        trips_json = json.dumps(self._trips)
        self.settings.setValue("trips", trips_json)
        self.tripsChanged.emit()

    @Slot(str, int)
    def addTrip(self, name, members):
        """Add a new trip"""
        trip = {"name": name, "members": members, "expenses": []}
        self._trips.append(trip)
        self.save_trips()

    @Slot(str, result=bool)
    def deleteTrip(self, name):
        """Delete a trip by name"""
        for i, trip in enumerate(self._trips):
            if trip["name"] == name:
                self._trips.pop(i)
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

    @Slot(str, str, float, str)
    def addExpense(self, trip_name, description, amount, paid_by):
        """Add an expense to a specific trip"""
        for trip in self._trips:
            if trip["name"] == trip_name:
                expense = {
                    "description": description,
                    "amount": amount,
                    "paid_by": paid_by,
                }
                trip["expenses"].append(expense)
                self.save_trips()
                break

    @Slot(str, int, result=bool)
    def deleteExpense(self, trip_name, expense_index):
        """Delete an expense from a trip"""
        for trip in self._trips:
            if trip["name"] == trip_name:
                if 0 <= expense_index < len(trip["expenses"]):
                    trip["expenses"].pop(expense_index)
                    self.save_trips()
                    return True
        return False

    @Property(list, notify=tripsChanged)
    def trips(self):
        """Get all trips"""
        return self._trips

    @Slot(result=int)
    def getTripCount(self):
        """Get total number of trips"""
        return len(self._trips)
