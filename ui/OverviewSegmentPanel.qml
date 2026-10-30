import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string heading: "Segment comparison"
    property string subtitle: "Observed churn rates"
    property var rows: []
    property color accent: "#2563EB"
    implicitHeight: 335
    color: "#FFFFFF"
    border.color: "#E0E7F0"
    border.width: 1
    radius: 8
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 11
        Text { text: root.heading; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#142E49" }
        Text { text: root.subtitle; font.pixelSize: 11; color: "#798B9D"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
        Repeater {
            model: root.rows || []
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; elide: Text.ElideRight; text: modelData.name; font.pixelSize: 11; color: "#314960" }
                    Text { text: modelData.rate.toFixed(1) + "%"; color: "#142E49"; font.pixelSize: 11; font.weight: Font.DemiBold }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 7; radius: 3; color: "#EDF2F7"; clip: true
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(100, modelData.rate)) / 100
                        height: parent.height; radius: 3
                        color: index === 0 ? "#F28C28" : root.accent
                    }
                }
            }
        }
        Text { visible: !root.rows || root.rows.length === 0; text: "No data for this breakdown"; color: "#7B8794"; font.pixelSize: 12 }
        Item { Layout.fillHeight: true }
    }
}
