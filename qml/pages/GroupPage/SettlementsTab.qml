import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import components
import singletons
import theme

ColumnLayout {
    id: root
    spacing: 2

    function formatAmount(amount) {
        return Number(amount).toLocaleString(Qt.locale(), 'f', 2)
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 16
        Layout.topMargin: 12
        Layout.bottomMargin: 8
        spacing: 12

        Label {
            text: "Balances"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            Layout.fillWidth: true
            opacity: 0.87
        }

        Rectangle {
            width: 56
            height: 22
            radius: 11
            color: ThemeManager.isDark ? Qt.rgba(1, 1, 1, 0.1) : Material.color(
                                             Material.Grey, Material.Shade200)

            Label {
                anchors.centerIn: parent
                text: settlementList.count + " items"
                opacity: 0.7
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    ListView {
        id: settlementList
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        spacing: 10
        clip: true

        model: AppState.settlementModel

        delegate: SettlementCard {
            width: ListView.view.width
            debtor: model.from_name
            creditor: model.to_name
            amount: root.formatAmount(model.amount)
            currencySymbol: AppState.currencySymbol
        }
    }
}
