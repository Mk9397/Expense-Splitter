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

    def __init__(self):
        super().__init__()
        self.settings = QSettings("Bells Uni", "ExpenseSplitter")

        self._theme = self.settings.value("theme", "system")
        self._currency = self.settings.value("currency", "NGN")
        self._language = self.settings.value("language", "en")

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
    def setTheme(self, theme):
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
    def setCurrency(self, currency):
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
    def setLanguage(self, language):
        self.language = language

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
    def getCurrencySymbol(self, code):
        """Get currency symbol for a given code"""
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
