import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: "Metric"
    property string value: "—"
    property string detail: ""
    property string mode: "ring"     // ring, progress, columns, charges
    property color accent: "#2563EB"
    property real firstPct: 0
    property real secondPct: 0
    property var bands: []
    property bool available: true

    implicitHeight: 181
    radius: 8
    color: "#FFFFFF"
    border.width: 1
    border.color: "#E0E7F0"

    onFirstPctChanged: ring.requestPaint()
    onSecondPctChanged: ring.requestPaint()
    onModeChanged: ring.requestPaint()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.title; color: "#54677C"; font.pixelSize: 12
                font.weight: Font.Medium; Layout.fillWidth: true; elide: Text.ElideRight
            }
            Rectangle { width: 5; height: 5; radius: 2.5; color: root.accent }
        }
        Item { Layout.preferredHeight: 17 }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            spacing: 9
            ColumnLayout {
                Layout.fillWidth: true; spacing: 3
                Text {
                    text: root.value; color: "#102A43"; font.pixelSize: root.value.length > 7 ? 24 : 28
                    font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight
                }
                Text {
                    text: root.detail; color: "#7F8FA3"; font.pixelSize: 10
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
            }
            Item {
                Layout.preferredWidth: 83
                Layout.preferredHeight: 62
                Canvas {
                    id: ring
                    anchors.centerIn: parent
                    width: 60; height: 60
                    visible: root.mode === "ring"
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.lineWidth = 7
                        ctx.lineCap = "butt"
                        var cx = width / 2, cy = height / 2, r = 23
                        function arc(start, length, color) {
                            if (length <= 0) return
                            ctx.beginPath()
                            ctx.strokeStyle = color
                            ctx.arc(cx, cy, r, start, start + length, false)
                            ctx.stroke()
                        }
                        var full = 2 * Math.PI
                        var a = -Math.PI/2
                        arc(a, full, "#E9EFF6")
                        if (!root.available) return
                        var first = Math.max(0, Math.min(100, root.firstPct)) / 100 * full
                        var second = Math.max(0, Math.min(100 - root.firstPct, root.secondPct)) / 100 * full
                        arc(a, first, "#2563EB")
                        arc(a+first, second, "#F28C28")
                    }
                }
                Column {
                    width: 76; spacing: 7
                    visible: root.mode === "columns" && root.available
                    anchors.centerIn: parent
                    Text { text: root.firstPct.toFixed(1) + "%"; color: root.accent; font.pixelSize: 16; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; width: parent.width }
                    Rectangle {
                        width: parent.width; height: 8; radius: 3; color: "#EDF1F6"; clip: true
                        Rectangle { width: parent.width*Math.max(0, Math.min(100,root.firstPct))/100; height: parent.height; radius: 3; color: root.accent }
                    }
                    Text { text: "of scored"; color: "#8A9AA9"; font.pixelSize: 9; width: parent.width; horizontalAlignment: Text.AlignHCenter }
                }
                Column {
                    width: 78; spacing: 5
                    visible: root.mode === "charges" && root.available
                    anchors.centerIn: parent
                    Text { text: "CHURNED"; color: "#8696A8"; font.pixelSize: 9 }
                    Rectangle {
                        width: parent.width; height: 8; radius: 2; color: "#EDF1F6"; clip: true
                        Rectangle { width: parent.width*Math.max(0, Math.min(100, root.firstPct))/100; height: parent.height; color: "#F28C28" }
                    }
                    Text { text: "RETAINED"; color: "#8696A8"; font.pixelSize: 9 }
                    Rectangle {
                        width: parent.width; height: 8; radius: 2; color: "#EDF1F6"; clip: true
                        Rectangle { width: parent.width*Math.max(0, Math.min(100,100-root.firstPct))/100; height: parent.height; color: "#2563EB" }
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
        Item { Layout.preferredHeight: 11 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Rectangle {
                width: 6; height: 6; radius: 3
                color: root.mode === "charges" || root.mode === "progress" ? "#F28C28" : "#2563EB"
            }
            Text {
                Layout.fillWidth: true
                text: root.available ? (
                    root.mode === "ring" ? root.firstPct.toFixed(1) + "% retained  ·  " + root.secondPct.toFixed(1) + "% churned" :
                    root.mode === "progress" ? root.firstPct.toFixed(1) + "% of labeled accounts" :
                    root.mode === "columns" ? "Based on model cutoff" :
                    root.firstPct.toFixed(1) + "% of labeled monthly charges"
                ) : "Available when data is ready"
                font.pixelSize: 10; color: "#687B90"; elide: Text.ElideRight
            }
        }
    }
}
