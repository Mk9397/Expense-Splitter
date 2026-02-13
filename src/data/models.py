from PySide6.QtCore import (
    QAbstractListModel,
    QModelIndex,
    QSortFilterProxyModel,
    Qt,
    Slot,
)
from PySide6.QtSql import QSqlQuery, QSqlQueryModel


class GroupSqlModel(QSqlQueryModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    CurrencyRole = Qt.UserRole + 3
    CreatedAtRole = Qt.UserRole + 4
    UpdatedAtRole = Qt.UserRole + 5
    ParticipantCountRole = Qt.UserRole + 6

    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db
        self.select()

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
            self.CurrencyRole: b"currency",
            self.CreatedAtRole: b"created_at",
            self.UpdatedAtRole: b"updated_at",
            self.ParticipantCountRole: b"participant_count",
        }

    def data(self, index, role=Qt.DisplayRole):
        if role >= Qt.UserRole:
            column_map = {
                self.IdRole: 0,
                self.NameRole: 1,
                self.CurrencyRole: 2,
                self.CreatedAtRole: 3,
                self.UpdatedAtRole: 4,
                self.ParticipantCountRole: 5,
            }
            return super().data(self.index(index.row(), column_map[role]))
        return super().data(index, role)

    def select(self):
        """Load groups with participant counts"""
        query = QSqlQuery(self.db)
        query.exec(
            """
            SELECT 
                t.id,
                t.name,
                t.currency,
                t.created_at,
                t.updated_at,
                COALESCE(COUNT(p.id), 0) as participant_count
            FROM trips t
            LEFT JOIN participants p ON t.id = p.trip_id
            GROUP BY t.id
            ORDER BY t.updated_at DESC
            """
        )
        self.setQuery(query)


class GroupFilterProxy(QSortFilterProxyModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setDynamicSortFilter(True)

        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterRole(GroupSqlModel.NameRole)

        self.setSortRole(GroupSqlModel.UpdatedAtRole)
        self.sort(0, Qt.DescendingOrder)

    @Slot()
    def sortByNameAsc(self):
        self.setSortRole(GroupSqlModel.NameRole)
        self.sort(0, Qt.AscendingOrder)

    @Slot()
    def sortByNameDesc(self):
        self.setSortRole(GroupSqlModel.NameRole)
        self.sort(0, Qt.DescendingOrder)

    @Slot()
    def sortByUpdatedDesc(self):
        self.setSortRole(GroupSqlModel.UpdatedAtRole)
        self.sort(0, Qt.DescendingOrder)

    @Slot()
    def sortByUpdatedAsc(self):
        self.setSortRole(GroupSqlModel.UpdatedAtRole)
        self.sort(0, Qt.AscendingOrder)

    @Slot()
    def sortByCreatedDesc(self):
        self.setSortRole(GroupSqlModel.CreatedAtRole)
        self.sort(0, Qt.DescendingOrder)

    @Slot()
    def sortByCreatedAsc(self):
        self.setSortRole(GroupSqlModel.CreatedAtRole)
        self.sort(0, Qt.AscendingOrder)


class ExpenseSqlModel(QSqlQueryModel):
    IdRole = Qt.UserRole + 1
    TitleRole = Qt.UserRole + 2
    AmountRole = Qt.UserRole + 3
    PaidByRole = Qt.UserRole + 4
    SplitTypeRole = Qt.UserRole + 5
    CreatedAtRole = Qt.UserRole + 6
    ExcludedRole = Qt.UserRole + 7

    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.TitleRole: b"title",
            self.AmountRole: b"amount",
            self.PaidByRole: b"paid_by",
            self.SplitTypeRole: b"split_type",
            self.CreatedAtRole: b"created_at",
            self.ExcludedRole: b"excluded",
        }

    def data(self, index, role):
        if role == self.ExcludedRole:
            csv = super().data(self.index(index.row(), 6))
            if csv:
                return [pid.strip() for pid in csv.split(",") if pid.strip()]
            return []

        if role >= Qt.UserRole:
            column_map = {
                self.IdRole: 0,
                self.TitleRole: 1,
                self.AmountRole: 2,
                self.PaidByRole: 3,
                self.SplitTypeRole: 4,
                self.CreatedAtRole: 5,
            }
            return super().data(self.index(index.row(), column_map[role]))
        return super().data(index, role)

    def setGroup(self, group_id):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            SELECT 
                e.id, 
                e.title, 
                e.amount, 
                e.paid_by, 
                e.split_type, 
                e.created_at,
                COALESCE(
                    (SELECT GROUP_CONCAT(ee.participant_id, ',')
                    FROM expense_excluded ee 
                    WHERE ee.expense_id = e.id),
                    ''
                ) AS excluded_csv
            FROM expenses e
            WHERE trip_id = ?
            ORDER BY e.created_at DESC
        """
        )
        query.addBindValue(group_id)
        query.exec()
        self.setQuery(query)


class ParticipantSqlModel(QSqlQueryModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2

    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db

    def roleNames(self):
        return {
            self.IdRole: b"id",
            self.NameRole: b"name",
        }

    def data(self, index, role):
        if role >= Qt.UserRole:
            column_map = {
                self.IdRole: 0,
                self.NameRole: 1,
            }
            return super().data(self.index(index.row(), column_map[role]))
        return super().data(index, role)

    def setGroup(self, group_id):
        query = QSqlQuery(self.db)
        query.prepare(
            """
            SELECT id, name
            FROM participants
            WHERE trip_id = ?
        """
        )
        query.addBindValue(group_id)
        query.exec()
        self.setQuery(query)

    @Slot(str, result=int)
    def indexOfId(self, participant_id: str):
        for row in range(self.rowCount()):
            if self.data(self.index(row, 0), self.IdRole) == participant_id:
                return row
        return -1

    @Slot(str, result=str)
    def nameOfId(self, participant_id: str):
        query = QSqlQuery(self.db)
        query.prepare("SELECT name FROM participants WHERE id = ?")
        query.addBindValue(participant_id)
        query.exec()
        return query.next() and query.value(0) or ""


class ParticipantProxyModelWithNobody(QSortFilterProxyModel):
    """Adds a 'None' option as the first row in participant list"""

    def __init__(self, sourceModel=None, parent=None):
        super().__init__(parent)
        if sourceModel:
            self.setSourceModel(sourceModel)

    def rowCount(self, parent=QModelIndex()):
        """Add 1 for the 'None' row"""
        return super().rowCount(parent) + 1

    def data(self, index, role=Qt.DisplayRole):
        """Return 'None' data for row 0, source data for others"""
        if not index.isValid():
            return None

        if index.row() == 0:
            if role == ParticipantSqlModel.IdRole:
                return ""
            elif role == ParticipantSqlModel.NameRole:
                return "None"
            return None

        sourceRow = index.row() - 1
        sourceIndex = self.sourceModel().index(sourceRow, 0)
        return self.sourceModel().data(sourceIndex, role)

    def index(self, row, column, parent=QModelIndex()):
        """Create index for proxy model"""
        if row < 0 or row >= self.rowCount(parent) or column != 0:
            return QModelIndex()
        return self.createIndex(row, column)

    def roleNames(self):
        """Forward roleNames from source model"""
        if self.sourceModel():
            return self.sourceModel().roleNames()
        return {}

    @Slot(str, result=int)
    def indexOfId(self, participant_id: str):
        """Find index by participant ID"""
        if not participant_id:
            return 0

        for row in range(1, self.rowCount()):
            if (
                self.data(self.index(row, 0), ParticipantSqlModel.IdRole)
                == participant_id
            ):
                return row

        return 0

    @Slot(str, result=str)
    def nameOfId(self, participant_id: str):
        """Get name by participant ID"""
        if not participant_id:
            return "None"

        if hasattr(self.sourceModel(), "nameOfId"):
            return self.sourceModel().nameOfId(participant_id)
        return ""


class SettlementModel(QAbstractListModel):
    FromIdRole = Qt.UserRole + 1
    FromNameRole = Qt.UserRole + 2
    ToIdRole = Qt.UserRole + 3
    ToNameRole = Qt.UserRole + 4
    AmountRole = Qt.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._settlements = []

    def setSettlements(self, settlements):
        """Update the expense list"""
        self.beginResetModel()
        self._settlements = settlements
        self.endResetModel()

    def rowCount(self, parent=QModelIndex()):
        return len(self._settlements)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self._settlements)):
            return None

        settlement = self._settlements[index.row()]
        if role == self.FromIdRole:
            return settlement["from_id"]
        if role == self.FromNameRole:
            return settlement["from_name"]
        if role == self.ToIdRole:
            return settlement["to_id"]
        if role == self.ToNameRole:
            return settlement["to_name"]
        if role == self.AmountRole:
            return settlement["amount"]
        return None

    def roleNames(self):
        return {
            self.FromIdRole: b"from_id",
            self.FromNameRole: b"from_name",
            self.ToIdRole: b"to_id",
            self.ToNameRole: b"to_name",
            self.AmountRole: b"amount",
        }
