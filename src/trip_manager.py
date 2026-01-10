# This Python file uses the following encoding: utf-8
import re
from PySide6.QtCore import QObject, Signal, Slot, Property, QSettings
from PySide6.QtQml import QmlElement
from datetime import datetime
import json
import uuid

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class TripManager(QObject):
    """Backend manager for trips with model integration"""

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

    @Slot(str, int, result=str)
    def addTrip(self, name: str, members: int):
        """Add a new trip"""
        trip = {
            "id": str(uuid.uuid4()),
            "name": name,
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
        """Delete a trip by name"""
        for i, trip in enumerate(self._trips):
            if trip["id"] == trip_id:
                self._trips.pop(i)
                self.save_trips()
                return True
        return False

    @Slot(str, str, int, result=bool)
    def editTrip(self, trip_id, name, members):
        """Edit a trip's details"""
        for trip in self._trips:
            if trip["id"] == trip_id:
                trip["name"] = name
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
