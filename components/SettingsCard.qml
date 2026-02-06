import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import theme

// Reusable card for settings groups
Rectangle {
    id: root

    property alias content: contentLoader.sourceComponent
    property color borderColor: ThemeManager.cardBorder

    Layout.fillWidth: true
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0
    radius: 12
    color: ThemeManager.cardBackground
    border.color: borderColor
    border.width: 1

    Loader {
        id: contentLoader
        anchors.fill: parent
    }
}
