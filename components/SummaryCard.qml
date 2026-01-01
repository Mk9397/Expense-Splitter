import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

Rectangle {
    id: root
    height: 100
    radius: 20
    color: ApplicationWindow.window.accentCardBackground
    border.color: ApplicationWindow.window.accentCardBorder
    border.width: 1

    property int tripCount: 0
    property int totalMembers: 0

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.1)
        shadowBlur: 0.4
        shadowVerticalOffset: 2
        shadowHorizontalOffset: 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: "TOTAL TRIPS"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                opacity: 0.65
                color: Material.accent
            }
            Label {
                text: root.tripCount.toString()
                font.pixelSize: 32
                font.weight: Font.Bold
                color: Material.accent
            }
        }

        Rectangle {
            width: 1
            Layout.fillHeight: true
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            color: ApplicationWindow.window.accentCardBorder
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: "TOTAL MEMBERS"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                opacity: 0.65
                color: Material.accent
            }
            Label {
                text: root.totalMembers.toString()
                font.pixelSize: 32
                font.weight: Font.Bold
                color: Material.accent
            }
        }
    }
}
