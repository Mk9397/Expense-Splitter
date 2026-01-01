import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"
import "../dialogs"

Page {
    id: root
    title: "Trips"

    signal themeModeChanged(int newMode)

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 64

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 20
            spacing: 8

            Label {
                text: "Group Trip"
                font.pixelSize: 26
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                id: settingsButton
                icon.name: "preferences-desktop-theme"
                icon.source: "qrc:/icons/settings.svg"
                onClicked: themeMenu.open()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Menu {
                id: themeMenu
                x: parent.width
                y: parent.height

                MenuItem {
                    text: "System Theme"
                    checkable: true
                    checked: ApplicationWindow.window.themeMode === Material.System
                    onTriggered: root.themeModeChanged(Material.System)
                }
                MenuItem {
                    text: "Light Theme"
                    checkable: true
                    checked: ApplicationWindow.window.themeMode === Material.Light
                    onTriggered: root.themeModeChanged(Material.Light)
                }
                MenuItem {
                    text: "Dark Theme"
                    checkable: true
                    checked: ApplicationWindow.window.themeMode === Material.Dark
                    onTriggered: root.themeModeChanged(Material.Dark)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.topMargin: 20
        spacing: 20

        // Summary Card
        SummaryCard {
            Layout.fillWidth: true
            tripCount: tripList.count
            totalMembers: {
                let total = 0
                for (var i = 0; i < tripList.count; i++) {
                    total += tripList.model.get(i).members
                }
                return total
            }
        }

        // Section Header
        Label {
            text: "Your Trips"
            font.pixelSize: 18
            font.weight: Font.DemiBold
            Layout.topMargin: 4
            opacity: 0.87
        }

        ListView {
            id: tripList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12

            model: ListModel {
                ListElement {
                    name: "Lagos Beach Trip"
                    members: 5
                }
                ListElement {
                    name: "Campus Picnic"
                    members: 8
                }
                ListElement {
                    name: "Abuja Conference"
                    members: 3
                }
            }

            delegate: TripCard {
                width: ListView.view.width
                tripName: name
                memberCount: members
                onClicked: {
                    var stack = root.StackView.view
                    stack.push("TripPage.qml", {
                                   "tripName": name,
                                   "memberCount": members
                               })
                }
            }
        }

        Button {
            text: "Add New Trip"
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            font.pixelSize: 15
            font.weight: Font.DemiBold
            Material.elevation: 3
            highlighted: true
            onClicked: addTripDialog.open()
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }

    AddTripDialog {
        id: addTripDialog
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
