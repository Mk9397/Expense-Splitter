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
    property string tripName: ""
    property int memberCount: 0

    property int totalExpenses: 0

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 64

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16
            spacing: 4

            ToolButton {
                icon.source: "qrc:/icons/chevron_left.svg"
                onClicked: root.StackView.view.pop()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Label {
                text: root.tripName
                Layout.alignment: Qt.AlignVCenter
                font.weight: Font.DemiBold
                font.pixelSize: 19
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            ToolButton {
                icon.name: 'preferences-other'
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
                    onClicked: settlementDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
                }
                MenuItem {
                    text: "Edit Trip"
                    onClicked: console.log("TODO: Edit Trip")
                    Component.onCompleted: pointerCursor.createObject(this)
                }
                MenuItem {
                    text: "Delete Trip"
                    onClicked: console.log("TODO: Delete Trip")
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
                        font.pixelSize: 36
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
                        text: totalAmount()
                        font.pixelSize: 36
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
                        text: "₦" + (totalAmount(
                                         ) / root.memberCount).toFixed(0)
                        font.pixelSize: 36
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

            model: ListModel {}

            delegate: ExpenseCard {
                width: ListView.view.width
                expenseTitle: title
                expenseAmount: amount
                expenseIcon: icon
                paidBy: paid
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

    // Refresh list from Python backend
    function refreshExpenseList() {
        expenseList.model.clear()
        var expenses = tripManager.getTripById(tripId)["expenses"]
        totalExpenses = expenses.length

        expenses.forEach(expense => {
                             expenseList.model.append({
                                                          "id": expense.id,
                                                          "title": expense.title,
                                                          "amount": expense.amount,
                                                          "paid": expense.paid_by
                                                      })
                         })
    }

    function totalAmount() {
        var expenses = tripManager.getTripById(tripId)["expenses"]
        var total = 0
        expenses.forEach(expense => total += expense.amount)
        return total
    }

    // Load expenses on startup
    Component.onCompleted: {
        refreshExpenseList()
    }

    // Listen for changes from Python
    Connections {
        target: tripManager
        function onTripsChanged() {
            refreshExpenseList()
        }
    }

    SettlementDialog {
        id: settlementDialog
    }

    AddExpenseDialog {
        id: addExpenseDialog
        onExpenseCreated: function (expenseTitle, expenseAmount, paidBy) {
            tripManager.addExpense(tripId, expenseTitle, expenseAmount, paidBy)
        }
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
