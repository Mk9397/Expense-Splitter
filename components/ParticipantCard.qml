import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ItemDelegate {
    id: control
    implicitHeight: 88

    property string participantName: "Participant" + (index + 1)
    property string currencySymbol: "₦"
    property real totalPaid: 0
    property real shouldPay: 0
    property real balance: 0

    signal deleteParticipant

    function formatAmount(amount) {
        return Number(amount).toLocaleString(Qt.locale(), 'f', 2)
    }

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

        // Left section - Participant info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: participantName
                font.pixelSize: 17
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 16

                ColumnLayout {
                    spacing: 0
                    Label {
                        text: "Total paid:"
                        font.pixelSize: 10
                        opacity: 0.6
                    }
                    Label {
                        text: currencySymbol + formatAmount(totalPaid)
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                }

                // Separator
                Rectangle {
                    width: 1
                    height: 16
                    color: Material.theme === Material.Dark ? Qt.rgba(
                                                                  255 / 255,
                                                                  255 / 255,
                                                                  255 / 255,
                                                                  0.1) : Qt.rgba(
                                                                  0, 0, 0, 0.1)
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    spacing: 0
                    Label {
                        text: "Share:"
                        font.pixelSize: 10
                        opacity: 0.6
                    }
                    Label {
                        text: currencySymbol + formatAmount(shouldPay)
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // Right side - Balance badge
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 16

            Rectangle {
                width: 1
                height: 30
                color: Material.theme === Material.Dark ? Qt.rgba(
                                                              255 / 255,
                                                              255 / 255,
                                                              255 / 255,
                                                              0.1) : Qt.rgba(
                                                              0, 0, 0, 0.1)
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Label {
                    text: {
                        if (balance > 0.01)
                            return "Owed"
                        else if (balance < -0.01)
                            return "Owes"
                        else
                            return "Settled"
                    }
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.capitalization: Font.AllUppercase
                    opacity: 0.8
                    Layout.alignment: Qt.AlignRight
                    color: {
                        if (balance > 0.01)
                            return Material.color(Material.Green,
                                                  Material.Shade700)
                        else if (balance < -0.01)
                            return Material.color(Material.Red,
                                                  Material.Shade700)
                        else
                            return Material.color(Material.Grey,
                                                  Material.Shade600)
                    }
                }

                Label {
                    text: balance === 0 ? "✓" : currencySymbol + formatAmount(
                                              Math.abs(balance))
                    font.pixelSize: balance === 0 ? 18 : 16
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignRight
                    color: {
                        if (balance > 0.01)
                            return Material.color(Material.Green,
                                                  Material.Shade700)
                        else if (balance < -0.01)
                            return Material.color(Material.Red,
                                                  Material.Shade700)
                        else
                            return Material.color(Material.Grey,
                                                  Material.Shade600)
                    }
                }
            }
        }

        ToolButton {
            icon.source: "qrc:/icons/delete.svg"
            icon.color: Material.color(Material.Red)
            icon.width: 20
            icon.height: 20
            Layout.alignment: Qt.AlignVCenter
            onClicked: control.deleteParticipant()
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }
}
