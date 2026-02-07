import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

import theme

// Reusable action item with icon, title, subtitle
ItemDelegate {
    id: root

    property string iconSource: ""
    property color iconBackgroundColor: Qt.alpha(Material.accent, 0.1)
    property string title: ""
    property string subtitle: ""
    property color titleColor: Material.foreground
    property color subtitleColor: Material.foreground
    property int itemHeight: 56

    Layout.fillWidth: true
    implicitHeight: itemHeight

    contentItem: RowLayout {
        spacing: 16

        Rectangle {
            width: 40
            height: 40
            radius: 8
            color: root.iconBackgroundColor

            Image {
                anchors.centerIn: parent
                source: root.iconSource
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: Material.foreground
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: root.title
                font.pixelSize: 14
                font.weight: Font.Medium
                color: root.titleColor
            }

            Label {
                text: root.subtitle
                font.pixelSize: 12
                opacity: 0.6
                color: root.subtitleColor
                visible: subtitle !== ""
            }
        }
    }

    background: Rectangle {
        color: parent.hovered ? Qt.alpha(ThemeManager.cardBackground,
                                         0.1) : "transparent"
        radius: 12

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
