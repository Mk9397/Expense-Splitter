import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Popup {
    id: control
    modal: true
    focus: true
    padding: 24
    anchors.centerIn: parent

    property var selectedIds: []
    property var memberModel

    signal accepted(var selectedIds)

    background: Rectangle {
        radius: 12
        color: Material.background
        border.color: Material.dividerColor
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Label {
            text: "Exclude members"
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: control.memberModel ?? null

            delegate: CheckDelegate {
                width: parent.width
                text: name
                checked: control.selectedIds.includes(model.id)

                onToggled: {
                    if (checked) {
                        if (!control.selectedIds.includes(model.id))
                            control.selectedIds = control.selectedIds.concat(
                                        model.id)
                    } else {
                        control.selectedIds = control.selectedIds.filter(
                                    m => m !== model.id)
                    }
                }
            }
        }

        Button {
            text: "Done"
            Layout.fillWidth: true
            highlighted: true
            onClicked: {
                control.accepted(control.selectedIds)
                control.close()
            }
            Component.onCompleted: pointerCursor.createObject(this)
        }
    }
}
