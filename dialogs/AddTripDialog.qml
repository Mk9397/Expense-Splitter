import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Create New Group"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    signal tripCreated(string tripName)

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: tripNameField
            Layout.fillWidth: true
            placeholderText: "Group name"
            font.pixelSize: 15
        }

        Button {
            text: "Create Group"
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            font.weight: Font.DemiBold
            highlighted: true
            onClicked: {
                if (tripNameField.text.trim() !== "") {
                    root.tripCreated(tripNameField.text)
                    tripNameField.clear()
                    root.close()
                }
            }
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }
}
