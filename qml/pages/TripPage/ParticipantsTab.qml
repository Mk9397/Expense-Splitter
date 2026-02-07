import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import components
import theme

ColumnLayout {
    id: root
    spacing: 0

    // Properties
    property var participantModel
    property string currencySymbol
    property var participantBalances

    // Signals
    signal addParticipantClicked
    signal deleteParticipantClicked(string id, string name)

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 16
        Layout.topMargin: 12
        Layout.bottomMargin: 8
        spacing: 12

        Label {
            text: "Participants"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            Layout.fillWidth: true
            opacity: 0.87
        }

        Rectangle {
            width: 84
            height: 22
            radius: 11
            color: ThemeManager.isDark ? Qt.rgba(1, 1, 1, 0.1) : Material.color(
                                             Material.Grey, Material.Shade200)

            Label {
                anchors.centerIn: parent
                text: participantList.count + " participants"
                opacity: 0.7
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    ListView {
        id: participantList
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        spacing: 10
        clip: true

        model: root.participantModel

        delegate: ParticipantCard {
            required property string id
            required property string name

            width: ListView.view.width
            participantName: name
            currencySymbol: root.currencySymbol

            property var balanceData: root.participantBalances[id] ?? {}

            totalPaid: balanceData.total_paid ?? 0
            shouldPay: balanceData.should_pay ?? 0
            balance: balanceData.balance ?? 0

            onDeleteParticipant: {
                root.deleteParticipantClicked(id, name)
            }
        }
    }

    Button {
        text: "Add Participant"
        Layout.fillWidth: true
        Layout.margins: 16
        Layout.topMargin: 8
        Layout.preferredHeight: 48
        font.pixelSize: 14
        font.weight: Font.DemiBold
        Material.elevation: 3
        highlighted: true

        onClicked: root.addParticipantClicked()

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
