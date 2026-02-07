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
    property int participantCount: tripManager ? tripManager.participantCount : 0

    property string currencySymbol: settingsManager ? settingsManager.getCurrencySymbol(
                                                          tripCurrency) : ""

    property real totalAmount: tripManager ? tripManager.totalSpent : 0
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
                                avgShare = tripManager.averageSharePerPerson
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

            // ExpensesTab {
            //     id: expensesTab
            // }

            // Expenses Tab
            ColumnLayout {
                spacing: 2

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
                        color: ThemeManager.isDark ? Qt.rgba(
                                                         1, 1, 1,
                                                         0.1) : Material.color(
                                                         Material.Grey,
                                                         Material.Shade200)

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

                    model: tripManager ? tripManager.expenseModel : null

                    delegate: ExpenseCard {
                        width: ListView.view.width

                        expenseTitle: title
                        expenseAmount: amount
                        expenseIcon: "💵"
                        paidBy: participantModel ? participantModel.nameOfId(
                                                       paid_by) : "Participant ID: " + paid_by
                        splitType: split_type
                        excludedIds: excluded ?? []

                        tripCurrencySymbol: root.currencySymbol
                        participantCount: root.participantCount
                        onEditExpense: {
                            editExpenseDialog.expenseId = id
                            editExpenseDialog.expenseTitle = title
                            editExpenseDialog.expenseAmount = amount
                            editExpenseDialog.paidById = paid_by
                            editExpenseDialog.splitType = split_type
                            editExpenseDialog.excludedIds = excluded.slice()
                            editExpenseDialog.participantModel = root.participantModel
                            editExpenseDialog.open()
                        }
                        onDeleteExpense: {
                            if (!settingsManager.confirmDeleteExpenses) {
                                tripManager.deleteExpense(id)
                            } else {
                                deleteExpenseDialog.expenseId = id
                                deleteExpenseDialog.expenseTitle = title
                                deleteExpenseDialog.open()
                            }
                        }
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
                    onClicked: {
                        addExpenseDialog.participantModel = root.participantModel
                        addExpenseDialog.open()
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // ParticipantsTab {
            //     id: participantsTab
            // }

            // Participants Tab
            ColumnLayout {
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 12
                    Layout.bottomMargin: 8
                    spacing: 12

                    Label {
                        text: "Participants"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                        opacity: 0.87
                    }

                    Rectangle {
                        width: 84
                        height: 22
                        radius: 11
                        color: ThemeManager.isDark ? Qt.rgba(
                                                         1, 1, 1,
                                                         0.1) : Material.color(
                                                         Material.Grey,
                                                         Material.Shade200)

                        Label {
                            anchors.centerIn: parent
                            text: participantList.count + " participants"
                            opacity: 0.7
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }

                ListView {
                    id: participantList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 10
                    clip: true

                    model: root.participantModel

                    delegate: ParticipantCard {
                        required property string id
                        required property string name

                        width: ListView.view.width
                        participantName: name
                        currencySymbol: root.currencySymbol

                        property var balanceData: tripManager.participantBalances[id]
                                                  ?? {}

                        totalPaid: balanceData.total_paid ?? 0
                        shouldPay: balanceData.should_pay ?? 0
                        balance: balanceData.balance ?? 0

                        onDeleteParticipant: {
                            deleteParticipantDialog.participantId = id
                            deleteParticipantDialog.participantName = name
                            deleteParticipantDialog.open()
                        }
                    }
                }

                Button {
                    text: "Add Participant"
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 8
                    Layout.preferredHeight: 48
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    Material.elevation: 3
                    highlighted: true
                    onClicked: addParticipantDialog.open()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // SettlementsTab {
            //     id: settlementTab
            // }

            // Settlement Tab
            ColumnLayout {
                spacing: 2

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
                        color: ThemeManager.isDark ? Qt.rgba(
                                                         1, 1, 1,
                                                         0.1) : Material.color(
                                                         Material.Grey,
                                                         Material.Shade200)

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

                    model: tripManager ? tripManager.settlementModel : null

                    delegate: SettlementCard {
                        width: ListView.view.width
                        debtor: model.from_name
                        creditor: model.to_name
                        amount: formatAmount(model.amount)
                        currencySymbol: root.currencySymbol
                    }
                }
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

    AddExpenseDialog {
        id: addExpenseDialog
        onExpenseCreated: function (expenseTitle, expenseAmount, paidBy, split_type, excluded) {
            tripManager.addExpense(expenseTitle, expenseAmount, paidBy,
                                   split_type, excluded)
        }
    }

    EditExpenseDialog {
        id: editExpenseDialog
        onExpenseEdited: function (expenseId, expenseTitle, expenseAmount, paidBy, split_type, excluded) {
            tripManager.editExpense(expenseId, expenseTitle, expenseAmount,
                                    paidBy, split_type, excluded)
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

    AddParticipantDialog {
        id: addParticipantDialog
        onParticipantCreated: function (participantName) {
            tripManager.addParticipant(participantName)
        }
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
