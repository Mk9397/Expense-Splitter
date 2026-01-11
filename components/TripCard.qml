import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ItemDelegate {
    id: control
    implicitHeight: 88

    property string tripId: ""
    property string tripName: ""
    property int memberCount: 0

    signal editTrip
    signal deleteTrip
    signal shareTrip

    background: Rectangle {
        radius: 16
        color: {
            if (control.pressed)
                return Material.color(
                            Material.Blue, Material.theme
                            === Material.Dark ? Material.Shade800 : Material.Shade100)
            if (control.hovered)
                return Material.theme === Material.Dark ? Qt.rgba(
                                                              255 / 255,
                                                              255 / 255,
                                                              255 / 255,
                                                              0.08) : Material.color(
                                                              Material.Grey,
                                                              Material.Shade50)
            var window = ApplicationWindow.window
            return window ? window.cardBackground : (Material.theme
                                                     === Material.Dark ? Qt.rgba(
                                                                             255 / 255,
                                                                             255 / 255,
                                                                             255 / 255,
                                                                             0.05) : "#FFFFFF")
        }
        border.color: {
            if (control.hovered)
                return Material.accent
            var window = ApplicationWindow.window
            return window ? window.cardBorder : Material.color(
                                Material.Grey, Material.Shade200)
        }
        border.width: control.hovered ? 2 : 1

        layer.enabled: !control.pressed
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.08)
            shadowBlur: 0.3
            shadowVerticalOffset: 1
            shadowHorizontalOffset: 0
        }
    }

    contentItem: RowLayout {
        anchors.margins: 16
        spacing: 16

        Rectangle {
            width: 52
            height: 52
            radius: 26
            color: Material.theme === Material.Dark ? Qt.rgba(
                                                          33 / 255, 150 / 255,
                                                          243 / 255,
                                                          0.2) : Material.color(
                                                          Material.Blue,
                                                          Material.Shade100)
            border.color: Material.color(
                              Material.Blue, Material.theme
                              === Material.Dark ? Material.Shade600 : Material.Shade300)
            border.width: 1.5
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: control.tripName.substring(0, 1).toUpperCase()
                font.pixelSize: 24
                font.weight: Font.Bold
                color: Material.accent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Label {
                text: control.tripName
                font.pixelSize: 17
                font.weight: Font.DemiBold
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Label {
                text: control.memberCount + " member" + (control.memberCount !== 1 ? "s" : "")
                opacity: 0.6
                font.pixelSize: 14
            }
        }

        ToolButton {
            id: moreButton
            icon.source: "qrc:/icons/more_vert.svg"
            icon.width: 20
            icon.height: 20
            Layout.alignment: Qt.AlignVCenter

            onClicked: moreMenu.popup()
            Component.onCompleted: pointerCursor.createObject(this)

            Menu {
                id: moreMenu

                MenuItem {
                    text: "Edit"
                    icon.source: "qrc:/icons/edit.svg"
                    onTriggered: control.editTrip()
                }

                MenuItem {
                    text: "Share"
                    icon.source: "qrc:/icons/share.svg"
                    onTriggered: control.shareTrip()
                }

                MenuSeparator {}

                MenuItem {
                    text: "Delete"
                    icon.source: "qrc:/icons/delete.svg"
                    icon.color: Material.color(Material.Red)
                    onTriggered: control.deleteTrip()
                }
            }

            // Prevent click from bubbling to the card
            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: function (event) {
                    event.accepted = true
                    moreButton.clicked()
                }
                cursorShape: "PointingHandCursor"
            }
        }

        Image {
            Layout.alignment: Qt.AlignVCenter
            source: "qrc:/icons/chevron_right.svg"
            sourceSize.width: 25
            sourceSize.height: 25
            opacity: 0.3
        }
    }

    Component.onCompleted: pointerCursor.createObject(this)
}
