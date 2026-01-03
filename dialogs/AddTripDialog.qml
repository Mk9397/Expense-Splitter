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

    signal tripCreated(string tripName, int memberCount)

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
                if (tripNameField.text.trim() !== "" && membersField.text.trim(
                            ) !== "") {
                    root.tripCreated(tripNameField.text,
                                     parseInt(membersField.text) || 0)
                    tripNameField.clear()
                    membersField.clear()
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
