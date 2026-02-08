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

    signal addExpenseClicked
    signal editExpenseClicked(string id, string title, real amount, string paidById, string splitType, var excludedIds)
    signal deleteExpenseClicked(string id, string title)

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 16
        Layout.topMargin: 12
        Layout.bottomMargin: 8
        spacing: 12

        Label {
            text: "Expenses"
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
                text: expenseList.count + " items"
                opacity: 0.7
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    ListView {
        id: expenseList
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        spacing: 10
        clip: true

        // Empty State
        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.8
            visible: expenseList.count === 0

            Label {
                text: "No Expenses Yet"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.87
            }
            Label {
                text: "Add one to get started!"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                opacity: 0.6
            }
        }

        model: AppState.expenseModel

        delegate: ExpenseCard {
            width: ListView.view.width

            expenseTitle: title
            expenseAmount: amount
            expenseIcon: "💵"
            paidBy: AppState.participantModel?.nameOfId(paid_by) ?? ""
            splitType: split_type
            excludedIds: excluded ?? []

            tripCurrencySymbol: AppState.currencySymbol
            participantCount: AppState.participantCount

            onEditExpense: root.editExpenseClicked(id, title, amount, paid_by,
                                                   split_type, excluded.slice())

            onDeleteExpense: root.deleteExpenseClicked(id, title)
        }
    }

    Button {
        text: "Add Expense"
        Layout.fillWidth: true
        Layout.margins: 16
        Layout.topMargin: 8
        Layout.preferredHeight: 48
        font.pixelSize: 14
        font.weight: Font.DemiBold
        Material.elevation: 3
        highlighted: true

        onClicked: root.addExpenseClicked()

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
