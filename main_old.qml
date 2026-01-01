import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

ApplicationWindow {
    id: app
    visible: true
    width: 480
    height: 640
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
        initialItem: homePage
    }

    Component {
        id: pointerCursor
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }

    Component {
        id: homePage

        Page {
            title: "Trips"

            background: Rectangle {
                color: Material.background
            }

            header: ToolBar {
                Material.elevation: 2
                height: 64

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 20
                    spacing: 8

                    Label {
                        text: "Group Trips"
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        id: settingsButton
                        icon.name: "preferences-desktop-theme"
                        icon.source: "qrc:/icons/settings.svg"
                        onClicked: themeMenu.open()
                        Component.onCompleted: pointerCursor.createObject(this)
                    }

                    Menu {
                        id: themeMenu
                        x: parent.width
                        y: parent.height

                        MenuItem {
                            text: "System Theme"
                            checkable: true
                            checked: themeMode === Material.System
                            onTriggered: themeMode = Material.System
                        }
                        MenuItem {
                            text: "Light Theme"
                            checkable: true
                            checked: themeMode === Material.Light
                            onTriggered: themeMode = Material.Light
                        }
                        MenuItem {
                            text: "Dark Theme"
                            checkable: true
                            checked: themeMode === Material.Dark
                            onTriggered: themeMode = Material.Dark
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                anchors.topMargin: 20
                spacing: 20

                // Summary Card
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 20
                    color: app.accentCardBackground
                    border.color: app.accentCardBorder
                    border.width: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0, 0, 0, 0.1)
                        shadowBlur: 0.4
                        shadowVerticalOffset: 2
                        shadowHorizontalOffset: 0
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            Label {
                                text: "TOTAL TRIPS"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                                opacity: 0.65
                                color: Material.accent
                            }
                            Label {
                                text: tripList.count.toString()
                                font.pixelSize: 32
                                font.weight: Font.Bold
                                color: Material.accent
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 12
                            Layout.bottomMargin: 12
                            color: app.accentCardBorder
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            Label {
                                text: "TOTAL MEMBERS"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                                opacity: 0.65
                                color: Material.accent
                            }
                            Label {
                                text: {
                                    let total = 0
                                    for (var i = 0; i < tripList.count; i++) {
                                        total += tripList.model.get(i).members
                                    }
                                    return total.toString()
                                }
                                font.pixelSize: 32
                                font.weight: Font.Bold
                                color: Material.accent
                            }
                        }
                    }
                }

                // Section Header
                Label {
                    text: "Your Trips"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    Layout.topMargin: 4
                    opacity: 0.87
                }

                ListView {
                    id: tripList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 12

                    model: ListModel {
                        ListElement {
                            name: "Lagos Beach Trip"
                            members: 5
                        }
                        ListElement {
                            name: "Campus Picnic"
                            members: 8
                        }
                        ListElement {
                            name: "Abuja Conference"
                            members: 3
                        }
                    }

                    delegate: ItemDelegate {
                        id: control
                        width: ListView.view.width
                        implicitHeight: 88

                        background: Rectangle {
                            radius: 16
                            color: {
                                if (control.pressed)
                                    return Material.color(
                                                Material.Blue,
                                                Material.theme === Material.Dark ? Material.Shade800 : Material.Shade100)
                                if (control.hovered)
                                    return Material.theme
                                            === Material.Dark ? Qt.rgba(
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    0.08) : Material.color(
                                                                    Material.Grey,
                                                                    Material.Shade50)
                                return app.cardBackground
                            }
                            border.color: control.hovered ? Material.accent : app.cardBorder
                            border.width: control.hovered ? 2 : 1

                            layer.enabled: !control.pressed
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0, 0, 0, 0.08)
                                shadowBlur: 0.3
                                shadowVerticalOffset: 1
                                shadowHorizontalOffset: 0
                            }
                        }

                        contentItem: RowLayout {
                            // anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 52
                                height: 52
                                radius: 26
                                color: Material.theme
                                       === Material.Dark ? Qt.rgba(
                                                               33 / 255,
                                                               150 / 255,
                                                               243 / 255,
                                                               0.2) : Material.color(
                                                               Material.Blue,
                                                               Material.Shade100)
                                border.color: Material.color(
                                                  Material.Blue,
                                                  Material.theme === Material.Dark ? Material.Shade600 : Material.Shade300)
                                border.width: 1.5
                                Layout.alignment: Qt.AlignVCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: name.substring(0, 1)
                                    font.pixelSize: 24
                                    font.weight: Font.Bold
                                    color: Material.accent
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                Label {
                                    text: name
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: members + " members"
                                    opacity: 0.6
                                    font.pixelSize: 14
                                }
                            }

                            Label {
                                text: "›"
                                font.pixelSize: 28
                                opacity: 0.3
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: stack.push(tripPageComponent, {
                                                  "tripName": name,
                                                  "memberCount": members
                                              })
                        Component.onCompleted: pointerCursor.createObject(this)
                    }
                }

                Button {
                    text: "Add New Trip"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    Material.elevation: 3
                    highlighted: true
                    onClicked: addTripDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
                }
            }
        }
    }

    Component {
        id: tripPageComponent

        Page {
            property string tripName
            property int memberCount

            background: Rectangle {
                color: Material.background
            }

            header: ToolBar {
                Material.elevation: 2
                height: 64

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 16
                    spacing: 4

                    ToolButton {
                        text: "‹"
                        font.pixelSize: 28
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        onClicked: stack.pop()
                        Component.onCompleted: pointerCursor.createObject(this)
                    }

                    Label {
                        text: tripName
                        Layout.alignment: Qt.AlignVCenter
                        font.weight: Font.DemiBold
                        font.pixelSize: 19
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    ToolButton {
                        icon.name: 'preferences-other'
                        icon.source: 'qrc:/icons/more_vert.svg'
                        onClicked: tripOptionsMenu.open()
                        Component.onCompleted: pointerCursor.createObject(this)
                    }

                    Menu {
                        id: tripOptionsMenu
                        x: parent.width
                        y: parent.height

                        MenuItem {
                            text: "View Settlement"
                            onClicked: settlementDialog.open()
                            Component.onCompleted: pointerCursor.createObject(
                                                       this)
                        }
                        MenuItem {
                            text: "Edit Trip"
                            onClicked: console.log("TODO: Edit Trip")
                            Component.onCompleted: pointerCursor.createObject(
                                                       this)
                        }
                        MenuItem {
                            text: "Delete Trip"
                            onClicked: console.log("TODO: Delete Trip")
                            Component.onCompleted: pointerCursor.createObject(
                                                       this)
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                anchors.topMargin: 20
                spacing: 20

                Rectangle {
                    Layout.fillWidth: true
                    height: 120
                    radius: 20
                    color: app.accentCardBackground
                    border.color: app.accentCardBorder
                    border.width: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0, 0, 0, 0.1)
                        shadowBlur: 0.4
                        shadowVerticalOffset: 2
                        shadowHorizontalOffset: 0
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 6

                            Label {
                                text: "MEMBERS"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                                opacity: 0.65
                                color: Material.accent
                            }
                            Label {
                                text: memberCount.toString()
                                font.pixelSize: 36
                                font.weight: Font.Bold
                                color: Material.accent
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 16
                            Layout.bottomMargin: 16
                            color: app.accentCardBorder
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 6

                            Label {
                                text: "TOTAL"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                                opacity: 0.65
                                color: Material.accent
                            }
                            Label {
                                text: "₦22,500"
                                font.pixelSize: 36
                                font.weight: Font.Bold
                                color: Material.accent
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 16
                            Layout.bottomMargin: 16
                            color: app.accentCardBorder
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 6

                            Label {
                                text: "PER PERSON"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                                opacity: 0.65
                                color: Material.accent
                            }
                            Label {
                                text: "₦" + (22500 / memberCount).toFixed(0)
                                font.pixelSize: 36
                                font.weight: Font.Bold
                                color: Material.accent
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Label {
                        text: "Expenses"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                        opacity: 0.87
                    }

                    Rectangle {
                        width: 52
                        height: 24
                        radius: 12
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
                                                       255 / 255, 255 / 255,
                                                       255 / 255,
                                                       0.1) : Material.color(
                                                       Material.Grey,
                                                       Material.Shade200)

                        Label {
                            anchors.centerIn: parent
                            text: expenseList.count + " items"
                            opacity: 0.7
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }
                }

                ListView {
                    id: expenseList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    clip: true

                    model: ListModel {
                        ListElement {
                            title: "Transport"
                            amount: "₦4,000"
                            icon: "🚗"
                            paidBy: "John"
                        }
                        ListElement {
                            title: "Food"
                            amount: "₦6,500"
                            icon: "🍽️"
                            paidBy: "Sarah"
                        }
                        ListElement {
                            title: "Hotel"
                            amount: "₦12,000"
                            icon: "🏨"
                            paidBy: "Mike"
                        }
                    }

                    delegate: ItemDelegate {
                        id: expenseDelegate
                        width: ListView.view.width
                        implicitHeight: 90

                        background: Rectangle {
                            radius: 16
                            color: {
                                if (expenseDelegate.pressed)
                                    return Material.color(
                                                Material.Blue,
                                                Material.theme === Material.Dark ? Material.Shade800 : Material.Shade50)
                                if (expenseDelegate.hovered)
                                    return Material.theme
                                            === Material.Dark ? Qt.rgba(
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    255 / 255,
                                                                    0.08) : Material.color(
                                                                    Material.Grey,
                                                                    Material.Shade50)
                                return app.cardBackground
                            }
                            border.color: app.cardBorder
                            border.width: 1

                            layer.enabled: !expenseDelegate.pressed
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0, 0, 0, 0.08)
                                shadowBlur: 0.3
                                shadowVerticalOffset: 1
                                shadowHorizontalOffset: 0
                            }
                        }

                        contentItem: RowLayout {
                            // anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: Material.theme
                                       === Material.Dark ? Qt.rgba(
                                                               255 / 255,
                                                               255 / 255,
                                                               255 / 255,
                                                               0.1) : Material.color(
                                                               Material.Grey,
                                                               Material.Shade100)
                                Layout.alignment: Qt.AlignVCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: icon
                                    font.pixelSize: 26
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 5

                                Label {
                                    text: title
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                }
                                Label {
                                    text: "Paid by " + paidBy
                                    opacity: 0.55
                                    font.pixelSize: 13
                                }
                                Label {
                                    text: "₦" + (parseFloat(
                                                     amount.replace(
                                                         /[₦,]/g,
                                                         "")) / memberCount).toFixed(
                                              2) + " per person"
                                    opacity: 0.7
                                    font.pixelSize: 12
                                    color: Material.accent
                                    font.weight: Font.Medium
                                }
                            }

                            Label {
                                text: amount
                                font.weight: Font.Bold
                                font.pixelSize: 19
                                color: Material.accent
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: console.log("TODO: View/Edit Expense")
                        Component.onCompleted: pointerCursor.createObject(this)
                    }
                }

                Button {
                    text: "Add Expense"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    Material.elevation: 3
                    highlighted: true
                    onClicked: addExpenseDialog.open()
                    Component.onCompleted: pointerCursor.createObject(this)
                }
            }

            // Settlement Dialog
            Dialog {
                id: settlementDialog
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
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
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
                                    color: Material.color(Material.Green,
                                                          Material.Shade700)
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 76
                        radius: 16
                        color: Material.theme
                               === Material.Dark ? Qt.rgba(
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
                                    color: Material.color(Material.Green,
                                                          Material.Shade700)
                                }
                            }
                        }
                    }
                }
            }

            // Add Expense Dialog
            Dialog {
                id: addExpenseDialog
                title: "Add Expense"
                modal: true
                anchors.centerIn: parent
                width: parent.width * 0.88
                padding: 24

                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Expense title"
                        font.pixelSize: 15
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Amount (₦)"
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: 15
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Paid by"
                        font.pixelSize: 15
                    }

                    Button {
                        text: "Add Expense"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        font.weight: Font.DemiBold
                        highlighted: true
                        onClicked: {
                            console.log("TODO: Add expense logic")
                            addExpenseDialog.close()
                        }
                        Component.onCompleted: pointerCursor.createObject(this)
                    }
                }
            }
        }
    }

    // Add Trip Dialog
    Dialog {
        id: addTripDialog
        title: "Create New Trip"
        modal: true
        anchors.centerIn: parent
        width: parent.width * 0.88
        padding: 24

        ColumnLayout {
            width: parent.width
            spacing: 16

            TextField {
                Layout.fillWidth: true
                placeholderText: "Trip name"
                font.pixelSize: 15
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: "Number of members"
                inputMethodHints: Qt.ImhDigitsOnly
                font.pixelSize: 15
            }

            Button {
                text: "Create Trip"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.weight: Font.DemiBold
                highlighted: true
                onClicked: {
                    console.log("TODO: Add trip logic")
                    addTripDialog.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }
}
