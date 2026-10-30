import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var visuals: backend.overviewVisuals
    ScrollView {
        id: viewport
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout {
            width: viewport.availableWidth
            spacing: 20
            Item { height: 8 }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout {
                    spacing: 5
                    Text { text: "Customer overview"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#102A43" }
                    Text { text: "Customer composition, churn exposure and risk intelligence"; font.pixelSize: 13; color: "#788B9E" }
                }
                Item { Layout.fillWidth: true }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 12
                OverviewKpiCard {
                    Layout.fillWidth: true; title: "Total customers"; value: backend.totalCustomers
                    detail: "Current dataset"; mode: "ring"; accent: "#2563EB"
                    firstPct: root.visuals.retainedPct; secondPct: root.visuals.churnedPct
                    available: backend.hasData
                }
                OverviewKpiCard {
                    Layout.fillWidth: true; title: "Observed churn"; value: backend.churnRate
                    detail: "Known churn outcomes"; mode: "ring"; accent: "#F28C28"
                    // Orange segment is the observed churn share, blue segment is retained.
                    firstPct: backend.hasData ? 100 - root.visuals.observedPct : 0
                    secondPct: root.visuals.observedPct
                    available: backend.hasData && backend.summary.known > 0
                }
                OverviewKpiCard {
                    Layout.fillWidth: true; title: "At-risk customers"; value: backend.modelReady ? backend.riskCount.toString() : "—"
                    detail: backend.modelReady ? "Above " + backend.riskThreshold + "% cutoff" : "Train a model in Model Lab"
                    mode: "columns"; accent: "#F28C28"
                    firstPct: root.visuals.atRiskPct
                    available: backend.modelReady && backend.scoredCount > 0
                }
                OverviewKpiCard {
                    Layout.fillWidth: true; title: "Churned monthly charges"; value: backend.monthlyAssociated
                    detail: backend.currencyLabel === "Source units" ? "Charges on churned accounts" : backend.currencyLabel + " · churned accounts"
                    mode: "charges"; accent: "#2563EB"
                    firstPct: root.visuals.churnChargePct
                    available: backend.hasData && root.visuals.knownCharges > 0
                }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 15; Layout.alignment: Qt.AlignTop
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredWidth: 690; Layout.preferredHeight: 365
                    color: "#FFFFFF"; border.color: "#E0E7F0"; radius: 8
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 13
                        Text { text: "Churn by contract"; font.pixelSize: 17; font.weight: Font.DemiBold; color: "#142E49" }
                        Text { text: "Observed churn rate by contract length"; font.pixelSize: 11; color: "#798B9D" }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                        Repeater {
                            model: backend.contractStats
                            delegate: ColumnLayout {
                                Layout.fillWidth: true; spacing: 6
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: modelData.name; font.pixelSize: 12; color: "#314960"; Layout.fillWidth: true }
                                    Text { text: modelData.rate.toFixed(1) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#142E49" }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 12; radius: 5; color: "#EDF2F7"; clip: true
                                    Rectangle { width: parent.width * Math.max(0, Math.min(100, modelData.rate)) / 100; height: parent.height; radius: 5; color: index === 0 ? "#F28C28" : "#2563EB" }
                                }
                                Text { text: Math.round(modelData.count).toString() + " customers"; color: "#829AB1"; font.pixelSize: 10 }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredWidth: 440; Layout.preferredHeight: 365
                    color: "#FFFFFF"; border.color: "#E0E7F0"; radius: 8
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 13
                        Text { text: "Outcome distribution"; font.pixelSize: 17; font.weight: Font.DemiBold; color: "#142E49" }
                        Text { text: "Customer records with known outcomes"; font.pixelSize: 11; color: "#798B9D" }
                        Text { text: backend.summary.known.toString(); font.pixelSize: 32; font.weight: Font.DemiBold; color: "#142E49" }
                        Text { text: "Labeled customer records"; font.pixelSize: 10; color: "#8798AA" }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 0
                            Rectangle { Layout.fillWidth: true; Layout.preferredWidth: backend.summary.known ? backend.summary.retained : 1; height: 16; radius: 3; color: "#2563EB" }
                            Rectangle { Layout.fillWidth: true; Layout.preferredWidth: backend.summary.known ? backend.summary.churned : 1; height: 16; radius: 3; color: "#F28C28" }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 8; height: 8; radius: 2; color: "#2563EB" }
                            Text { text: "Retained"; Layout.fillWidth: true; font.pixelSize: 11; color: "#5C6F82" }
                            Text { text: backend.summary.retained.toString(); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#142E49" }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 8; height: 8; radius: 2; color: "#F28C28" }
                            Text { text: "Churned"; Layout.fillWidth: true; font.pixelSize: 11; color: "#5C6F82" }
                            Text { text: backend.summary.churned.toString(); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#142E49" }
                        }
                        RowLayout { Layout.fillWidth: true
                            Rectangle { width: 8; height: 8; radius: 2; color: "#BCCCDC" }
                            Text { text: "Unknown"; Layout.fillWidth: true; font.pixelSize: 11; color: "#5C6F82" }
                            Text { text: backend.summary.unknown.toString(); font.pixelSize: 12; font.weight: Font.DemiBold; color: "#142E49" }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 15; Layout.alignment: Qt.AlignTop
                OverviewSegmentPanel {
                    Layout.fillWidth: true; Layout.preferredWidth: 550
                    heading: "Churn by tenure"
                    subtitle: "Which length-of-stay groups show higher observed churn?"
                    rows: backend.tenureSegments
                    accent: "#2563EB"
                }
                OverviewSegmentPanel {
                    Layout.fillWidth: true; Layout.preferredWidth: 550
                    heading: "Churn by payment method"
                    subtitle: "Observed churn percentages across payment groups"
                    rows: backend.paymentSegments
                    accent: "#2563EB"
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                Layout.preferredHeight: 260; color: "#FFFFFF"; border.color: "#E0E7F0"; radius: 8
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    RowLayout { Layout.fillWidth: true
                        Text { text: "Model risk distribution"; font.pixelSize: 17; font.weight: Font.DemiBold; color: "#142E49"; Layout.fillWidth: true }
                        Text { text: backend.modelReady ? backend.scoredCount + " customers scored" : "Model not trained"; font.pixelSize: 11; color: "#798B9D" }
                    }
                    Text { text: "Distribution of estimated customer risk across four score bands"; font.pixelSize: 11; color: "#798B9D" }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                    RowLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 25
                        Repeater {
                            model: root.visuals.riskBands || []
                            delegate: ColumnLayout {
                                Layout.fillWidth: true; spacing: 7
                                Text { Layout.fillWidth: true; text: modelData.count.toString(); font.pixelSize: 18; font.weight: Font.DemiBold; color: "#142E49"; horizontalAlignment: Text.AlignHCenter }
                                Rectangle {
                                    Layout.fillWidth: true; height: 26; color: "#EDF2F7"; radius: 4; clip: true
                                    Rectangle {
                                        width: parent.width * (backend.scoredCount ? modelData.count / backend.scoredCount : 0)
                                        height: parent.height; radius: 4; color: index >= 2 ? "#F28C28" : "#2563EB"
                                    }
                                }
                                Text { Layout.fillWidth: true; text: modelData.label; font.pixelSize: 11; color: "#657990"; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                        Text {
                            visible: !backend.modelReady; Layout.fillWidth: true; text: "Train a model in Model Lab to display the risk distribution."
                            font.pixelSize: 12; color: "#7B8794"
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            Item { height: 16 }
        }
    }
}
