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

    function confirm() {
        if (editTripNameField.text.trim() === "") {
            return
        }

        let newParticipants = []
        for (var i = 0; i < participantModel.count; ++i) {
            newParticipants.push({
                                     "id": participantModel.get(i).id,
                                     "name": participantModel.get(i).name
                                 })
        }

        root.tripEdited(
                    root.tripId, editTripNameField.text.trim(),
                    newParticipants,
                    editCurrencyCombo.model[editCurrencyCombo.currentIndex].code)

        root.close()
    }

    function cancel() {
        root.close()
    }

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    onOpened: {
        participantModel.clear()
        for (let p of root.participants) {
            participantModel.append(p)
        }

        editTripNameField.forceActiveFocus()
    }

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight

        Keys.onEscapePressed: root.cancel()
        Keys.onReturnPressed: {
            if (saveButton.activeFocus || editTripNameField.activeFocus
                    || editCurrencyCombo.activeFocus) {
                root.confirm()
            }
        }

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 16

            TextField {
                id: editTripNameField
                Layout.fillWidth: true
                placeholderText: "Group name"
                text: root.tripName
                font.pixelSize: 15

                KeyNavigation.tab: editCurrencyCombo
                KeyNavigation.backtab: saveButton
            }

            CurrencyComboBox {
                id: editCurrencyCombo
                Layout.fillWidth: true
                currentCode: root.tripCurrency

                KeyNavigation.tab: manageParticipantsButton
                KeyNavigation.backtab: editTripNameField
            }

            Button {
                id: manageParticipantsButton
                text: "Manage Participants (%1)".arg(participantModel.count)
                Layout.fillWidth: true
                flat: true
                icon.source: "qrc:/icons/group.svg"
                font.weight: Font.Medium

                onClicked: participantsPopup.open()

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                KeyNavigation.tab: cancelButton
                KeyNavigation.backtab: editCurrencyCombo
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: cancelButton
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true

                    onClicked: root.cancel()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: saveButton
                    KeyNavigation.backtab: manageParticipantsButton
                }

                Button {
                    id: saveButton
                    text: "Save"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    highlighted: true
                    enabled: editTripNameField.text.trim().length > 0

                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: editTripNameField
                    KeyNavigation.backtab: cancelButton
                }
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
