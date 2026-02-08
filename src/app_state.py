from PySide6.QtCore import QObject, Signal, Property, Slot


class AppState(QObject):
    # Signals for all state changes
    tripIdChanged = Signal(str)
    tripNameChanged = Signal(str)
    tripCurrencyChanged = Signal(str)
    currencySymbolChanged = Signal(str)
    participantCountChanged = Signal(int)
    totalSpentChanged = Signal(float)
    averageShareChanged = Signal(float)

    participantListChanged = Signal("QVariantList")

    participantModelChanged = Signal()
    expenseModelChanged = Signal()
    settlementModelChanged = Signal()
    participantBalancesChanged = Signal()

    def __init__(self):
        super().__init__()

        # Trip state
        self._trip_id = ""
        self._trip_name = ""
        self._trip_currency = ""
        self._currency_symbol = ""
        self._participant_count = 0
        self._total_spent = 0.0
        self._average_share = 0.0
        self._participant_list = []

        # Model references
        self._participant_model = None
        self._expense_model = None
        self._settlement_model = None
        self._participant_balances = {}

    # Trip ID
    @Property(str, notify=tripIdChanged)
    def tripId(self):
        return self._trip_id

    @tripId.setter
    def tripId(self, value):
        if self._trip_id != value:
            self._trip_id = value
            self.tripIdChanged.emit(value)

    # Trip Name
    @Property(str, notify=tripNameChanged)
    def tripName(self):
        return self._trip_name

    @tripName.setter
    def tripName(self, value):
        if self._trip_name != value:
            self._trip_name = value
            self.tripNameChanged.emit(value)

    # Trip Currency
    @Property(str, notify=tripCurrencyChanged)
    def tripCurrency(self):
        return self._trip_currency

    @tripCurrency.setter
    def tripCurrency(self, value):
        if self._trip_currency != value:
            self._trip_currency = value
            self.tripCurrencyChanged.emit(value)

    # Currency Symbol
    @Property(str, notify=currencySymbolChanged)
    def currencySymbol(self):
        return self._currency_symbol

    @currencySymbol.setter
    def currencySymbol(self, value):
        if self._currency_symbol != value:
            self._currency_symbol = value
            self.currencySymbolChanged.emit(value)

    # Participant Count
    @Property(int, notify=participantCountChanged)
    def participantCount(self):
        return self._participant_count

    @participantCount.setter
    def participantCount(self, value):
        if self._participant_count != value:
            self._participant_count = value
            self.participantCountChanged.emit(value)

    # Total Spent
    @Property(float, notify=totalSpentChanged)
    def totalSpent(self):
        return self._total_spent

    @totalSpent.setter
    def totalSpent(self, value):
        if self._total_spent != value:
            self._total_spent = value
            self.totalSpentChanged.emit(value)

    # Average Share
    @Property(float, notify=averageShareChanged)
    def averageShare(self):
        return self._average_share

    @averageShare.setter
    def averageShare(self, value):
        if self._average_share != value:
            self._average_share = value
            self.averageShareChanged.emit(value)

    # Participant List
    @Property("QVariantList", notify=participantListChanged)
    def participantList(self):
        """Get the list of participants"""
        return self._participant_list

    @participantList.setter
    def participantList(self, value):
        if self._participant_list != value:
            self._participant_list = value
            self.participantListChanged.emit(value)

    # Models (var type for QML)
    @Property("QVariant", notify=participantModelChanged)
    def participantModel(self):
        return self._participant_model

    @participantModel.setter
    def participantModel(self, value):
        self._participant_model = value
        self.participantModelChanged.emit()

    @Property("QVariant", notify=expenseModelChanged)
    def expenseModel(self):
        return self._expense_model

    @expenseModel.setter
    def expenseModel(self, value):
        self._expense_model = value
        self.expenseModelChanged.emit()

    @Property("QVariant", notify=settlementModelChanged)
    def settlementModel(self):
        return self._settlement_model

    @settlementModel.setter
    def settlementModel(self, value):
        self._settlement_model = value
        self.settlementModelChanged.emit()

    @Property("QVariant", notify=participantBalancesChanged)
    def participantBalances(self):
        return self._participant_balances

    @participantBalances.setter
    def participantBalances(self, value):
        self._participant_balances = value
        self.participantBalancesChanged.emit()

    # Helper methods
    @Slot(result=str)
    def reset(self):
        """Reset all trip state"""
        self.tripId = ""
        self.tripName = ""
        self.tripCurrency = ""
        self.currencySymbol = ""
        self.participantCount = 0
        self.totalSpent = 0.0
        self.averageShare = 0.0
        self.participantList = []
        self.participantModel = None
        self.expenseModel = None
        self.settlementModel = None
        self.participantBalances = {}
