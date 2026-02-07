pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject {
    id: themeManager
    property int theme: Material.System
    Material.theme: theme
    readonly property bool isDark: Material.theme === Material.Dark

    // Colors
    readonly property color cardBackground: isDark ? Qt.rgba(1, 1, 1,
                                                             0.05) : "#FFFFFF"
    readonly property color cardBorder: isDark ? Qt.rgba(1, 1, 1,
                                                         0.12) : Material.color(
                                                     Material.Grey,
                                                     Material.Shade200)

    // Accent cards
    readonly property color accentCardBackground: isDark ? Qt.rgba(
                                                               33 / 255,
                                                               150 / 255,
                                                               243 / 255,
                                                               0.12) : Material.color(
                                                               Material.Blue,
                                                               Material.Shade50)
    readonly property color accentCardBorder: isDark ? Qt.rgba(
                                                           33 / 255, 150 / 255,
                                                           243 / 255,
                                                           0.3) : Material.color(
                                                           Material.Blue,
                                                           Material.Shade100)

    // ========================================================================
    // Optional: Add more theme properties here as needed
    // ========================================================================
    readonly property int defaultRadius: 12
    readonly property int cardRadius: 16
    readonly property int smallRadius: 8

    readonly property int defaultElevation: 2
    readonly property int cardElevation: 3
}
