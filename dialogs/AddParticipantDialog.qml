import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Add New Participant"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.8
    padding: 24

    signal participantCreated(string participantName)

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "Name"
            font.pixelSize: 15
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
                text: "Add Participant"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.weight: Font.DemiBold
                enabled: nameField.text.trim().length > 0
                highlighted: true
                onClicked: {
                    if (nameField.text.trim() !== "") {
                        root.participantCreated(nameField.text)
                        nameField.clear()
                        root.close()
                    }
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }
}
