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

    property string groupId: ""
    property string groupName: ""
    property var participants: []
    property string groupCurrency: ""

    signal groupEdited(string id, string name, var participants, string currency)

    function confirm() {
        if (editGroupNameField.text.trim() === "") {
            return
        }

        let newParticipants = []
        for (var i = 0; i < participantModel.count; ++i) {
            newParticipants.push({
                                     "id": participantModel.get(i).id,
                                     "name": participantModel.get(i).name
                                 })
        }

        root.groupEdited(
                    root.groupId, editGroupNameField.text.trim(),
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

        editGroupNameField.forceActiveFocus()
    }

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight

        Keys.onEscapePressed: root.cancel()
        Keys.onReturnPressed: {
            if (saveButton.activeFocus || editGroupNameField.activeFocus
                    || editCurrencyCombo.activeFocus) {
                root.confirm()
            }
        }

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 16

            TextField {
                id: editGroupNameField
                Layout.fillWidth: true
                placeholderText: "Group name"
                text: root.groupName
                font.pixelSize: 15

                KeyNavigation.tab: editCurrencyCombo
                KeyNavigation.backtab: saveButton
            }

            CurrencyComboBox {
                id: editCurrencyCombo
                Layout.fillWidth: true
                currentCode: root.groupCurrency

                KeyNavigation.tab: manageParticipantsButton
                KeyNavigation.backtab: editGroupNameField
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
                    enabled: editGroupNameField.text.trim().length > 0

                    onClicked: root.confirm()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: editGroupNameField
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
