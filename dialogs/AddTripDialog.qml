import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Create New Group"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.8
    padding: 24

    signal tripCreated(string tripName)

    function confirm() {
        if (nameField.text.trim() !== "") {
            root.tripCreated(nameField.text)
            nameField.clear()
            root.close()
        }
    }

    function cancel() {
        nameField.clear()
        root.close()
    }

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    onOpened: nameField.forceActiveFocus()

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight

        Keys.onEscapePressed: root.cancel()
        Keys.onReturnPressed: root.confirm()

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 16

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "Group name"
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
                    onClicked: root.cancel()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Button {
                    text: "Create Group"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    font.weight: Font.DemiBold
                    highlighted: true
                    enabled: nameField.text.trim().length > 0
                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
