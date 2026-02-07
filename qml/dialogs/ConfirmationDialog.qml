import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root

    property string message: ""
    property string warningText: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property color confirmColor: Material.color(Material.Red)
    property bool showWarning: warningText !== ""

    signal confirmed

    function confirm() {
        root.confirmed()
        root.close()
    }

    function cancel() {
        root.close()
    }

    anchors.centerIn: parent
    width: Math.min(parent.width - 48, 400)
    modal: true

    Material.elevation: 2
    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    onOpened: confirmButton.forceActiveFocus()

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight

        Keys.onEscapePressed: root.cancel()
        Keys.onReturnPressed: root.confirm()

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 16

            Label {
                text: root.message
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: root.warningText
                opacity: 0.6
                font.pixelSize: 13
                Layout.fillWidth: true
                // color: root.confirmColor
                visible: root.showWarning
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: root.cancelText
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true
                    onClicked: root.cancel()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Button {
                    id: confirmButton
                    text: root.confirmText
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    Material.background: root.confirmColor
                    Material.foreground: "white"

                    font.weight: Font.DemiBold
                    Material.elevation: 2

                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
