import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: root
    title: "Settlement Summary"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    ColumnLayout {
        width: parent.width
        spacing: 16

        Label {
            text: "Who owes who"
            font.pixelSize: 15
            opacity: 0.7
            Layout.bottomMargin: 4
        }

        Rectangle {
            Layout.fillWidth: true
            height: 76
            radius: 16
            color: Material.theme === Material.Dark ? Qt.rgba(
                                                          76 / 255, 175 / 255,
                                                          80 / 255,
                                                          0.12) : Material.color(
                                                          Material.Green,
                                                          Material.Shade50)
            border.color: Material.color(
                              Material.Green, Material.theme
                              === Material.Dark ? Material.Shade700 : Material.Shade200)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Label {
                    text: "💰"
                    font.pixelSize: 32
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "John owes Mike"
                        font.weight: Font.DemiBold
                        font.pixelSize: 15
                    }
                    Label {
                        text: "₦2,500"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: Material.color(Material.Green, Material.Shade700)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 76
            radius: 16
            color: Material.theme === Material.Dark ? Qt.rgba(
                                                          76 / 255, 175 / 255,
                                                          80 / 255,
                                                          0.12) : Material.color(
                                                          Material.Green,
                                                          Material.Shade50)
            border.color: Material.color(
                              Material.Green, Material.theme
                              === Material.Dark ? Material.Shade700 : Material.Shade200)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Label {
                    text: "💰"
                    font.pixelSize: 32
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Sarah owes Mike"
                        font.weight: Font.DemiBold
                        font.pixelSize: 15
                    }
                    Label {
                        text: "₦1,000"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: Material.color(Material.Green, Material.Shade700)
                    }
                }
            }
        }
    }
}
