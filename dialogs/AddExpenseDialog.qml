import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../popups"

Dialog {
    id: root
    title: "Add Expense"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    property var excludedIds: []
    property var participantModel

    signal expenseCreated(string expenseTitle, int expenseAmount, string paidById, string splitType, var excludedIds)

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    ColumnLayout {
        width: parent.width
        spacing: 12

        TextField {
            id: titleField
            Layout.fillWidth: true
            implicitHeight: 50
            placeholderText: "Expense title"
            font.pixelSize: 15
        }

        TextField {
            id: amountField
            Layout.fillWidth: true
            implicitHeight: 50
            placeholderText: "Amount (₦)"
            inputMethodHints: Qt.ImhDigitsOnly
            font.pixelSize: 15
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

                model: participantModel
                textRole: "name"
                valueRole: "id"
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
            }
        }

        Button {
            id: excludeBtn
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
                color: ApplicationWindow.window.cardBackground
                radius: 12
                border.color: ApplicationWindow.window.cardBorder
                border.width: 1
            }
            Component.onCompleted: pointerCursor.createObject(this)
        }

        Button {
            text: "Add Expense"
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            font.weight: Font.DemiBold
            highlighted: true
            onClicked: {
                if (titleField.text.trim() !== "" && amountField.text.trim(
                            ) !== "") {
                    root.expenseCreated(titleField.text,
                                        parseFloat(amountField.text) || 0.00,
                                        paidByField.currentValue,
                                        splitTypeField.currentValue,
                                        root.excludedIds)
                    titleField.clear()
                    amountField.clear()
                    root.close()
                }
            }
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }

    ParticipantMultiSelectPopup {
        id: excludePopup
        width: root.width * 0.85
        height: participantModel ? Math.min(participantModel.rowCount(
                                                ) * 50 + 40, 300) : 200

        participantModel: root.participantModel
        onAccepted: function (ids) {
            root.excludedIds = ids
        }
    }
}
