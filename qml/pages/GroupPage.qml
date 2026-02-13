import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

import dialogs
import popups
import singletons
import theme

import "GroupPage"

Page {
    id: root
    property string groupId: ""

    Component.onCompleted: groupManager.setActiveGroup(groupId)
    Component.onDestruction: AppState.reset()

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

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Label {
                text: AppState.groupName
                Layout.alignment: Qt.AlignVCenter
                font.weight: Font.DemiBold
                font.pixelSize: 18
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            ToolButton {
                icon.source: 'qrc:/icons/more_vert.svg'
                onClicked: groupOptionsMenu.open()
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Menu {
                id: groupOptionsMenu
                x: parent.width
                y: parent.height

                MenuItem {
                    text: "Edit Group"
                    icon.source: "qrc:/icons/edit.svg"
                    onTriggered: {
                        editGroupDialog.groupName = AppState.groupName
                        editGroupDialog.participants = AppState.participantList
                        editGroupDialog.groupCurrency = AppState.groupCurrency
                        editGroupDialog.open()
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                MenuItem {
                    text: "Share Group"
                    icon.source: "qrc:/icons/share.svg"
                    onTriggered: {
                        let path = groupManager.shareGroup(root.groupId)
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
                    text: "Delete Group"
                    icon.source: "qrc:/icons/delete.svg"
                    icon.color: Material.color(Material.Red)
                    onTriggered: {
                        if (!settingsManager.confirmDeleteGroups) {
                            root.StackView.view.pop()
                            groupManager.deleteGroup(root.groupId)
                        } else {
                            deleteGroupDialog.groupId = root.groupId
                            deleteGroupDialog.groupName = AppState.groupName
                            deleteGroupDialog.open()
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

        // Group Stats Card
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
                        text: AppState.participantCount.toString()
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
                        text: AppState.formattedTotal
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
                        text: AppState.formattedAverage
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

            ExpensesTab {
                onAddExpenseClicked: addExpenseDialog.open()

                onEditExpenseClicked: function (id, title, amount, paidById, splitType, excludedIds) {
                    editExpenseDialog.expenseId = id
                    editExpenseDialog.expenseTitle = title
                    editExpenseDialog.expenseAmount = amount
                    editExpenseDialog.paidById = paidById
                    editExpenseDialog.splitType = splitType
                    editExpenseDialog.excludedIds = excludedIds
                    editExpenseDialog.open()
                }

                onDeleteExpenseClicked: function (id, title) {
                    if (settingsManager.confirmDeleteExpenses) {
                        deleteExpenseDialog.expenseId = id
                        deleteExpenseDialog.expenseTitle = title
                        deleteExpenseDialog.open()
                    } else {
                        groupManager.deleteExpense(id)
                    }
                }
            }

            ParticipantsTab {
                onAddParticipantClicked: addParticipantDialog.open()

                onDeleteParticipantClicked: function (id, name) {
                    deleteParticipantDialog.participantId = id
                    deleteParticipantDialog.participantName = name
                    deleteParticipantDialog.open()
                }
            }

            SettlementsTab {}
        }
    }

    ToastPopup {
        id: shareToast
    }

    EditGroupDialog {
        id: editGroupDialog
        groupId: root.groupId

        onGroupEdited: function (id, name, participants, currency) {
            groupManager.editGroup(id, name, participants, currency)
        }
    }

    ExpenseDialog {
        id: addExpenseDialog
        isEditMode: false
        participantModel: AppState.participantModel

        onExpenseAccepted: function (expenseId, title, amount, paidBy, splitType, excluded) {
            groupManager.addExpense(title, amount, paidBy, splitType, excluded)
        }
    }

    ExpenseDialog {
        id: editExpenseDialog
        isEditMode: true
        participantModel: AppState.participantModel

        onExpenseAccepted: function (expenseId, title, amount, paidBy, splitType, excluded) {
            groupManager.editExpense(expenseId, title, amount, paidBy,
                                     splitType, excluded)
        }
    }

    GenericInputDialog {
        id: addParticipantDialog
        dialogTitle: "Add New Participant"
        placeholderText: "Name"
        confirmButtonText: "Add Participant"

        onInputAccepted: function (text) {
            groupManager.addParticipant(text)
        }
    }

    ConfirmationDialog {
        id: deleteGroupDialog
        property string groupId: ""
        property string groupName: ""

        title: "Delete Group"
        message: "Are you sure you want to delete \"" + groupName + "\"?"
        warningText: "This action cannot be undone."
        confirmText: "Delete"
        confirmColor: Material.color(Material.Red)
        onConfirmed: {
            root.StackView.view.pop()
            groupManager.deleteGroup(groupId)
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
        onConfirmed: groupManager.deleteExpense(expenseId)
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
        onConfirmed: groupManager.deleteParticipant(participantId)
    }
}
