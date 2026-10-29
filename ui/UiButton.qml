import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string label: "Action"
    property bool primary: true
    property string iconName: ""
    property bool disabled: false
    property int buttonHeight: 42
    signal clicked()
    implicitHeight: buttonHeight
    implicitWidth: Math.max(116, labelText.implicitWidth + (iconName.length ? 65 : 40))
    radius: 10
    color: disabled ? "#DCE3EB" : (primary ? (hoverArea.containsMouse ? "#1D4ED8" : "#2563EB") : (hoverArea.containsMouse ? "#EEF4FF" : "#FFFFFF"))
    border.color: primary ? "transparent" : (hoverArea.containsMouse ? "#CFE0FF" : "#DCE5F0")
    border.width: primary ? 0 : 1
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Row {
        anchors.centerIn: parent
        spacing: 9
        AppIcon {
            iconName: root.iconName
            iconSize: 15
            color: root.primary ? "#FFFFFF" : "#1E3A5F"
            visible: root.iconName.length > 0
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: labelText
            text: root.label
            font.family: "Segoe UI"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: root.primary ? "#FFFFFF" : "#1E3A5F"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onClicked: root.clicked()
    }
}
