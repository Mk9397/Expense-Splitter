import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

RowLayout {
    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        height: 48
        radius: 24
        color: ApplicationWindow.window.cardBackground
        border.color: searchField.activeFocus ? Material.accent : ApplicationWindow.window.cardBorder
        border.width: searchField.activeFocus ? 2 : 1

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
        Behavior on border.width {
            NumberAnimation {
                duration: 200
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Image {
                source: "qrc:/icons/search.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                opacity: searchField.activeFocus ? 0.87 : 0.54
                Layout.alignment: Qt.AlignVCenter

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            Timer {
                id: searchDebounce
                interval: 300
                onTriggered: tripManager.setFilter(searchField.text)
            }

            TextField {
                id: searchField
                placeholderText: searchField.activeFocus
                                 || searchField.text.length > 0 ? "" : "Search groups..."
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                verticalAlignment: TextInput.AlignVCenter

                background: Item {}

                color: Material.foreground
                placeholderTextColor: Material.hintTextColor

                onTextChanged: searchDebounce.restart()
            }

            ToolButton {
                visible: searchField.text.length > 0
                opacity: visible ? 1 : 0
                icon.source: "qrc:/icons/close.svg"
                icon.width: 18
                icon.height: 18
                implicitWidth: 32
                implicitHeight: 32
                Layout.alignment: Qt.AlignVCenter

                onClicked: searchField.clear()
                Component.onCompleted: pointerCursor.createObject(this)

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
