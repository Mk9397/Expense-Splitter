import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"
import "../dialogs"
import "../popups"

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
                onClicked: settingsMenu.open()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Menu {
                id: settingsMenu
                width: 260
                x: parent.width
                y: parent.height

                Label {
                    text: "Global Currency"
                    font.pixelSize: 12
                    opacity: 0.6
                    leftPadding: 16
                    topPadding: 8
                    bottomPadding: 4
                }

                MenuItem {
                    contentItem: CurrencyComboBox {
                        id: globalCurrencyCombo
                        currentCode: settingsManager ? settingsManager.currency : "NGN"
                        onActivated: settingsManager.setCurrency(
                                         globalCurrencyCombo.model[globalCurrencyCombo.currentIndex].code)
                    }
                }

                MenuSeparator {}
                Label {
                    text: "Theme"
                    font.pixelSize: 12
                    opacity: 0.6
                    leftPadding: 16
                    topPadding: 8
                    bottomPadding: 4
                }

                MenuItem {
                    text: "System Theme"
                    checkable: true
                    checked: settingsManager ? settingsManager.theme === "system" : false
                    onTriggered: settingsManager.setTheme("system")
                }
                MenuItem {
                    text: "Light Theme"
                    checkable: true
                    checked: settingsManager ? settingsManager.theme === "light" : false
                    onTriggered: settingsManager.setTheme("light")
                }
                MenuItem {
                    text: "Dark Theme"
                    checkable: true
                    checked: settingsManager ? settingsManager.theme === "dark" : false
                    onTriggered: settingsManager.setTheme("dark")
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Search Bar
        SearchBar {
            id: searchBar
            visible: totalTrips > 0
        }

        Label {
            text: "Your Groups"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            Layout.topMargin: 4
            opacity: 0.87
            visible: totalTrips > 0
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
                    color: ApplicationWindow.window.accentCardBackground
                    border.color: ApplicationWindow.window.accentCardBorder
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
                        deleteTripDialog.tripId = id
                        deleteTripDialog.tripName = name
                        deleteTripDialog.open()
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
            text: totalTrips === 0 ? "Create Your First Group" : "Add New Group"
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

    ToastPopup {
        id: shareToast
    }

    AddTripDialog {
        id: addTripDialog
        onTripCreated: function (tripName) {
            tripManager.addTrip(tripName)
        }
    }

    DeleteTripDialog {
        id: deleteTripDialog
        onTripDeleted: function (tripId) {
            tripManager.deleteTrip(tripId)
        }
    }

    EditTripDialog {
        id: editTripDialog
        onTripEdited: function (tripId, tripName, participants, tripCurrency) {
            tripManager.editTrip(tripId, tripName, participants, tripCurrency)
        }
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
