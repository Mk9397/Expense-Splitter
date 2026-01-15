import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../popups"

Dialog {
    id: root
    title: "Edit Expense"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    property string expenseId: ""
    property string expenseTitle: ""
    property real expenseAmount: 0
    property string paidById: ""
    property string splitType: "equal"
    property var excludedIds: []

    property var memberModel

    signal expenseEdited(string expenseId, string expenseTitle, real expenseAmount, string paidById, string splitType, var excludedIds)

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
                implicitHeight: 50

                model: memberModel
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
                implicitHeight: 50
                model: ["equal", "personal"]
            }
        }

        Button {
            id: excludeBtn
            text: "Manage excluded members"
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

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                flat: true
                onClicked: root.close()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Button {
                text: "Save"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                highlighted: true
                onClicked: {
                    if (titleField.text.trim() !== "" && amountField.text.trim(
                                ) !== "") {
                        root.expenseEdited(expenseId, titleField.text,
                                           parseFloat(amountField.text)
                                           || 0.00, paidByField.currentValue,
                                           splitTypeField.currentValue,
                                           root.excludedIds)
                        root.close()
                    }
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }

    MemberMultiSelectPopup {
        id: excludePopup
        width: root.width * 0.85
        height: memberModel ? Math.min(memberModel.rowCount() * 50 + 40,
                                       300) : 200

        memberModel: root.memberModel
        onAccepted: function (ids) {
            root.excludedIds = ids
        }
    }

    onOpened: {
        titleField.text = expenseTitle
        amountField.text = expenseAmount
        paidByField.currentIndex = memberModel.indexOfId(paidById)
        splitTypeField.currentIndex = splitTypeField.model.indexOf(splitType)
        excludedIds = excludedIds.slice()
    }
}
