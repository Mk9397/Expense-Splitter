import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"
import "../dialogs"

Page {
    id: root
    title: "Trips"
    property int totalTrips: 0

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 64

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 8

            Label {
                text: "Group Trip"
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

                        onActivated: settingsManager.setCurrency(
                                         globalCurrencyCombo.model[globalCurrencyCombo.currentIndex].code)

                        Component.onCompleted: {
                            pointerCursor.createObject(this)
                            for (var i = 0; i < model.length; i++) {
                                if (globalCurrencyCombo.model[i].code
                                        === settingsManager.currency) {
                                    globalCurrencyCombo.currentIndex = i
                                    break
                                }
                            }
                        }
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
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            visible: totalTrips > 0

            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 24
                color: ApplicationWindow.window.cardBackground
                border.color: searchField.activeFocus ? Material.accent : ApplicationWindow.window.cardBorder
                border.width: searchField.activeFocus ? 2 : 1

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }
                Behavior on border.width {
                    NumberAnimation {
                        duration: 200
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Image {
                        source: "qrc:/icons/search.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        opacity: searchField.activeFocus ? 0.87 : 0.54
                        Layout.alignment: Qt.AlignVCenter

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    TextField {
                        id: searchField
                        placeholderText: searchField.activeFocus
                                         || searchField.text.length > 0 ? "" : "Search trips..."
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 15
                        verticalAlignment: TextInput.AlignVCenter

                        background: Item {}

                        color: Material.foreground
                        placeholderTextColor: Material.hintTextColor

                        onTextChanged: refreshTripList()
                    }

                    ToolButton {
                        visible: searchField.text.length > 0
                        opacity: visible ? 1 : 0
                        icon.source: "qrc:/icons/close.svg"
                        icon.width: 18
                        icon.height: 18
                        implicitWidth: 32
                        implicitHeight: 32
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: searchField.clear()
                        Component.onCompleted: pointerCursor.createObject(this)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }
                }
            }
        }

        Label {
            text: "Your Trips"
            font.pixelSize: 18
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
                    text: "No Trips Yet"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.87
                }

                Label {
                    text: "Start planning your next adventure by creating your first group trip"
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
                    text: "No trips found"
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

                model: ListModel {}

                delegate: TripCard {
                    width: ListView.view.width
                    tripId: id
                    tripName: name
                    memberCount: members

                    onClicked: {
                        var stack = root.StackView.view
                        stack.push("TripPage.qml", {
                                       "tripId": id,
                                       "tripName": name,
                                       "tripCurrency": currency,
                                       "memberCount": members
                                   })
                    }

                    onEditTrip: {
                        editTripDialog.tripId = id
                        editTripDialog.tripName = name
                        editTripDialog.memberCount = members
                        editTripDialog.tripCurrency = currency
                        editTripDialog.open()
                    }

                    onDeleteTrip: {
                        deleteTripDialog.tripId = id
                        deleteTripDialog.tripName = name
                        deleteTripDialog.open()
                    }

                    onShareTrip: {
                        // TODO: Implement share functionality
                        console.log("Share trip:", name)
                        console.log("Trip ID:", id)
                    }
                }
            }
        }

        Button {
            text: totalTrips === 0 ? "Create Your First Trip" : "Add New Trip"
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

    // Refresh list from Python backend
    function refreshTripList() {
        tripList.model.clear()
        var trips = tripManager.trips
        totalTrips = trips.length
        var searchText = searchField.text.toLowerCase()

        for (var i = 0; i < trips.length; i++) {
            if (searchText === "" || trips[i].name.toLowerCase().indexOf(
                        searchText) !== -1) {
                tripList.model.append({
                                          "name": trips[i].name,
                                          "members": trips[i].members
                                      })
            }
        }
    }

    // Load trips on startup
    Component.onCompleted: {
        refreshTripList()
    }

    // Listen for changes from Python
    Connections {
        target: tripManager
        function onTripsChanged() {
            refreshTripList()
        }
    }

    AddTripDialog {
        id: addTripDialog
        onTripCreated: function (tripName, memberCount) {
            tripManager.addTrip(tripName, memberCount)
        }
    }

    DeleteTripDialog {
        id: deleteTripDialog
    }

    EditTripDialog {
        id: editTripDialog
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
