import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
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
    property var members: []
    property string tripCurrency: ""

    signal tripEdited(string tripId, string tripName, var members, string tripCurrency)

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
            text: "Manage Members (%1)".arg(memberModel.count)
            Layout.fillWidth: true
            flat: true
            icon.source: "qrc:/icons/group.svg"
            font.weight: Font.Medium
            onClicked: membersPopup.open()
            Component.onCompleted: pointerCursor.createObject(this)

            // background: Rectangle {
            //     radius: 10
            //     color: parent.pressed ? Material.color(
            //                                 Material.Grey,
            //                                 Material.Shade300) : parent.hovered ? Material.color(Material.Grey, Material.Shade200) : Material.color(Material.Grey, Material.Shade100)
            //     border.color: Material.color(Material.Grey, Material.Shade300)
            //     border.width: 1

            //     Behavior on color {
            //         ColorAnimation {
            //             duration: 150
            //         }
            //     }
            // }
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
                    let newMembers = []
                    for (var i = 0; i < memberModel.count; ++i) {
                        newMembers.push({
                                            "id": memberModel.get(i).id,
                                            "name": memberModel.get(i).name
                                        })
                    }

                    root.tripEdited(
                                root.tripId, editTripNameField.text,
                                newMembers,
                                editCurrencyCombo.model[editCurrencyCombo.currentIndex].code)
                    root.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }

    ListModel {
        id: memberModel
    }

    Popup {
        id: membersPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent.width * 0.88
        height: Math.min(parent.height * 0.7, 500)
        modal: true

        background: Rectangle {
            // color: ApplicationWindow.window ? ApplicationWindow.window.background : Material.Blue
            color: Material.background
            radius: 16

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.08)
                shadowBlur: 0.3
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Label {
                    text: "Members"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Label {
                    text: memberModel.count
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Material.color(Material.Grey)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                // color: Material.color(Material.Grey, Material.Shade200)
            }

            ListView {
                id: memberList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: memberModel
                clip: true
                spacing: 10
                boundsMovement: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
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

                delegate: SwipeDelegate {
                    id: swipeDelegate
                    width: memberList.width
                    height: 64

                    swipe.right: Rectangle {
                        width: 80
                        height: parent.height
                        anchors.right: parent.right
                        color: Material.color(Material.Red)
                        radius: 10

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Image {
                                source: "qrc:/icons/delete.svg"
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                            Label {
                                text: "Delete"
                                color: "white"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    swipe.onCompleted: {
                        // if (swipe.position > 0.45)
                        memberModel.remove(index)
                    }

                    background: Rectangle {
                        radius: 12
                        color: swipeDelegate.pressed ? Qt.darker(
                                                           ApplicationWindow.window.cardBackground,
                                                           1.05) : ApplicationWindow.window.cardBackground
                        border.color: swipeDelegate.swipe.position
                                      > 0 ? Material.color(
                                                Material.Red,
                                                Material.Shade200) : "transparent"
                        border.width: swipeDelegate.swipe.position > 0 ? 1 : 0

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: RowLayout {
                        width: parent.width
                        height: parent.height
                        spacing: 12

                        Item {
                            width: 14
                        }

                        Label {
                            text: name
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ToolButton {
                            icon.source: "qrc:/icons/delete.svg"
                            icon.color: Material.color(Material.Red)
                            icon.width: 20
                            icon.height: 20
                            onClicked: memberModel.remove(index)
                            Component.onCompleted: pointerCursor.createObject(
                                                       this)
                        }

                        Item {
                            width: 14
                        }
                    }
                }
            }

            Button {
                text: "Add Member"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                flat: true
                icon.source: "qrc:/icons/add.svg"
                font.weight: Font.Medium
                onClicked: {
                    membersPopup.close()
                    memberDialog.open()
                }
                Component.onCompleted: pointerCursor.createObject(this)

                background: Rectangle {
                    radius: 12
                    color: parent.pressed ? Material.color(
                                                Material.Grey,
                                                Material.Shade300) : parent.hovered ? Material.color(Material.Grey, Material.Shade200) : "transparent"
                    border.color: Material.color(Material.Grey,
                                                 Material.Shade400)
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }

            Button {
                text: "Done"
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 15
                onClicked: membersPopup.close()
                Component.onCompleted: pointerCursor.createObject(this)

                background: Rectangle {
                    radius: 12
                    color: parent.pressed ? Qt.darker(
                                                Material.accentColor,
                                                1.1) : parent.hovered ? Qt.lighter(
                                                                            Material.accentColor,
                                                                            1.05) : Material.accentColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }
    }

    onOpened: {
        memberModel.clear()
        for (let m of root.members)
            memberModel.append(m)
    }

    AddMemberDialog {
        id: memberDialog
        onMemberCreated: function (memberName) {
            memberModel.append({
                                   "id": tripManager.generateId(),
                                   "name": memberName.trim()
                               })
        }
    }
}
