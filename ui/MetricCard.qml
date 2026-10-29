import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string label: "Metric"
    property string value: "—"
    property string detail: ""
    property color accent: "#2563EB"
    property string iconName: "analytics"
    implicitHeight: 148
    radius: 14
    color: "#FFFFFF"
    border.color: "#E6ECF5"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Text { text: root.label; font.pixelSize: 12; font.weight: Font.Medium; color: "#5C6F82"; Layout.fillWidth: true; elide: Text.ElideRight }
            Rectangle {
                width: 32; height: 32; radius: 9; color: "#F3F7FF"
                AppIcon { anchors.centerIn: parent; iconName: root.iconName; iconSize: 17; color: root.accent }
            }
        }
        Item { Layout.fillHeight: true }
        Text { text: root.value; font.family: "Segoe UI"; font.pixelSize: 29; font.weight: Font.DemiBold; color: "#102A43"; Layout.fillWidth: true; elide: Text.ElideRight }
        Item { height: 8 }
        Text { text: root.detail; font.pixelSize: 11; color: "#829AB1"; Layout.fillWidth: true; elide: Text.ElideRight }
    }
}
