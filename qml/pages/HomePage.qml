import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import components
import dialogs
import popups
import theme

Page {
    id: root
    title: "Groups"
    property int totalTrips: tripManager ? tripManager.tripCount : 0

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 8

            Label {
                text: "Groups"
                font.pixelSize: 24
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            ToolButton {
                id: settingsButton
                icon.source: "qrc:/icons/settings.svg"

                onClicked: {
                    var stack = root.StackView.view
                    stack.push("SettingsPage.qml")
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.bottomMargin: 0
        spacing: 4

        // Search Bar
        SearchBar {
            id: searchBar
            visible: totalTrips > 0
        }

        RowLayout {
            visible: totalTrips > 0
            Label {
                text: "Your Groups"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                opacity: 0.87
                Layout.fillWidth: true
                // Layout.topMargin: 4
            }
            ToolButton {
                icon.source: "qrc:/icons/sort.svg"
                onClicked: sortMenu.open()
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Menu {
                id: sortMenu
                x: parent.width
                y: parent.height

                MenuItem {
                    text: "Name (A–Z)"
                    onTriggered: tripList.model.sortByNameAsc()
                }
                MenuItem {
                    text: "Name (Z–A)"
                    onTriggered: tripList.model.sortByNameDesc()
                }
                MenuItem {
                    text: "Recently updated"
                    onTriggered: tripList.model.sortByUpdatedDesc()
                }
                MenuItem {
                    text: "Oldest updated"
                    onTriggered: tripList.model.sortByUpdatedAsc()
                }
                MenuItem {
                    text: "Recently created"
                    onTriggered: tripList.model.sortByCreatedDesc()
                }
                MenuItem {
                    text: "Oldest created"
                    onTriggered: tripList.model.sortByCreatedAsc()
                }
            }
        }

        // Main Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Empty State
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 16
                visible: totalTrips === 0

                // Icon
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 80
                    height: 80
                    radius: 40
                    color: ThemeManager.accentCardBackground
                    border.color: ThemeManager.accentCardBorder
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/flight.svg"
                        sourceSize.width: 40
                        sourceSize.height: 40
                        opacity: 0.87
                    }
                }

                Label {
                    text: "No Groups Yet"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.87
                }

                Label {
                    text: "Start planning your next adventure by creating your first group"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    opacity: 0.6
                }
            }

            // No search results message
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 12
                visible: totalTrips > 0 && tripList.count === 0

                Label {
                    text: "No groups found"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.87
                }

                Label {
                    text: "Try adjusting your search"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 0.6
                }
            }

            ListView {
                id: tripList
                anchors.fill: parent
                spacing: 12
                clip: true
                visible: count > 0
                bottomMargin: 20

                // model: ListModel {}
                model: tripManager ? tripManager.proxyModel : null

                delegate: TripCard {
                    width: ListView.view.width
                    tripId: id
                    tripName: name
                    participantCount: participant_count

                    onClicked: {
                        var stack = root.StackView.view
                        stack.push("TripPage.qml", {
                                       "tripId": id
                                   })
                    }

                    onEditTrip: {
                        editTripDialog.tripId = id
                        editTripDialog.tripName = name
                        editTripDialog.participants = participants
                        editTripDialog.tripCurrency = currency
                        editTripDialog.open()
                    }

                    onDeleteTrip: {
                        if (!settingsManager.confirmDeleteGroups) {
                            tripManager.deleteTrip(id)
                        } else {
                            deleteTripDialog.tripId = id
                            deleteTripDialog.tripName = name
                            deleteTripDialog.open()
                        }
                    }

                    onShareTrip: {
                        let path = tripManager.shareTrip(id)
                        if (!path)
                            return
                        shareToast.pdfPath = path

                        let fileName = path.replace(/^.*[\\/]/, "")
                        shareToast.fileName = fileName

                        let pathParts = path.split(/[\\/]/)
                        pathParts.pop()
                        shareToast.displayPath = ".../" + pathParts.slice(
                                    -3).join('/')
                        shareToast.open()
                    }
                }
            }
        }

        Button {
            text: "Create Your First Group"
            visible: totalTrips === 0

            Layout.fillWidth: true
            Layout.preferredHeight: 52

            font.pixelSize: 15
            font.weight: Font.DemiBold

            Material.elevation: 3
            highlighted: true

            onClicked: addTripDialog.open()
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // Floating Action Button
    RoundButton {
        id: fab
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        width: hovered ? implicitWidth + 32 : 56
        height: 56
        visible: totalTrips > 0

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        text: hovered ? "Add New Group" : ""
        icon.source: "qrc:/icons/add.svg"
        icon.width: 24
        icon.height: 24

        font.pixelSize: 15
        font.weight: Font.DemiBold

        Material.elevation: hovered ? 8 : 6
        Material.background: Material.accent

        Behavior on Material.elevation {
            NumberAnimation {
                duration: 200
            }
        }

        onClicked: addTripDialog.open()
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }

    ToastPopup {
        id: shareToast
    }

    GenericInputDialog {
        id: addTripDialog
        dialogTitle: "Create New Group"
        placeholderText: "Group name"
        confirmButtonText: "Create Group"

        onInputAccepted: function (text) {
            tripManager.addTrip(text)
        }
    }

    ConfirmationDialog {
        id: deleteTripDialog
        property string tripId: ""
        property string tripName: ""

        title: "Delete Group"
        message: "Are you sure you want to delete \"" + tripName + "\"?"
        warningText: "This action cannot be undone."
        confirmText: "Delete"
        confirmColor: Material.color(Material.Red)
        onConfirmed: tripManager.deleteTrip(tripId)
    }

    EditTripDialog {
        id: editTripDialog
        onTripEdited: function (tripId, tripName, participants, tripCurrency) {
            tripManager.editTrip(tripId, tripName, participants, tripCurrency)
        }
    }
}
