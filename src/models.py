from PySide6.QtCore import (
    QAbstractListModel,
    QModelIndex,
    QSortFilterProxyModel,
    Qt,
    Slot,
)


class TripModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    ParticipantCountRole = Qt.UserRole + 3
    ParticipantsRole = Qt.UserRole + 4
    CurrencyRole = Qt.UserRole + 5

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
        if role == self.ParticipantCountRole:
            return len(trip.get("participants", []))
        if role == self.ParticipantsRole:
            return trip.get("participants", [])
        if role == self.CurrencyRole:
            return trip["currency"]
        return None

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.ParticipantCountRole: b"participant_count",
            self.ParticipantsRole: b"participants",
            self.CurrencyRole: b"currency",
        }

    def refresh(self):
        self.beginResetModel()
        self.endResetModel()


class TripFilterProxy(QSortFilterProxyModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterRole(TripModel.NameRole)


class ExpenseModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    TitleRole = Qt.UserRole + 2
    AmountRole = Qt.UserRole + 3
    PaidByRole = Qt.UserRole + 4
    SplitTypeRole = Qt.UserRole + 5
    ExcludedRole = Qt.UserRole + 6
    CreatedAtRole = Qt.UserRole + 7

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
        if role == self.SplitTypeRole:
            return expense["split_type"]
        if role == self.ExcludedRole:
            return expense["excluded"]
        if role == self.CreatedAtRole:
            return expense.get("created_at", "")
        return None

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.TitleRole: b"title",
            self.AmountRole: b"amount",
            self.PaidByRole: b"paid_by",
            self.SplitTypeRole: b"split_type",
            self.ExcludedRole: b"excluded",
            self.CreatedAtRole: b"created_at",
        }


class ParticipantModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2

    def __init__(self, parent=None):
        super().__init__(parent)
        self._participants = []

    def setParticipants(self, participants):
        """Update the participant list"""
        self.beginResetModel()
        self._participants = participants
        self.endResetModel()

    def rowCount(self, parent=QModelIndex()):
        return len(self._participants)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._participants)):
            return None

        participant = self._participants[index.row()]
        if role == self.IdRole:
            return participant["id"]
        if role == self.NameRole:
            return participant["name"]
        return None

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
        }

    @Slot(int, result=dict)
    def get(self, row):
        """Returns dict with all roles for given row"""
        if not (0 <= row < len(self._participants)):
            return {}

        participant = self._participants[row]
        return {"id": participant["id"], "name": participant["name"]}

    @Slot(str, result=int)
    def indexOfId(self, participant_id: str):
        """Returns the index of the participant with the given ID, or -1 if not found"""
        for row, participant in enumerate(self._participants):
            if participant["id"] == participant_id:
                return row
        return -1

    @Slot(str, result=str)
    def nameOfId(self, participant_id: str):
        """Returns the name of the participant with the given ID, or empty string if not found"""
        for participant in self._participants:
            if participant["id"] == participant_id:
                return participant["name"]
        return ""
