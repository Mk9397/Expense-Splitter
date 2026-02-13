from PySide6.QtCore import Property, QObject, QSettings, Signal, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "com.expensesplitter.backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0


@QmlElement
class SettingsManager(QObject):
    """Global settings manager for app-wide preferences"""

    themeChanged = Signal()
    currencyChanged = Signal()
    languageChanged = Signal()
    lastGroupIdChanged = Signal()
    openLastGroupChanged = Signal()
    confirmDeleteGroupsChanged = Signal()
    confirmDeleteExpensesChanged = Signal()

    VALID_THEMES = {"system", "light", "dark"}
    VALID_CURRENCIES = {"USD", "EUR", "GBP", "JPY", "NGN", "CAD", "AUD"}

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")

        self._theme = self.settings.value("theme", "system")
        self._currency = self.settings.value("currency", "NGN")
        self._language = self.settings.value("language", "en")
        self._last_group_id = self.settings.value("last_group_id", "")
        self._open_last_group = self.settings.value("open_last_group", True, type=bool)
        self._confirm_delete_groups = self.settings.value(
            "confirm_delete_groups", True, type=bool
        )
        self._confirm_delete_expenses = self.settings.value(
            "confirm_delete_expenses", True, type=bool
        )

    # Theme property
    @Property(str, notify=themeChanged)
    def theme(self):
        return self._theme

    @theme.setter
    def theme(self, value):
        if self._theme != value:
            self._theme = value
            self.settings.setValue("theme", value)
            self.themeChanged.emit()

    @Slot(str)
    def setTheme(self, theme: str):
        if theme not in self.VALID_THEMES:
            print(f"Warning: Invalid theme '{theme}', using 'system'")
            theme = "system"
        self.theme = theme

    # Currency property
    @Property(str, notify=currencyChanged)
    def currency(self):
        return self._currency

    @currency.setter
    def currency(self, value):
        if self._currency != value:
            self._currency = value
            self.settings.setValue("currency", value)
            self.currencyChanged.emit()

    @Slot(str)
    def setCurrency(self, currency: str):
        if currency not in self.VALID_CURRENCIES:
            print(f"Warning: Invalid currency '{currency}', using 'NGN'")
            currency = "NGN"
        self.currency = currency

    # Language property
    @Property(str, notify=languageChanged)
    def language(self):
        return self._language

    @language.setter
    def language(self, value):
        if self._language != value:
            self._language = value
            self.settings.setValue("language", value)
            self.languageChanged.emit()

    @Slot(str)
    def setLanguage(self, language: str):
        self.language = language

    # Last group_id property
    @Property(str, notify=lastGroupIdChanged)
    def lastGroupId(self):
        return self._last_group_id

    @lastGroupId.setter
    def lastGroupId(self, value):
        if self._last_group_id != value:
            self._last_group_id = value
            self.settings.setValue("last_group_id", value)
            self.lastGroupIdChanged.emit()

    @Slot(str)
    def setLastGroupId(self, group_id):
        self.lastGroupId = group_id

    # Open last group on startup property
    @Property(bool, notify=openLastGroupChanged)
    def openLastGroup(self):
        return self._open_last_group

    @openLastGroup.setter
    def openLastGroup(self, value):
        if self._open_last_group != value:
            self._open_last_group = value
            self.settings.setValue("open_last_group", value)
            self.openLastGroupChanged.emit()

    @Slot(bool)
    def setOpenLastGroup(self, enabled: bool):
        self.openLastGroup = enabled

    # Confirm delete groups property
    @Property(bool, notify=confirmDeleteGroupsChanged)
    def confirmDeleteGroups(self):
        return self._confirm_delete_groups

    @confirmDeleteGroups.setter
    def confirmDeleteGroups(self, value):
        if self._confirm_delete_groups != value:
            self._confirm_delete_groups = value
            self.settings.setValue("confirm_delete_groups", value)
            self.confirmDeleteGroupsChanged.emit()

    @Slot(bool)
    def setConfirmDeleteGroups(self, enabled: bool):
        self.confirmDeleteGroups = enabled

    # Confirm delete expenses property
    @Property(bool, notify=confirmDeleteExpensesChanged)
    def confirmDeleteExpenses(self):
        return self._confirm_delete_expenses

    @confirmDeleteExpenses.setter
    def confirmDeleteExpenses(self, value):
        if self._confirm_delete_expenses != value:
            self._confirm_delete_expenses = value
            self.settings.setValue("confirm_delete_expenses", value)
            self.confirmDeleteExpensesChanged.emit()

    @Slot(bool)
    def setConfirmDeleteExpenses(self, enabled: bool):
        self.confirmDeleteExpenses = enabled

    # Helper methods
    @Slot(result=list)
    def getAvailableCurrencies(self):
        """Return list of supported currencies"""
        return [
            {"code": "USD", "symbol": "$", "name": "US Dollar"},
            {"code": "EUR", "symbol": "€", "name": "Euro"},
            {"code": "GBP", "symbol": "£", "name": "British Pound"},
            {"code": "JPY", "symbol": "¥", "name": "Japanese Yen"},
            {"code": "NGN", "symbol": "₦", "name": "Nigerian Naira"},
            {"code": "CAD", "symbol": "$", "name": "Canadian Dollar"},
            {"code": "AUD", "symbol": "$", "name": "Australian Dollar"},
        ]

    @Slot(str, result=str)
    def getCurrencySymbol(self, code: str = None):
        """Get currency symbol for a given code"""
        if code is None:
            code = self.currency
        currencies = self.getAvailableCurrencies()
        for curr in currencies:
            if curr["code"] == code:
                return curr["symbol"]
        return code

    @Slot()
    def resetToDefaults(self):
        """Reset all settings to defaults"""
        self.theme = "system"
        self.currency = "NGN"
        self.language = "en"
        self.openLastGroup = True
        self.confirmDeleteGroups = True
        self.confirmDeleteExpenses = True
