import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import "../components"
import "../dialogs"

Page {
    id: root
    property string tripId: ""
    property string tripName: tripManager ? tripManager.currentTrip.name : ""
    property string tripCurrency: tripManager ? tripManager.currentTrip.currency : ""
    property int memberCount: tripManager ? tripManager.memberCount : 0

    property string currencySymbol: settingsManager ? settingsManager.getCurrencySymbol(
                                                          tripCurrency) : ""

    property real totalAmount: tripManager ? tripManager.totalTripAmount : 0
    property var memberModel: tripManager ? tripManager.memberModel : null

    function formatAmount(amount) {
        return Number(amount).toLocaleString(Qt.locale(), 'f', 2)
    }

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 8
            spacing: 0

            ToolButton {
                icon.source: "qrc:/icons/chevron_left.svg"
                onClicked: root.StackView.view.pop()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Label {
                text: root.tripName
                Layout.alignment: Qt.AlignVCenter
                font.weight: Font.DemiBold
                font.pixelSize: 18
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            ToolButton {
                icon.source: 'qrc:/icons/more_vert.svg'
                onClicked: tripOptionsMenu.open()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Menu {
                id: tripOptionsMenu
                x: parent.width
                y: parent.height

                MenuItem {
                    text: "View Settlement"
                    onTriggered: settlementDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
                }

                MenuSeparator {}
                MenuItem {
                    text: "Edit Trip"
                    icon.source: "qrc:/icons/edit.svg"
                    onTriggered: {
                        editTripDialog.tripName = root.tripName
                        editTripDialog.members = tripManager.membersList
                        editTripDialog.tripCurrency = root.tripCurrency
                        editTripDialog.open()
                    }
                    Component.onCompleted: pointerCursor.createObject(this)
                }
                MenuItem {
                    text: "Share Trip"
                    icon.source: "qrc:/icons/share.svg"
                    onTriggered: console.log(
                                     "Yo, I've like been triggered and shi bruh")
                    Component.onCompleted: pointerCursor.createObject(this)
                }

                MenuSeparator {}
                MenuItem {
                    text: "Delete Trip"
                    icon.source: "qrc:/icons/delete.svg"
                    icon.color: Material.color(Material.Red)
                    onTriggered: {
                        deleteTripDialog.tripName = root.tripName
                        deleteTripDialog.open()
                    }
                    Component.onCompleted: pointerCursor.createObject(this)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.topMargin: 20
        spacing: 20

        // Trip Stats Card
        Rectangle {
            Layout.fillWidth: true
            height: 120
            radius: 20
            color: ApplicationWindow.window.accentCardBackground
            border.color: ApplicationWindow.window.accentCardBorder
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.1)
                shadowBlur: 0.4
                shadowVerticalOffset: 2
                shadowHorizontalOffset: 0
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Label {
                        text: "MEMBERS"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: root.memberCount.toString()
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 16
                    Layout.bottomMargin: 16
                    color: ApplicationWindow.window.accentCardBorder
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Label {
                        text: "TOTAL"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: currencySymbol + totalAmount.toFixed(2)
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 16
                    Layout.bottomMargin: 16
                    color: ApplicationWindow.window.accentCardBorder
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Label {
                        text: "PER PERSON"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: currencySymbol + (totalAmount / root.memberCount).toFixed(
                                  2)
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "Expenses"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                Layout.fillWidth: true
                opacity: 0.87
            }

            Rectangle {
                width: 52
                height: 24
                radius: 12
                color: Material.theme === Material.Dark ? Qt.rgba(
                                                              255 / 255,
                                                              255 / 255,
                                                              255 / 255,
                                                              0.1) : Material.color(
                                                              Material.Grey,
                                                              Material.Shade200)

                Label {
                    anchors.centerIn: parent
                    text: expenseList.count + " items"
                    opacity: 0.7
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }

        ListView {
            id: expenseList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true

            // model: ListModel {}
            model: tripManager ? tripManager.expenseModel : null

            delegate: ExpenseCard {
                width: ListView.view.width
                expenseTitle: title
                expenseAmount: amount
                expenseIcon: "💵"
                paidBy: paid_by
                tripCurrencySymbol: currencySymbol
                memberCount: root.memberCount
                onClicked: console.log("TODO: View/Edit Expense")
            }
        }

        Button {
            text: "Add Expense"
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            font.pixelSize: 15
            font.weight: Font.DemiBold
            Material.elevation: 3
            highlighted: true
            onClicked: addExpenseDialog.open()
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }

    Component.onCompleted: tripManager.setCurrentTrip(tripId)

    SettlementDialog {
        id: settlementDialog
    }

    AddExpenseDialog {
        id: addExpenseDialog
        onExpenseCreated: function (expenseTitle, expenseAmount, paidBy) {
            tripManager.addExpense(expenseTitle, expenseAmount, paidBy)
        }
    }

    DeleteTripDialog {
        id: deleteTripDialog
        tripId: root.tripId

        onTripDeleted: function (tripId) {
            root.StackView.view.pop()
            tripManager.deleteTrip(tripId)
        }
    }

    EditTripDialog {
        id: editTripDialog
        tripId: root.tripId

        onTripEdited: function (tripId, tripName, members, tripCurrency) {
            tripManager.editTrip(tripId, tripName, members, tripCurrency)
        }
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
