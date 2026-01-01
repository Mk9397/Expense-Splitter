import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "pages"

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640

    minimumWidth: 300
    minimumHeight: 500

    title: "Expense Splitter"

    property int themeMode: Material.System
    Material.theme: themeMode
    Material.accent: Material.Blue
    Material.primary: Material.Blue

    // Computed properties for consistent styling
    readonly property color cardBackground: Material.theme
                                            === Material.Dark ? Qt.rgba(
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    0.05) : "#FFFFFF"

    readonly property color cardBorder: Material.theme
                                        === Material.Dark ? Qt.rgba(
                                                                255 / 255,
                                                                255 / 255,
                                                                255 / 255,
                                                                0.12) : Material.color(
                                                                Material.Grey,
                                                                Material.Shade200)

    readonly property color accentCardBackground: Material.theme
                                                  === Material.Dark ? Qt.rgba(
                                                                          33 / 255,
                                                                          150 / 255,
                                                                          243 / 255,
                                                                          0.12) : Material.color(
                                                                          Material.Blue,
                                                                          Material.Shade50)

    readonly property color accentCardBorder: Material.theme
                                              === Material.Dark ? Qt.rgba(
                                                                      33 / 255,
                                                                      150 / 255,
                                                                      243 / 255,
                                                                      0.3) : Material.color(
                                                                      Material.Blue,
                                                                      Material.Shade100)

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: HomePage {
            onThemeModeChanged: app.themeMode = newMode
        }
    }

    // Global pointer cursor component
    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
