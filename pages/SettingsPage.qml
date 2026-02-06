import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

import theme
import "../components"
import "../dialogs"

Page {
    id: root

    background: Rectangle {
        color: Material.background
    }

    header: ToolBar {
        Material.elevation: 2
        height: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 8
            spacing: 0

            ToolButton {
                icon.source: "qrc:/icons/chevron_left.svg"
                onClicked: root.StackView.view.pop()
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Label {
                text: "Settings"
                Layout.alignment: Qt.AlignVCenter
                font.weight: Font.DemiBold
                font.pixelSize: 20
                Layout.fillWidth: true
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 32

            // APPEARANCE SECTION
            SettingsSection {
                title: "Appearance"
                Layout.topMargin: 24

                content: ColumnLayout {
                    spacing: 8

                    Label {
                        text: "Theme"
                        font.pixelSize: 13
                        opacity: 0.6
                    }

                    SettingsCard {
                        content: ColumnLayout {
                            spacing: 0

                            RadioDelegate {
                                Layout.fillWidth: true
                                implicitHeight: 56
                                text: "System"
                                font.pixelSize: 14
                                checked: settingsManager?.theme === "system"
                                onClicked: settingsManager.setTheme("system")
                                icon.source: "qrc:/icons/contrast.svg"
                                icon.width: 20
                                icon.height: 20
                                icon.color: Qt.rgba(Material.foreground.r,
                                                    Material.foreground.g,
                                                    Material.foreground.b, 0.6)
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: ThemeManager.cardBorder
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                            }

                            RadioDelegate {
                                Layout.fillWidth: true
                                implicitHeight: 56
                                text: "Light"
                                font.pixelSize: 14
                                checked: settingsManager?.theme === "light"
                                onClicked: settingsManager.setTheme("light")
                                icon.source: "qrc:/icons/light_mode.svg"
                                icon.width: 20
                                icon.height: 20
                                icon.color: Qt.rgba(Material.foreground.r,
                                                    Material.foreground.g,
                                                    Material.foreground.b, 0.6)
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: ThemeManager.cardBorder
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                            }

                            RadioDelegate {
                                Layout.fillWidth: true
                                implicitHeight: 56
                                text: "Dark"
                                font.pixelSize: 14
                                checked: settingsManager?.theme === "dark"
                                onClicked: settingsManager.setTheme("dark")
                                icon.source: "qrc:/icons/dark_mode.svg"
                                icon.width: 20
                                icon.height: 20
                                icon.color: Qt.rgba(Material.foreground.r,
                                                    Material.foreground.g,
                                                    Material.foreground.b, 0.6)
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }

            // PREFERENCES SECTION
            SettingsSection {
                title: "Preferences"

                content: ColumnLayout {
                    spacing: 16

                    // Currency
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Default Currency"
                            font.pixelSize: 13
                            opacity: 0.6
                        }

                        SettingsCard {
                            Layout.preferredHeight: 56

                            content: Item {
                                CurrencyComboBox {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    currentCode: settingsManager?.currency
                                                 ?? "NGN"
                                    onActivated: settingsManager.setCurrency(
                                                     model[currentIndex].code)
                                }
                            }
                        }

                        Label {
                            text: "Applied to new groups by default"
                            font.pixelSize: 12
                            opacity: 0.5
                            leftPadding: 4
                        }
                    }

                    // Language
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Language"
                            font.pixelSize: 13
                            opacity: 0.6
                        }

                        SettingsCard {
                            Layout.preferredHeight: 56

                            content: Item {
                                ComboBox {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    enabled: false
                                    model: [{
                                            "name": "English",
                                            "code": "en"
                                        }]
                                    textRole: "name"
                                    valueRole: "code"
                                }
                            }
                        }

                        Label {
                            text: "More languages coming soon"
                            font.pixelSize: 12
                            opacity: 0.5
                            leftPadding: 4
                        }
                    }

                    // Startup
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Startup"
                            font.pixelSize: 13
                            opacity: 0.6
                        }

                        SettingsCard {
                            content: CheckDelegate {
                                implicitHeight: 56
                                anchors.fill: parent
                                text: "Open last trip on startup"
                                font.pixelSize: 14
                                checked: settingsManager?.openLastTrip ?? true
                                onToggled: settingsManager.setOpenLastTrip(
                                               checked)
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }

            // CONFIRMATIONS SECTION
            SettingsSection {
                title: "Confirmations"

                content: SettingsCard {
                    content: ColumnLayout {
                        spacing: 0

                        CheckDelegate {
                            Layout.fillWidth: true
                            implicitHeight: 56
                            text: "Ask before deleting groups"
                            font.pixelSize: 14
                            checked: settingsManager?.confirmDeleteGroups
                                     ?? true
                            onToggled: settingsManager.setConfirmDeleteGroups(
                                           checked)
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: ThemeManager.cardBorder
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                        }

                        CheckDelegate {
                            Layout.fillWidth: true
                            implicitHeight: 56
                            text: "Ask before deleting expenses"
                            font.pixelSize: 14
                            checked: settingsManager?.confirmDeleteExpenses
                                     ?? true
                            onToggled: settingsManager.setConfirmDeleteExpenses(
                                           checked)
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }

            // DATA MANAGEMENT SECTION
            SettingsSection {
                title: "Data Management"

                content: ColumnLayout {
                    spacing: 16

                    // Export Card
                    SettingsCard {
                        content: ColumnLayout {
                            spacing: 0

                            SettingsActionItem {
                                iconSource: "qrc:/icons/download.svg"
                                iconBackgroundColor: Qt.alpha(
                                                         Material.color(
                                                             Material.Blue),
                                                         0.1)
                                title: "Export as JSON"
                                subtitle: "Human-readable export with all data"
                                onClicked: jsonFileDialog.open()
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: ThemeManager.cardBorder
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                            }

                            SettingsActionItem {
                                iconSource: "qrc:/icons/file_save.svg"
                                iconBackgroundColor: Qt.alpha(
                                                         Material.color(
                                                             Material.Teal),
                                                         0.1)
                                title: "Backup Database"
                                subtitle: "Complete database backup file"
                                onClicked: dbFileDialog.open()
                            }
                        }
                    }

                    // Danger Zone Card
                    SettingsCard {
                        borderColor: Qt.alpha(Material.color(Material.Red), 0.3)

                        content: ColumnLayout {
                            spacing: 0

                            SettingsActionItem {
                                iconSource: "qrc:/icons/refresh.svg"
                                iconBackgroundColor: Qt.alpha(
                                                         Material.color(
                                                             Material.Red), 0.1)
                                title: "Reset All Settings"
                                subtitle: "Restore default preferences"
                                titleColor: Material.color(Material.Red)
                                onClicked: resetDialog.open()
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: ThemeManager.cardBorder
                                Layout.leftMargin: 16
                                Layout.rightMargin: 16
                            }

                            SettingsActionItem {
                                iconSource: "qrc:/icons/delete.svg"
                                iconBackgroundColor: Qt.alpha(
                                                         Material.color(
                                                             Material.Red), 0.1)
                                title: "Delete All Groups"
                                subtitle: "⚠️ Permanently deletes all data"
                                titleColor: Material.color(Material.Red)
                                subtitleColor: Material.color(Material.Red,
                                                              Material.Shade300)
                                itemHeight: 72
                                onClicked: deleteDialog.open()
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 24
            }
        }
    }

    // File Dialogs
    FileDialog {
        id: jsonFileDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: ["JSON files (*.json)"]
        currentFolder: "file:///home"

        onAccepted: {
            if (tripManager.exportDataAsJson(selectedFile.toString().replace(
                                                 "file://", ""))) {
                console.log("JSON export successful")
            } else {
                console.error("JSON export failed")
            }
        }
    }

    FileDialog {
        id: dbFileDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: "db"
        nameFilters: ["Database files (*.db)"]
        currentFolder: "file:///home"

        onAccepted: {
            if (tripManager.exportDatabaseFile(selectedFile.toString().replace(
                                                   "file://", ""))) {
                console.log("Database backup successful")
            } else {
                console.error("Database backup failed")
            }
        }
    }

    // Confirmation Dialogs
    ConfirmationDialog {
        id: resetDialog
        title: "Reset All Settings?"
        message: "This will reset all settings to their default values."
        warningText: "Your groups and expenses will not be affected."
        confirmText: "Reset"
        confirmColor: Material.color(Material.Red)

        onConfirmed: settingsManager.resetToDefaults()
    }

    ConfirmationDialog {
        id: deleteDialog
        title: "Delete All Groups?"
        message: "This will permanently delete all groups and their expenses."
        warningText: "This action cannot be undone."
        confirmText: "Delete All"
        confirmColor: Material.color(Material.Red)

        onConfirmed: {
            if (!tripManager.deleteAllTrips()) {
                console.error("Failed to delete all groups")
            }
        }
    }
}
