import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Add Expense"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    signal expenseCreated(string expenseTitle, int expenseAmount, string paidBy)

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: titleField
            Layout.fillWidth: true
            placeholderText: "Expense title"
            font.pixelSize: 15
        }

        TextField {
            id: amountField
            Layout.fillWidth: true
            placeholderText: "Amount (₦)"
            inputMethodHints: Qt.ImhDigitsOnly
            font.pixelSize: 15
        }

        TextField {
            id: paidByField
            Layout.fillWidth: true
            placeholderText: "Paid by"
            font.pixelSize: 15
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
                                        parseInt(amountField.text) || 0.00,
                                        paidByField.text)
                    titleField.clear()
                    amountField.clear()
                    paidByField.clear()
                    root.close()
                }
            }
            Component.onCompleted: {
                var hoverHandler = Qt.createQmlObject(
                            'import QtQuick; HoverHandler { cursorShape: Qt.PointingHandCursor }',
                            this)
            }
        }
    }
}
