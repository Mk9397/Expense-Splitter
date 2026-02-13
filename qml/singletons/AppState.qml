pragma Singleton

import QtQuick

QtObject {
    id: root

    // Reference to Python context property (internal)
    readonly property var _appState: typeof appState !== 'undefined' ? appState : null

    // Group properties
    readonly property string groupId: _appState?.groupId ?? ""
    readonly property string groupName: _appState?.groupName ?? ""
    readonly property string groupCurrency: _appState?.groupCurrency ?? ""
    readonly property string currencySymbol: _appState?.currencySymbol ?? ""

    // Numeric properties
    readonly property int participantCount: _appState?.participantCount ?? 0
    readonly property real totalSpent: _appState?.totalSpent ?? 0.0
    readonly property real averageShare: _appState?.averageShare ?? 0.0

    // Model properties
    readonly property var participantList: _appState?.participantList ?? []
    readonly property var participantModel: _appState?.participantModel ?? null
    readonly property var expenseModel: _appState?.expenseModel ?? null
    readonly property var settlementModel: _appState?.settlementModel ?? null
    readonly property var participantBalances: _appState?.participantBalances
                                               ?? ({})

    // Computed/formatted properties
    readonly property string formattedTotal: formatCurrency(totalSpent)
    readonly property string formattedAverage: formatCurrency(averageShare)

    // Helper functions
    function formatAmount(amount) {
        return Number(amount).toLocaleString(Qt.locale(), 'f', 2)
    }

    function formatCurrency(amount) {
        return currencySymbol + formatAmount(amount)
    }

    function reset() {
        _appState?.reset()
    }
}
