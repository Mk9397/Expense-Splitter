import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

Dialog {
    id: root
    title: "Edit Trip"
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.88
    padding: 24

    property string tripId: ""
    property string tripName: ""
    property int memberCount: 0
    property string tripCurrency: ""

    ColumnLayout {
        width: parent.width
        spacing: 16

        TextField {
            id: editTripNameField
            Layout.fillWidth: true
            placeholderText: "Trip name"
            text: root.tripName
            font.pixelSize: 15
        }

        TextField {
            id: editMembersField
            Layout.fillWidth: true
            placeholderText: "Number of members"
            text: root.memberCount
            inputMethodHints: Qt.ImhDigitsOnly
            font.pixelSize: 15
        }

        CurrencyComboBox {
            id: editCurrencyCombo
            Layout.fillWidth: true
            currentCode: root.tripCurrency
            Component.onCompleted: pointerCursor.createObject(this)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                flat: true
                onClicked: root.close()
                Component.onCompleted: pointerCursor.createObject(this)
            }

            Button {
                text: "Save"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                highlighted: true
                onClicked: {
                    tripManager.editTrip(
                                root.tripId, editTripNameField.text,
                                editMembersField.text,
                                editCurrencyCombo.model[editCurrencyCombo.currentIndex].code)
                    root.close()
                }
                Component.onCompleted: pointerCursor.createObject(this)
            }
        }
    }
}
