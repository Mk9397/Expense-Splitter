import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Delete Expense"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    property string expenseId: ""
    property string expenseTitle: ""

    signal expenseDeleted(string expenseId)

    ColumnLayout {
        width: parent.width
        spacing: 16

        Label {
            text: "Are you sure you want to delete \"" + root.expenseTitle + "\" from this trip?"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: "This action cannot be undone."
            opacity: 0.6
            font.pixelSize: 13
            Layout.fillWidth: true
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
                text: "Delete"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Material.background: Material.Red
                Material.foreground: "white"
                onClicked: {
                    root.expenseDeleted(root.expenseId)
                    root.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }
}
