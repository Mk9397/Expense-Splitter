import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ComboBox {
    id: control
    property string currentCode: ""

    model: settingsManager ? settingsManager.getAvailableCurrencies() : []

    currentIndex: {
        for (var i = 0; i < model.length; i++) {
            if (model[i].code === currentCode)
                return i
        }
        return -1
    }

    delegate: ItemDelegate {
        width: control.width

        contentItem: RowLayout {
            spacing: 8
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Label {
                text: modelData.symbol
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                color: control.currentIndex === index ? Material.accent : Material.foreground

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Label {
                text: modelData.name
                font.pixelSize: 14
                font.weight: control.currentIndex === index ? Font.Medium : Font.Normal
                Layout.fillWidth: true
                color: control.currentIndex === index ? Material.accent : Material.foreground

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Label {
                text: modelData.code
                font.pixelSize: 13
                opacity: control.currentIndex === index ? 0.87 : 0.6
                color: control.currentIndex === index ? Material.accent : Material.foreground

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            // Check icon for selected item
            Item {
                implicitWidth: 18
                implicitHeight: 18
                Layout.preferredWidth: 18

                Image {
                    id: checkIcon
                    source: "qrc:/icons/check.svg"
                    sourceSize.width: 18
                    sourceSize.height: 18
                    visible: false
                }

                MultiEffect {
                    source: checkIcon
                    anchors.fill: checkIcon

                    colorization: 1.0
                    colorizationColor: control.currentIndex
                                       === index ? Material.accent : Material.foreground

                    visible: control.currentIndex === index
                    opacity: visible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }

        highlighted: control.highlightedIndex === index
        Component.onCompleted: pointerCursor.createObject(this)
    }

    // Closed combobox display
    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: control.indicator.width + 12
        spacing: 8

        Label {
            text: control.currentIndex >= 0 ? control.model[control.currentIndex].symbol : ""
            font.pixelSize: 15
        }

        Label {
            text: control.currentIndex
                  >= 0 ? control.model[control.currentIndex].name + " ("
                         + control.model[control.currentIndex].code + ")" : ""
            font.pixelSize: 14
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    Component.onCompleted: pointerCursor.createObject(this)
}
