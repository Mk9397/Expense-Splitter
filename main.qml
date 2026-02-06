import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import theme
import "pages"

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640

    minimumWidth: 300
    minimumHeight: 500

    maximumWidth: 500

    title: "Expense Splitter"

    property int themeMode: Material.System
    Material.theme: themeMode
    // Material.elevation: 2
    Material.accent: Material.Blue
    Material.primary: Material.Blue

    // Material.foreground: Material.theme === Material.Dark ? "#e0e0e0" : "#212121"
    // Material.background: Material.theme === Material.Dark ? "#121212" : "#ffffff"

    // Theme settings
    Component.onCompleted: {
        var savedTheme = settingsManager.theme
        if (savedTheme === "light") {
            themeMode = Material.Light
        } else if (savedTheme === "dark") {
            themeMode = Material.Dark
        } else {
            themeMode = Material.System
        }
        ThemeManager.theme = themeMode

        let lastTripId = settingsManager.lastTripId
        if (settingsManager.openLastTrip && lastTripId) {
            stack.push("pages/TripPage.qml", {
                           "tripId": lastTripId
                       })
        }
    }

    // Listen for theme changes from settings
    Connections {
        target: settingsManager
        function onThemeChanged() {
            var newTheme = settingsManager.theme
            if (newTheme === "light") {
                app.themeMode = Material.Light
            } else if (newTheme === "dark") {
                app.themeMode = Material.Dark
            } else {
                app.themeMode = Material.System
            }
            ThemeManager.theme = themeMode
        }
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: HomePage {}
    }

    // Global pointer cursor component
    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
