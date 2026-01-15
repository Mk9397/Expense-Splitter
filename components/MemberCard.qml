import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ItemDelegate {
    id: control
    implicitHeight: 88

    property string memberName: "Member" + (index + 1)

    signal deleteMember

    background: Rectangle {
        radius: 12
        color: {
            if (control.hovered)
                return Material.theme === Material.Dark ? Qt.rgba(
                                                              255 / 255,
                                                              255 / 255,
                                                              255 / 255,
                                                              0.08) : Material.color(
                                                              Material.Grey,
                                                              Material.Shade50)
            return ApplicationWindow.window ? ApplicationWindow.window.cardBackground : Material.Blue
        }
        border.color: ApplicationWindow.window ? ApplicationWindow.window.cardBorder : Material.Blue
        border.width: 1

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
        Layout.fillWidth: true
        anchors.margins: 18
        spacing: 20

        Label {
            text: memberName
            font.pixelSize: 17
            font.weight: Font.DemiBold
            Layout.fillWidth: true
        }

        ToolButton {
            icon.source: "qrc:/icons/delete.svg"
            icon.color: Material.color(Material.Red)
            icon.width: 20
            icon.height: 20
            Layout.alignment: Qt.AlignVCenter
            onClicked: control.deleteMember()
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }
}
