import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal navigateRequested(int page)
    ScrollView {
        id: viewport
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: availableWidth
        ColumnLayout {
            width: viewport.availableWidth
            anchors.leftMargin: 0
            spacing: 23
            Item { height: 7 }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 6
                    Text { text: "Customer overview"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#102A43" }
                    Text { text: "Observed churn and customer health at a glance"; font.pixelSize: 13; color: "#7B8794" }
                }
                Item { Layout.fillWidth: true }
                UiButton { label: "Import dataset"; iconName: "import"; disabled: backend.modelTraining; onClicked: backend.openDataset() }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 15
                MetricCard { Layout.fillWidth: true; label: "Total customers"; iconName: "people"; value: backend.totalCustomers; detail: "Rows in current dataset"; accent: "#2563EB" }
                MetricCard { Layout.fillWidth: true; label: "Observed churn rate"; iconName: "analytics"; value: backend.churnRate; detail: "Known outcome records only"; accent: "#F28C28" }
                MetricCard { Layout.fillWidth: true; label: "Churned customers"; iconName: "alert"; value: backend.churnedCustomers; detail: "Historical churn label"; accent: "#F28C28" }
                MetricCard { Layout.fillWidth: true; label: "Churned monthly charges"; iconName: "money"; value: backend.monthlyAssociated; detail: backend.currencyLabel + " · not lost revenue"; accent: "#1D4ED8" }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 16
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredWidth: 600; Layout.preferredHeight: 365
                    radius: 12; color: "#FFFFFF"; border.color: "#E6ECF5"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 22; spacing: 15
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout { spacing: 4
                                Text { text: "Churn by contract"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#102A43" }
                                Text { text: "Observed share who churned in each contract group"; font.pixelSize: 11; color: "#7B8794" }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle { height: 25; width: 92; radius: 13; color: "#FFF4E8"; border.color: "#FAD7B0"; border.width: 1
                                Text { text: "ACTUAL DATA"; anchors.centerIn: parent; font.pixelSize: 9; font.weight: Font.DemiBold; color: "#C96A10" }
                            }
                        }
                        Rectangle { height: 1; Layout.fillWidth: true; color: "#EDF2F7" }
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 17
                            visible: backend.contractStats.length > 0
                            Repeater {
                                model: backend.contractStats
                                delegate: ColumnLayout {
                                    Layout.fillWidth: true; spacing: 7
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: modelData.name; font.pixelSize: 12; font.weight: Font.Medium; color: "#243B53"; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: modelData.rate.toFixed(1) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#102A43" }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true; height: 11; radius: 6; color: "#EDF2F7"; clip: true
                                        Rectangle { width: parent.width * Math.max(0, Math.min(1, modelData.rate / 100)); height: parent.height; radius: 6; color: "#2563EB" }
                                    }
                                    Text { text: Math.round(modelData.count).toLocaleString(Qt.locale("en_US")) + " customers with known outcomes"; color: "#829AB1"; font.pixelSize: 10 }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                        ColumnLayout {
                            visible: backend.contractStats.length === 0
                            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 11
                            Item { Layout.fillHeight: true }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "No contract analysis available"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#243B53" }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Import a dataset containing Contract and Churn columns."; font.pixelSize: 11; color: "#7B8794" }
                            Item { Layout.fillHeight: true }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredWidth: 360; Layout.preferredHeight: 365
                    radius: 12; color: "#FFFFFF"; border.color: "#E6ECF5"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 22; spacing: 13
                        Text { text: "Outcome distribution"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#102A43" }
                        Text { text: "Customer records with known churn outcomes"; font.pixelSize: 11; color: "#7B8794" }
                        Item { height: 7 }
                        Text { text: Math.round(backend.summary.known).toLocaleString(Qt.locale("en_US")); font.pixelSize: 36; font.weight: Font.DemiBold; color: "#102A43" }
                        Text { text: "Labeled customer records"; font.pixelSize: 11; color: "#7B8794" }
                        Item { height: 9 }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: backend.summary.known ? backend.summary.retained : 1
                                height: 16; radius: 4; color: "#2563EB"
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredWidth: backend.summary.known ? backend.summary.churned : 1
                                height: 16; radius: 4; color: "#F28C28"
                            }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 9; height: 9; radius: 3; color: "#2563EB" }
                            Text { text: "Retained"; font.pixelSize: 11; color: "#5C6F82"; Layout.fillWidth: true }
                            Text { text: Math.round(backend.summary.retained).toLocaleString(Qt.locale("en_US")); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#102A43" }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 9; height: 9; radius: 3; color: "#F28C28" }
                            Text { text: "Churned"; font.pixelSize: 11; color: "#5C6F82"; Layout.fillWidth: true }
                            Text { text: Math.round(backend.summary.churned).toLocaleString(Qt.locale("en_US")); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#102A43" }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 9; height: 9; radius: 3; color: "#BCCCDC" }
                            Text { text: "Unknown / missing"; font.pixelSize: 11; color: "#5C6F82"; Layout.fillWidth: true }
                            Text { text: Math.round(backend.summary.unknown).toLocaleString(Qt.locale("en_US")); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#102A43" }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                Layout.preferredHeight: 118; color: "#EFF6FF"; radius: 12
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 22; anchors.rightMargin: 22; spacing: 15
                    Rectangle { width: 46; height: 46; radius: 12; color: "#DBE8FF"
                        AppIcon { anchors.centerIn: parent; iconName: "info"; iconSize: 23; color: "#1D4ED8" }
                    }
                    ColumnLayout { Layout.fillWidth: true; spacing: 5
                        Text { text: backend.isDemo ? "Illustrative demo data is active" : (backend.hasData ? "Ready for deeper analysis" : "Start with your customer dataset"); font.pixelSize: 15; font.weight: Font.DemiBold; color: "#1D4ED8" }
                        Text { text: backend.isDemo ? "These records are synthetic and only demonstrate the app. Import a real dataset for meaningful analysis." : (backend.hasData ? "These are observed historical figures, not ML predictions. Prediction Studio will be enabled after model validation." : "Import the IBM Telco churn dataset or your own customer CSV / Excel file to populate this workspace."); font.pixelSize: 11; wrapMode: Text.WordWrap; color: "#486581"; Layout.fillWidth: true }
                    }
                    UiButton { label: "Open data sources"; iconName: "folder"; primary: false; onClicked: root.navigateRequested(5) }
                }
            }
            Item { height: 18 }
        }
    }
}
