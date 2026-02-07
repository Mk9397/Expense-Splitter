import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

// Reusable settings section with title
ColumnLayout {
    id: root

    property string title: ""
    property alias content: contentLoader.sourceComponent

    Layout.fillWidth: true
    Layout.leftMargin: 24
    Layout.rightMargin: 24
    spacing: 16

    Label {
        text: root.title
        font.pixelSize: 16
        font.weight: Font.Bold
        opacity: 0.87
        visible: title !== ""
    }

    Loader {
        id: contentLoader
        Layout.fillWidth: true
    }
}
