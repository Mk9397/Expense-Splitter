from PySide6.QtCore import QAbstractListModel, QModelIndex, QSortFilterProxyModel, Qt


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
