import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import "../components"
import "../dialogs"
import "../popups"

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
        spacing: 0

        // Trip Stats Card
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            Layout.topMargin: 16
            Layout.bottomMargin: 12

            height: 88
            radius: 16
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
                anchors.margins: 20
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Label {
                        text: "MEMBERS"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        opacity: 0.65
                        color: Material.accent
                    }
                    Label {
                        text: root.memberCount.toString()
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
                    color: ApplicationWindow.window.accentCardBorder
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
                    color: ApplicationWindow.window.accentCardBorder
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
                            if (root.memberCount)
                                avgShare = tripManager.averageShouldPay
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
                Component.onCompleted: pointerCursor.createObject(this)
            }
            TabButton {
                text: "Members"
                font.weight: Font.Medium
                font.pixelSize: 14
                Component.onCompleted: pointerCursor.createObject(this)
            }
            TabButton {
                text: "Balances"
                font.weight: Font.Medium
                font.pixelSize: 14
                Component.onCompleted: pointerCursor.createObject(this)
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
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
                                                       255 / 255, 255 / 255,
                                                       255 / 255,
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

                    model: tripManager ? tripManager.expenseModel : null

                    delegate: ExpenseCard {
                        width: ListView.view.width
                        expenseTitle: title
                        expenseAmount: amount
                        expenseIcon: "💵"
                        paidBy: memberModel ? memberModel.nameOfId(
                                                  paid_by) : "Member ID: " + paid_by
                        splitType: split_type
                        excludedIds: excluded
                        tripCurrencySymbol: root.currencySymbol
                        memberCount: root.memberCount
                        onEditExpense: {
                            editExpenseDialog.expenseId = id
                            editExpenseDialog.expenseTitle = title
                            editExpenseDialog.expenseAmount = amount
                            editExpenseDialog.paidById = paid_by
                            editExpenseDialog.splitType = split_type
                            editExpenseDialog.excludedIds = excluded.slice()
                            editExpenseDialog.open()
                        }
                        onDeleteExpense: {
                            deleteExpenseDialog.expenseId = id
                            deleteExpenseDialog.expenseTitle = title
                            deleteExpenseDialog.open()
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
                    onClicked: addExpenseDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
                }
            }

            // MembersTab {
            //     id: membersTab
            // }

            // Members Tab
            ColumnLayout {
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 12
                    Layout.bottomMargin: 8
                    spacing: 12

                    Label {
                        text: "Members"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                        opacity: 0.87
                    }

                    Rectangle {
                        width: 68
                        height: 22
                        radius: 11
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
                                                       255 / 255, 255 / 255,
                                                       255 / 255,
                                                       0.1) : Material.color(
                                                       Material.Grey,
                                                       Material.Shade200)

                        Label {
                            anchors.centerIn: parent
                            text: memberList.count + " members"
                            opacity: 0.7
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }

                ListView {
                    id: memberList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 10
                    clip: true

                    model: root.memberModel

                    delegate: MemberCard {
                        width: ListView.view.width

                        property var memberBalance: tripManager.getMemberBalance(
                                                        id)
                        memberName: name
                        currencySymbol: root.currencySymbol

                        totalPaid: memberBalance ? memberBalance.total_paid : 0
                        shouldPay: memberBalance ? memberBalance.should_pay : 0
                        balance: memberBalance ? memberBalance.balance : 0

                        onDeleteMember: {
                            deleteMemberDialog.memberId = id
                            deleteMemberDialog.memberName = name
                            deleteMemberDialog.open()
                        }
                    }
                }

                Button {
                    text: "Add Member"
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 8
                    Layout.preferredHeight: 48
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    Material.elevation: 3
                    highlighted: true
                    onClicked: addMemberDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
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
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
                                                       255 / 255, 255 / 255,
                                                       255 / 255,
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

                    model: ListModel {
                        id: settlementModel
                    }

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

    Component.onCompleted: {
        tripManager.setCurrentTrip(tripId)

        let suggestions = tripManager ? tripManager.getSettlementSuggestions(
                                            ) : []
        for (let suggestion of suggestions) {
            settlementModel.append(suggestion)
        }
    }

    ToastPopup {
        id: shareToast
    }

    EditTripDialog {
        id: editTripDialog
        tripId: root.tripId

        onTripEdited: function (tripId, tripName, members, tripCurrency) {
            tripManager.editTrip(tripId, tripName, members, tripCurrency)
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

    AddExpenseDialog {
        id: addExpenseDialog
        memberModel: root.memberModel
        onExpenseCreated: function (expenseTitle, expenseAmount, paidBy, split_type, excluded) {
            tripManager.addExpense(expenseTitle, expenseAmount, paidBy,
                                   split_type, excluded)
        }
    }

    EditExpenseDialog {
        id: editExpenseDialog
        memberModel: root.memberModel
        onExpenseEdited: function (expenseId, expenseTitle, expenseAmount, paidBy, split_type, excluded) {
            tripManager.editExpense(expenseId, expenseTitle, expenseAmount,
                                    paidBy, split_type, excluded)
        }
    }

    DeleteExpenseDialog {
        id: deleteExpenseDialog
        onExpenseDeleted: function (expenseId) {
            tripManager.deleteExpense(expenseId)
        }
    }

    AddMemberDialog {
        id: addMemberDialog
        onMemberCreated: function (memberName) {
            tripManager.addMember(memberName)
        }
    }

    DeleteMemberDialog {
        id: deleteMemberDialog
        onMemberDeleted: function (memberId) {
            tripManager.deleteMember(memberId)
        }
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
