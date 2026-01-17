import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

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

    Popup {
        id: participantsPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: Math.min(parent.height * 0.7, 500)
        modal: true

        background: Rectangle {
            color: Material.dialogColor
            radius: 16
        }

        Overlay.modal: Rectangle {
            color: Material.dropShadowColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Label {
                    text: "Participants"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }
                Label {
                    text: participantModel.count
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Material.color(Material.Grey)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Material.foreground
            }

            ListView {
                id: participantList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: participantModel
                clip: true
                spacing: 8
                focus: true
                boundsMovement: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 10
                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 0.8
                        to: 1
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                }
                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 150
                    }
                    NumberAnimation {
                        property: "scale"
                        to: 0.8
                        duration: 150
                    }
                }
                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: ItemDelegate {
                    width: participantList.width

                    background: Rectangle {
                        radius: 12
                        color: ApplicationWindow.window.cardBackground
                        border.color: ApplicationWindow.window.cardBorder
                        border.width: 1

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: RowLayout {
                        spacing: 12

                        Label {
                            text: name
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ToolButton {
                            icon.source: "qrc:/icons/delete.svg"
                            icon.color: Material.color(Material.Red)
                            icon.width: 24
                            icon.height: 24
                            onClicked: participantModel.remove(index)
                            Component.onCompleted: pointerCursor.createObject(
                                                       this)
                        }
                    }
                }
            }

            RowLayout {
                spacing: 4

                Button {
                    text: "Add Participant"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true
                    highlighted: true
                    icon.source: "qrc:/icons/add.svg"
                    font.weight: Font.Medium
                    onClicked: {
                        participantsPopup.close()
                        participantDialog.open()
                    }
                    Component.onCompleted: pointerCursor.createObject(this)
                }
                Button {
                    text: "Done"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    highlighted: true
                    font.weight: Font.Medium
                    font.pixelSize: 12
                    onClicked: participantsPopup.close()
                    Component.onCompleted: pointerCursor.createObject(this)
                }
            }
        }
    }

    onOpened: {
        participantModel.clear()
        for (let p of root.participants)
            participantModel.append(p)
    }

    AddParticipantDialog {
        id: participantDialog
        onParticipantCreated: function (participantName) {
            participantModel.append({
                                        "id": tripManager.generateId(),
                                        "name": participantName.trim()
                                    })
        }
    }
}
