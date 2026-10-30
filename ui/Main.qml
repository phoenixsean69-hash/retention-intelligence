import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1440
    height: 900
    minimumWidth: 1100
    minimumHeight: 700
    title: "Retention Intelligence"
    color: "#F7F9FC"
    property int activePage: 0
    property var pageNames: ["Overview", "Customers", "Churn Analytics", "Prediction Studio", "Retention", "Data Sources", "Model Lab", "Reports", "Settings"]
    function navigate(index) { activePage = index }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#FFFFFF"
            border.color: "#E6ECF5"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 0
                RowLayout {
                    Layout.preferredHeight: 76
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 42; height: 42; radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#2563EB" }
                            GradientStop { position: 1.0; color: "#1D4ED8" }
                        }
                        Text { text: "R"; color: "white"; font.pixelSize: 22; font.weight: Font.Bold; anchors.centerIn: parent }
                    }
                    Column {
                        spacing: 2
                        Text { text: "RETENTION"; font.pixelSize: 14; font.weight: Font.Bold; font.letterSpacing: 1.1; color: "#102A43" }
                        Text { text: "INTELLIGENCE"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1.6; color: "#7B8794" }
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                Item { height: 22 }
                Text { text: "WORKSPACE"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1.3; color: "#98A6B3"; leftPadding: 12 }
                Item { height: 10 }
                Repeater {
                    model: [
                        {name: "Overview", icon: "overview", idx: 0},
                        {name: "Customers", icon: "customers", idx: 1},
                        {name: "Churn Analytics", icon: "analytics", idx: 2},
                        {name: "Prediction Studio", icon: "prediction", idx: 3},
                        {name: "Retention", icon: "retention", idx: 4}
                    ]
                    delegate: sidebarItem
                }
                Item { height: 24 }
                Text { text: "MANAGEMENT"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1.3; color: "#98A6B3"; leftPadding: 12 }
                Item { height: 10 }
                Repeater {
                    model: [
                        {name: "Data Sources", icon: "data", idx: 5},
                        {name: "Model Lab", icon: "model", idx: 6},
                        {name: "Reports", icon: "reports", idx: 7},
                        {name: "Settings", icon: "settings", idx: 8}
                    ]
                    delegate: sidebarItem
                }
                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F7F9FC"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78
                    color: "#FFFFFF"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 32
                        anchors.rightMargin: 32
                        spacing: 0
                        Text { text: "WORKSPACE"; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#98A6B3"; font.letterSpacing: 1.3 }
                        Text { text: "  /  "; font.pixelSize: 13; color: "#C0CAD5" }
                        Text { text: appWindow.pageNames[appWindow.activePage]; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#243B53" }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            height: 34; width: statusLabel.implicitWidth + 30; radius: 8
                            color: backend.hasData ? "#F8FBFF" : "#F4F6F8"
                            border.color: backend.hasData ? "#D6E6FF" : "#E7ECF2"
                            border.width: 1
                            Text {
                                id: statusLabel
                                anchors.centerIn: parent
                                text: backend.hasData ? "●  Dataset loaded" : "○  No dataset"
                                font.pixelSize: 11; font.weight: Font.DemiBold
                                color: backend.hasData ? "#1D4ED8" : "#7B8794"
                            }
                        }
                        Item { width: 8 }
                        Rectangle {
                            width: 36; height: 36; radius: 8; color: "#FFF4E8"
                            border.color: "#FAD7B0"; border.width: 1
                            Text { anchors.centerIn: parent; text: "RI"; font.pixelSize: 10; font.weight: Font.Bold; color: "#C96A10" }
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#E8EEF5" }
Loader {
    id: pageLoader
    Layout.fillWidth: true
    Layout.fillHeight: true
    source: ["OverviewPage.qml", "CustomersPage.qml", "AnalysisPage.qml", "PredictionPage.qml", "RetentionPage.qml", "DataPage.qml", "ModelLabPage.qml", "ReportsPage.qml", "SettingsPage.qml"][appWindow.activePage]

    onLoaded: {
        if (!item)
            return

        try {
            item.hostWindow = appWindow
        } catch (e) {
        }
    }
}
                Connections {
                    target: pageLoader.item
                    ignoreUnknownSignals: true
                    function onNavigateRequested(page) { appWindow.navigate(page) }
                }
            }
        }
    }

    Component {
        id: sidebarItem
        Rectangle {
            id: navItem
            Layout.fillWidth: true
            height: 48
            radius: 10
            color: appWindow.activePage === modelData.idx ? "#EDF4FF" : (pointer.containsMouse ? "#F8FAFD" : "transparent")
            border.color: appWindow.activePage === modelData.idx ? "#D8E5FF" : "transparent"
            border.width: 1
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 12
                Item {
                    width: 30; height: 30
                    AppIcon {
                        anchors.centerIn: parent
                        iconName: modelData.icon
                        iconSize: 19
                        color: appWindow.activePage === modelData.idx ? "#1D4ED8" : "#718096"
                    }
                }
                Text {
                    Layout.fillWidth: true; text: modelData.name; font.pixelSize: 12
                    font.weight: appWindow.activePage === modelData.idx ? Font.DemiBold : Font.Normal
                    color: appWindow.activePage === modelData.idx ? "#1D4ED8" : "#486581"
                }
                Rectangle { width: 4; height: 22; radius: 2; color: "#F28C28"; visible: appWindow.activePage === modelData.idx }
            }
            MouseArea { id: pointer; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: appWindow.navigate(modelData.idx) }
        }
    }
}
