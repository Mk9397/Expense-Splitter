import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

import components
import dialogs
import popups
import theme

import "TripPage"

Page {
    id: root
    property string tripId: ""
    property string tripName: tripManager ? tripManager.activeTrip.name : ""

    property string tripCurrency: tripManager ? tripManager.activeTrip.currency : ""
    property string currencySymbol: settingsManager ? settingsManager.getCurrencySymbol(
                                                          tripCurrency) : ""
    property real totalAmount: tripManager ? tripManager.totalSpent : 0

    property int participantCount: tripManager ? tripManager.participantCount : 0
    property var participantModel: tripManager ? tripManager.participantModel : null

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
                onClicked: {
                    root.StackView.view.pop()
                    tripManager.setActiveTrip("")
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
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
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Menu {
                id: tripOptionsMenu
                x: parent.width
                y: parent.height

                MenuItem {
                    text: "Edit Trip"
                    icon.source: "qrc:/icons/edit.svg"
                    onTriggered: {
                        editTripDialog.tripName = root.tripName
                        editTripDialog.participants = tripManager.participantsList
                        editTripDialog.tripCurrency = root.tripCurrency
                        editTripDialog.open()
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                MenuItem {
                    text: "Share Trip"
                    icon.source: "qrc:/icons/share.svg"
                    onTriggered: {
                        let path = tripManager.shareTrip(root.tripId)
                        if (!path)
                            return
                        shareToast.pdfPath = path

                        let fileName = path.replace(/^.*[\\/]/, "")
                        shareToast.fileName = fileName

                        let pathParts = path.split(/[\\/]/)
                        pathParts.pop()
                        shareToast.displayPath = ".../" + pathParts.slice(
                                    -3).join('/')
                        shareToast.open()
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                MenuSeparator {}
                MenuItem {
                    text: "Delete Trip"
                    icon.source: "qrc:/icons/delete.svg"
                    icon.color: Material.color(Material.Red)
                    onTriggered: {
                        if (!settingsManager.confirmDeleteGroups) {
                            root.StackView.view.pop()
                            tripManager.deleteTrip(root.tripId)
                        } else {
                            deleteTripDialog.tripId = root.tripId
                            deleteTripDialog.tripName = root.tripName
                            deleteTripDialog.open()
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Trip Stats Card
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            Layout.topMargin: 16
            Layout.bottomMargin: 12

            height: 88
            radius: 16
            color: ThemeManager.accentCardBackground
            border.color: ThemeManager.accentCardBorder
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
                anchors.margins: 20
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Label {
                        text: "PARTICIPANTS"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: root.participantCount.toString()
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    color: ThemeManager.accentCardBorder
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Label {
                        text: "TOTAL"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: currencySymbol + formatAmount(totalAmount)
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    color: ThemeManager.accentCardBorder
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Label {
                        text: "AVG SHARE"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: {
                            let avgShare = 0
                            if (root.participantCount)
                                avgShare = tripManager ? tripManager.averageSharePerPerson : 0.00
                            return currencySymbol + formatAmount(avgShare)
                        }
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: Material.accent
                    }
                }
            }
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            TabButton {
                text: "Expenses"
                font.weight: Font.Medium
                font.pixelSize: 14

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
            TabButton {
                text: "Participants"
                font.weight: Font.Medium
                font.pixelSize: 14

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
            TabButton {
                text: "Balances"
                font.weight: Font.Medium
                font.pixelSize: 14

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Tab Content
        SwipeView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: tabBar.currentIndex
            onCurrentIndexChanged: tabBar.currentIndex = currentIndex

            // Expenses Tab
            ExpensesTab {
                participantModel: root.participantModel
                currencySymbol: root.currencySymbol
                participantCount: root.participantCount
                expenseModel: tripManager ? tripManager.expenseModel : null

                onAddExpenseClicked: {
                    addExpenseDialog.participantModel = root.participantModel
                    addExpenseDialog.open()
                }
                onEditExpenseClicked: function (id, title, amount, paidById, splitType, excludedIds) {
                    editExpenseDialog.expenseId = id
                    editExpenseDialog.expenseTitle = title
                    editExpenseDialog.expenseAmount = amount
                    editExpenseDialog.paidById = paidById
                    editExpenseDialog.splitType = splitType
                    editExpenseDialog.excludedIds = excludedIds
                    editExpenseDialog.participantModel = root.participantModel
                    editExpenseDialog.open()
                }
                onDeleteExpenseClicked: function (id, title) {
                    if (!settingsManager.confirmDeleteExpenses) {
                        tripManager.deleteExpense(id)
                    } else {
                        deleteExpenseDialog.expenseId = id
                        deleteExpenseDialog.expenseTitle = title
                        deleteExpenseDialog.open()
                    }
                }
            }

            // Participants Tab
            ParticipantsTab {
                participantModel: root.participantModel
                currencySymbol: root.currencySymbol
                participantBalances: tripManager ? tripManager.participantBalances : ({})

                onAddParticipantClicked: addParticipantDialog.open()
                onDeleteParticipantClicked: function (id, name) {
                    deleteParticipantDialog.participantId = id
                    deleteParticipantDialog.participantName = name
                    deleteParticipantDialog.open()
                }
            }

            // Settlement Tab
            SettlementsTab {
                settlementModel: tripManager ? tripManager.settlementModel : null
                currencySymbol: root.currencySymbol
            }
        }
    }

    Component.onCompleted: tripManager.setActiveTrip(tripId)

    ToastPopup {
        id: shareToast
    }

    EditTripDialog {
        id: editTripDialog
        tripId: root.tripId

        onTripEdited: function (tripId, tripName, participants, tripCurrency) {
            tripManager.editTrip(tripId, tripName, participants, tripCurrency)
        }
    }

    ExpenseDialog {
        id: addExpenseDialog
        isEditMode: false
        participantModel: root.participantModel

        onExpenseAccepted: function (expenseId, title, amount, paidBy, splitType, excluded) {
            tripManager.addExpense(title, amount, paidBy, splitType, excluded)
        }
    }

    ExpenseDialog {
        id: editExpenseDialog
        isEditMode: true
        participantModel: root.participantModel

        onExpenseAccepted: function (expenseId, title, amount, paidBy, splitType, excluded) {
            tripManager.editExpense(expenseId, title, amount, paidBy,
                                    splitType, excluded)
        }
    }

    GenericInputDialog {
        id: addParticipantDialog
        dialogTitle: "Add New Participant"
        placeholderText: "Name"
        confirmButtonText: "Add Participant"

        onInputAccepted: function (text) {
            tripManager.addParticipant(text)
        }
    }

    ConfirmationDialog {
        id: deleteTripDialog
        property string tripId: ""
        property string tripName: ""

        title: "Delete Group"
        message: "Are you sure you want to delete \"" + tripName + "\"?"
        warningText: "This action cannot be undone."
        confirmText: "Delete"
        confirmColor: Material.color(Material.Red)
        onConfirmed: {
            root.StackView.view.pop()
            tripManager.deleteTrip(tripId)
        }
    }

    ConfirmationDialog {
        id: deleteExpenseDialog
        property string expenseId: ""
        property string expenseTitle: ""

        title: "Delete Expense"
        message: "Are you sure you want to delete \"" + expenseTitle + "\" from this group?"
        warningText: "This action cannot be undone."
        confirmText: "Delete"
        confirmColor: Material.color(Material.Red)
        onConfirmed: tripManager.deleteExpense(expenseId)
    }

    ConfirmationDialog {
        id: deleteParticipantDialog
        property string participantId: ""
        property string participantName: ""

        title: "Remove Participant"
        message: "Are you sure you want to remove \"" + participantName + "\" from this group?"
        warningText: "This action cannot be undone."
        confirmText: "Remove"
        confirmColor: Material.color(Material.Red)
        onConfirmed: tripManager.deleteParticipant(participantId)
    }
}
