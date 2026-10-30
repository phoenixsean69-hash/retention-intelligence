import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string label: "Action"
    property bool primary: true
    property string iconName: ""
    property bool disabled: false
    property int buttonHeight: 40
    signal clicked()
    implicitHeight: buttonHeight
    implicitWidth: Math.max(108, labelText.implicitWidth + (iconName.length ? 58 : 34))
    radius: 6
    color: disabled ? "#E6EBF2" : (primary ? (hoverArea.containsMouse ? "#2458D3" : "#2563EB") : (hoverArea.containsMouse ? "#F7FAFF" : "#FFFFFF"))
    border.color: primary ? "transparent" : (hoverArea.containsMouse ? "#C9D9F4" : "#D8E2EE")
    border.width: 1

    Row {
        anchors.centerIn: parent
        spacing: 8
        AppIcon {
            iconName: root.iconName
            iconSize: 15
            color: root.primary ? "#FFFFFF" : "#173B63"
            visible: root.iconName.length > 0
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: labelText
            text: root.label
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: root.disabled ? "#90A0B4" : (root.primary ? "#FFFFFF" : "#173B63")
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        enabled: !root.disabled
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
