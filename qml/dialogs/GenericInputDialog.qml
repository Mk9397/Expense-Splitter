import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.8
    padding: 24

    property string dialogTitle: "Input"
    property string placeholderText: "Enter value"
    property string confirmButtonText: "Confirm"
    property string cancelButtonText: "Cancel"
    property string inputText: ""

    signal inputAccepted(string text)

    title: dialogTitle

    function confirm() {
        if (nameField.text.trim() !== "") {
            root.inputAccepted(nameField.text)
            resetFields()
            root.close()
        }
    }

    function cancel() {
        resetFields()
        root.close()
    }

    function resetFields() {
        nameField.clear()
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
                placeholderText: root.placeholderText
                font.pixelSize: 15
                text: root.inputText

                KeyNavigation.tab: confirmButton
                KeyNavigation.backtab: cancelButton
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: cancelButton
                    text: root.cancelButtonText
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true

                    onClicked: root.cancel()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: confirmButton
                    KeyNavigation.backtab: confirmButton
                }

                Button {
                    id: confirmButton
                    text: root.confirmButtonText
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    font.weight: Font.DemiBold
                    highlighted: true
                    enabled: nameField.text.trim().length > 0

                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: cancelButton
                    KeyNavigation.backtab: cancelButton
                }
            }
        }
    }
}
