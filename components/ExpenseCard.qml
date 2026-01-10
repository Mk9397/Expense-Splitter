import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ItemDelegate {
    id: control
    implicitHeight: 90

    property string expenseTitle: ""
    property string expenseAmount: ""
    property string expenseIcon: ""
    property string paidBy: ""
    property int memberCount: 1

    background: Rectangle {
        radius: 16
        color: {
            if (control.pressed)
                return Material.color(
                            Material.Blue,
                            Material.theme === Material.Dark ? Material.Shade800 : Material.Shade50)
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
        anchors.margins: 18
        spacing: 16

        Rectangle {
            width: 48
            height: 48
            radius: 24
            color: Material.theme === Material.Dark ? Qt.rgba(
                                                          255 / 255, 255 / 255,
                                                          255 / 255,
                                                          0.1) : Material.color(
                                                          Material.Grey,
                                                          Material.Shade100)
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: control.expenseIcon
                font.pixelSize: 26
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            Label {
                text: control.expenseTitle
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
            Label {
                text: "Paid by " + control.paidBy
                opacity: 0.55
                font.pixelSize: 13
            }
            Label {
                text: "₦" + (parseFloat(control.expenseAmount.replace(
                                            /[₦,]/g,
                                            "")) / control.memberCount).toFixed(
                          2) + " per person"
                opacity: 0.7
                font.pixelSize: 12
                color: Material.accent
                font.weight: Font.Medium
            }
        }

        Label {
            text: control.expenseAmount
            font.weight: Font.Bold
            font.pixelSize: 19
            color: Material.accent
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Component.onCompleted: {
        var hoverHandler = Qt.createQmlObject(
                    'import QtQuick; HoverHandler { cursorShape: Qt.PointingHandCursor }',
                    control)
    }
}
