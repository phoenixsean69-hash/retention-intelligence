import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string heading: 'Observed churn by segment'
    property string subtitle: 'Percent of known outcomes that churned'
    property var rows: []
    property string selectedName: ''
    implicitHeight: Math.max(235, 112 + rows.length * 62)
    radius: 14
    color: '#FFFFFF'
    border.color: '#E6ECF5'
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 13
        Text { text: root.heading; font.pixelSize: 16; font.weight: Font.DemiBold; color: '#102A43' }
        Text { text: root.subtitle; font.pixelSize: 12; color: '#7B8794' }
        Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
        Repeater {
            model: root.rows
            delegate: Item {
                Layout.fillWidth: true
                implicitHeight: 49
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.name; font.pixelSize: 12; color: '#243B53'; elide: Text.ElideRight; Layout.fillWidth: true }
                        Text { text: modelData.rate.toFixed(1) + '%'; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#1D4ED8' }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 9; radius: 4; color: '#EFF3F8'; clip: true
                        Rectangle { width: parent.width * Math.min(1, modelData.rate / 100); height: parent.height; radius: 4; color: root.selectedName === modelData.name ? '#F28C28' : '#2563EB' }
                    }
                    Text { text: modelData.churned + ' of ' + modelData.count + ' labeled customers churned'; font.pixelSize: 10; color: '#829AB1' }
                }
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedName = modelData.name }
            }
        }
        Text { visible: root.rows.length === 0; text: 'Not enough mapped data to compute this breakdown.'; color: '#7B8794'; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Item { Layout.fillHeight: true }
    }
}
