import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import dialogs
import theme

Popup {
    id: control
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: parent.width * 0.8
    height: Math.min(parent.height * 0.7, 500)
    modal: true

    property var participantModel

    background: Rectangle {
        color: Material.dialogColor
        radius: 16
    }

    Overlay.modal: Rectangle {
        color: Material.dropShadowColor
    }

    onOpened: participantList.forceActiveFocus()

    contentItem: Item {
        implicitWidth: popupLayout.implicitWidth
        implicitHeight: popupLayout.implicitHeight

        Keys.onEscapePressed: control.close()

        ColumnLayout {
            id: popupLayout
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
                    text: control.participantModel?.count ?? 0
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Material.color(Material.Grey)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Material.foreground
                opacity: 0.3
            }

            ListView {
                id: participantList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                focus: true
                boundsMovement: Flickable.StopAtBounds

                model: control.participantModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    hoverEnabled: true
                    width: 10

                    contentItem: Rectangle {
                        radius: 5
                        color: Material.scrollBarColor
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "height"
                        to: 0
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                delegate: ItemDelegate {
                    width: participantList.width

                    background: Rectangle {
                        radius: 12
                        color: ThemeManager.cardBackground
                        border.color: ThemeManager.cardBorder
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
                            onClicked: control.participantModel.remove(index)

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 4

                Button {
                    id: addParticipantButton
                    text: "Add Participant"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    flat: true
                    highlighted: true
                    icon.source: "qrc:/icons/add.svg"
                    font.weight: Font.Medium

                    onClicked: participantDialog.open()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: doneButton
                    KeyNavigation.backtab: doneButton
                }

                Button {
                    id: doneButton
                    text: "Done"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    highlighted: true
                    font.weight: Font.Medium
                    font.pixelSize: 12

                    onClicked: control.close()

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    KeyNavigation.tab: addParticipantButton
                    KeyNavigation.backtab: addParticipantButton
                }
            }
        }
    }

    GenericInputDialog {
        id: participantDialog
        dialogTitle: "Add New Participant"
        placeholderText: "Name"
        confirmButtonText: "Add Participant"

        onInputAccepted: function (text) {
            control.participantModel.append({
                                                "id": groupManager.generateId(),
                                                "name": text.trim()
                                            })
        }
    }
}
