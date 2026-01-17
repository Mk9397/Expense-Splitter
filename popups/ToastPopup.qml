import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Popup {
    id: control
    modal: false
    focus: false
    closePolicy: Popup.NoAutoClose

    x: (parent.width - width) / 2
    y: parent.height - height - 24

    padding: 16

    property string pdfPath: ""
    property string displayPath: ""
    property string fileName: ""

    background: Rectangle {
        radius: 8
        color: Material.background
        border.color: Material.dividerColor
    }

    ColumnLayout {
        spacing: 12 //8

        // Success icon + message row
        RowLayout {
            spacing: 12

            // Success icon
            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: Material.color(Material.Green, Material.Shade200)

                Label {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 16
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade800)
                }
            }

            Label {
                text: "File saved successfully"
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
        }

        // File info section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: fileInfoLayout.implicitHeight + 16
            radius: 4
            color: Qt.rgba(Material.foreground.r, Material.foreground.g,
                           Material.foreground.b, 0.05)

            ColumnLayout {
                id: fileInfoLayout
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Label {
                    text: control.fileName
                    font.weight: Font.Medium
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 360
                }

                Label {
                    id: pathLabel
                    text: control.displayPath
                    opacity: 0.6
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 360

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: pathToolTip.visible = true
                        onExited: pathToolTip.visible = false
                        onClicked: fileActions.showInFolder(control.pdfPath)
                    }
                    ToolTip {
                        id: pathToolTip
                        text: "Click to show in folder\n" + control.pdfPath
                        visible: false
                    }
                }
            }
        }

        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignRight

            Button {
                text: "Dismiss"
                flat: true
                onClicked: control.close()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Button {
                text: "Show in Folder"
                onClicked: {
                    fileActions.showInFolder(control.pdfPath)
                    control.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Button {
                text: "Open"
                highlighted: true
                onClicked: {
                    fileActions.openFile(control.pdfPath)
                    control.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }

    Timer {
        interval: 7000
        running: control.visible
        onTriggered: control.close()
    }
}
