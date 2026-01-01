import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Create New Trip"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: tripNameField
            Layout.fillWidth: true
            placeholderText: "Trip name"
            font.pixelSize: 15
        }

        TextField {
            id: membersField
            Layout.fillWidth: true
            placeholderText: "Number of members"
            inputMethodHints: Qt.ImhDigitsOnly
            font.pixelSize: 15
        }

        Button {
            text: "Create Trip"
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            font.weight: Font.DemiBold
            highlighted: true
            onClicked: {
                console.log("TODO: Add trip logic")
                root.close()
            }
            Component.onCompleted: {
                var hoverHandler = Qt.createQmlObject(
                            'import QtQuick; HoverHandler { cursorShape: Qt.PointingHandCursor }',
                            this)
            }
        }
    }
}
