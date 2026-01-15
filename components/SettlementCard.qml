import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ItemDelegate {
    id: control
    implicitHeight: 80

    property string debtor: ""
    property string creditor: ""
    property string amount: ""
    property string currencySymbol: "₦"

    background: Rectangle {
        radius: 12
        color: ApplicationWindow.window ? ApplicationWindow.window.cardBackground : Material.Blue
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
        anchors.margins: 16
        spacing: 16

        // From person/debtor/owing
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: "From"
                font.pixelSize: 11
                opacity: 0.6
                font.capitalization: Font.AllUppercase
                font.weight: Font.Medium
            }
            Label {
                text: debtor
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
                color: Material.color(Material.Red)
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.preferredWidth: 96
            Layout.alignment: Qt.AlignVCenter

            Image {
                source: "qrc:/icons/arrow_right_alt.svg"
                sourceSize.width: 24
                sourceSize.height: 24
                opacity: 0.4
                anchors.centerIn: parent
            }
        }

        // To person/creditor/owed
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: "To"
                font.pixelSize: 11
                opacity: 0.6
                font.capitalization: Font.AllUppercase
                font.weight: Font.Medium
            }
            Label {
                text: creditor
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
                color: Material.color(Material.Green)
                Layout.fillWidth: true
            }
        }

        Label {
            text: currencySymbol + amount
            font.weight: Font.Bold
            font.pixelSize: 18
            color: Material.color(Material.Green)
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: implicitWidth
        }
    }
}
