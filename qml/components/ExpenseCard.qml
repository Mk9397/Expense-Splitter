import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

import theme

ItemDelegate {
    id: control
    implicitHeight: 82

    property string expenseTitle: ""
    property real expenseAmount: 0
    property string expenseIcon: ""
    property string paidBy: ""
    property string splitType: "equal"
    property var excludedIds: []

    property int participantCount: 1
    property string groupCurrencySymbol: settingsManager ? settingsManager.getCurrencySymbol(
                                                               ) : ""

    function formatAmount(amount) {
        return Number(amount).toLocaleString(Qt.locale(), 'f', 2)
    }

    signal editExpense
    signal deleteExpense

    background: Rectangle {
        radius: 14
        color: {
            if (control.pressed)
                return Material.color(
                            Material.Blue,
                            ThemeManager.isDark ? Material.Shade800 : Material.Shade50)
            if (control.hovered)
                return ThemeManager.isDark ? Qt.rgba(1, 1, 1,
                                                     0.08) : Material.color(
                                                 Material.Grey,
                                                 Material.Shade50)
            return ThemeManager.cardBackground
        }
        border.color: ThemeManager.cardBorder
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
        spacing: 14

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: ThemeManager.isDark ? Qt.rgba(1, 1, 1, 0.1) : Material.color(
                                             Material.Grey, Material.Shade100)
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: control.expenseIcon
                font.pixelSize: 24
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: control.expenseTitle
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Label {
                text: "Paid by " + control.paidBy
                opacity: 0.55
                font.pixelSize: 12
            }
            Label {
                text: {
                    let participantCount = control.participantCount - excludedIds.length
                    if (splitType === "personal") {
                        return "Personal (only " + control.paidBy + ")"
                    } else {
                        return "Equal (" + participantCount + "/"
                                + control.participantCount + " participants)"
                    }
                }
                opacity: 0.7
                font.pixelSize: 10
                color: Material.accent
                font.weight: Font.Medium
            }
        }

        Label {
            text: groupCurrencySymbol + formatAmount(control.expenseAmount)
            font.weight: Font.Bold
            font.pixelSize: 17
            color: Material.accent
            Layout.alignment: Qt.AlignVCenter
        }

        ToolButton {
            icon.source: "qrc:/icons/delete.svg"
            icon.color: Material.color(Material.Red)
            icon.width: 20
            icon.height: 20
            Layout.alignment: Qt.AlignVCenter
            onClicked: control.deleteExpense()

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    onClicked: control.editExpense()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
