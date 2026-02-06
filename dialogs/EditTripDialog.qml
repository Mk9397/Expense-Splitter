import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import components
import popups
import theme

Dialog {
    id: root
    title: "Edit Group"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    property string tripId: ""
    property string tripName: ""
    property var participants: []
    property string tripCurrency: ""

    signal tripEdited(string tripId, string tripName, var participants, string tripCurrency)

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: editTripNameField
            Layout.fillWidth: true
            placeholderText: "Group name"
            text: root.tripName
            font.pixelSize: 15
        }

        CurrencyComboBox {
            id: editCurrencyCombo
            Layout.fillWidth: true
            currentCode: root.tripCurrency
        }

        Button {
            text: "Manage Participants (%1)".arg(participantModel.count)
            Layout.fillWidth: true
            flat: true
            icon.source: "qrc:/icons/group.svg"
            font.weight: Font.Medium
            onClicked: participantsPopup.open()
            Component.onCompleted: pointerCursor.createObject(this)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                flat: true
                onClicked: root.close()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Button {
                text: "Save"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                highlighted: true
                onClicked: {
                    let newParticipants = []
                    for (var i = 0; i < participantModel.count; ++i) {
                        newParticipants.push({
                                                 "id": participantModel.get(
                                                           i).id,
                                                 "name": participantModel.get(
                                                             i).name
                                             })
                    }

                    root.tripEdited(
                                root.tripId, editTripNameField.text,
                                newParticipants,
                                editCurrencyCombo.model[editCurrencyCombo.currentIndex].code)
                    root.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }

    ListModel {
        id: participantModel
    }

    ParticipantListPopup {
        id: participantsPopup
        participantModel: participantModel
    }
}
