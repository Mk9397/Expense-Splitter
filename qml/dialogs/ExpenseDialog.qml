import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import popups
import singletons
import theme

Dialog {
    id: root
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    // Mode property
    property bool isEditMode: false

    // Edit mode properties
    property string expenseId: ""
    property string expenseTitle: ""
    property real expenseAmount: 0
    property string paidById: ""
    property string splitType: "equal"

    // Common properties
    property var excludedIds: []
    property var participantModel

    signal expenseAccepted(string expenseId, string expenseTitle, real expenseAmount, string paidById, string splitType, var excludedIds)

    title: isEditMode ? "Edit Expense" : "Add Expense"

    function confirm() {
        if (titleField.text.trim() === "" || amountField.text.trim() === "") {
            return
        }

        root.expenseAccepted(expenseId, titleField.text.trim(),
                             parseFloat(amountField.text) || 0.00,
                             paidByField.currentValue,
                             splitTypeField.currentValue, root.excludedIds)

        resetFields()
        root.close()
    }

    function cancel() {
        resetFields()
        root.close()
    }

    function resetFields() {
        if (!isEditMode) {
            titleField.clear()
            amountField.clear()
            paidByField.currentIndex = 0
            splitTypeField.currentIndex = 0
            root.excludedIds = []
        }
    }

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    onOpened: {
        if (isEditMode) {
            titleField.text = expenseTitle
            amountField.text = expenseAmount.toString()
            paidByField.currentIndex = AppState.participantProxyModel.indexOfId(
                        paidById)
            splitTypeField.currentIndex = splitTypeField.model.indexOf(
                        splitType)
            root.excludedIds = excludedIds.slice()
        }

        titleField.forceActiveFocus()
    }

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight

        Keys.onEscapePressed: root.cancel()
        Keys.onReturnPressed: {
            if (confirmButton.activeFocus || titleField.activeFocus
                    || amountField.activeFocus || paidByField.activeFocus
                    || splitTypeField.activeFocus) {
                root.confirm()
            }
        }

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 12

            TextField {
                id: titleField
                Layout.fillWidth: true
                implicitHeight: 50
                placeholderText: "Expense title"
                font.pixelSize: 15

                KeyNavigation.tab: amountField
                KeyNavigation.backtab: confirmButton
            }

            TextField {
                id: amountField
                Layout.fillWidth: true
                implicitHeight: 50
                placeholderText: "Amount (₦)"
                font.pixelSize: 15

                inputMethodHints: Qt.ImhDigitsOnly
                validator: DoubleValidator {
                    bottom: 0.00
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                KeyNavigation.tab: paidByField
                KeyNavigation.backtab: titleField
            }

            ColumnLayout {
                spacing: 4
                Label {
                    text: "Paid by"
                    font.pixelSize: 12
                    font.weight: paidByField.activeFocus ? Font.Medium : Font.Normal
                    color: paidByField.activeFocus ? Material.accent : Material.foreground
                    opacity: paidByField.activeFocus ? 1 : 0.47
                    leftPadding: 10
                }
                ComboBox {
                    id: paidByField
                    implicitHeight: 45

                    model: AppState.participantProxyModel
                    textRole: "name"
                    valueRole: "id"

                    KeyNavigation.tab: splitTypeField
                    KeyNavigation.backtab: amountField
                }
            }

            ColumnLayout {
                spacing: 4
                Label {
                    text: "Split type"
                    font.pixelSize: 12
                    font.weight: splitTypeField.activeFocus ? Font.Medium : Font.Normal
                    color: splitTypeField.activeFocus ? Material.accent : Material.foreground
                    opacity: splitTypeField.activeFocus ? 1 : 0.47
                    leftPadding: 10
                }
                ComboBox {
                    id: splitTypeField
                    implicitHeight: 45
                    model: ["equal", "personal"]

                    KeyNavigation.tab: excludeBtn.visible ? excludeBtn : cancelButton
                    KeyNavigation.backtab: paidByField
                }
            }

            Button {
                id: excludeBtn
                visible: splitTypeField.currentValue !== "personal"
                text: "Manage excluded participants"
                      + (excludedIds.length > 0 ? " (" + excludedIds.length + ")" : "")
                flat: true
                icon.source: "qrc:/icons/block.svg"
                icon.color: Material.color(Material.Red)

                onClicked: {
                    excludePopup.selectedIds = root.excludedIds.slice()
                    excludePopup.open()
                }

                background: Rectangle {
                    color: ThemeManager.cardBackground
                    radius: 12
                    border.color: ThemeManager.cardBorder
                    border.width: 1
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                KeyNavigation.tab: cancelButton
                KeyNavigation.backtab: splitTypeField
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: cancelButton
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true

                    onClicked: root.cancel()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: confirmButton
                    KeyNavigation.backtab: excludeBtn.visible ? excludeBtn : splitTypeField
                }

                Button {
                    id: confirmButton
                    text: isEditMode ? "Save" : "Add Expense"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    highlighted: true
                    enabled: titleField.text.trim().length > 0
                             && amountField.text.trim().length > 0

                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: titleField
                    KeyNavigation.backtab: cancelButton
                }
            }
        }
    }

    ParticipantMultiSelectPopup {
        id: excludePopup
        width: root.width * 0.85
        height: participantModel ? Math.min(Math.max(participantModel.rowCount(
                                                         ) * 50 + 40, 250),
                                            300) : 200
        participantModel: root.participantModel

        onAccepted: function (ids) {
            root.excludedIds = ids
        }
    }
}
