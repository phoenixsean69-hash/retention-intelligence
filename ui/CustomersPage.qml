import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
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
                ColumnLayout { spacing: 6
                    Text { text: "Customer explorer"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#102A43" }
                    Text { text: "Explore customers, observed outcomes, and likely churn"; font.pixelSize: 13; color: "#7B8794" }
                }
                Item { Layout.fillWidth: true }
                UiButton { label: "Export filtered"; iconName: "download"; primary: false; disabled: !backend.hasData; onClicked: backend.exportCustomers() }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                implicitHeight: 705; radius: 12; color: "#FFFFFF"; border.color: "#E6ECF5"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 21; spacing: 14
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 41; radius: 8; color: "#F8FAFD"; border.color: "#D9E2EC"
                            AppIcon { iconName: "search"; iconSize: 16; color: "#7B8794"; anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter }
                            TextField {
                                id: search
                                anchors.fill: parent; anchors.leftMargin: 41; anchors.rightMargin: 10
                                background: Item { }
                                placeholderText: "Search customer name or ID..."
                                placeholderTextColor: "#9AA5B1"
                                color: "#243B53"
                                font.pixelSize: 12
                                enabled: backend.hasData
                                onTextChanged: backend.searchCustomers(text)
                            }
                        }
                        ComboBox {
                            id: outcomeFilter
                            Layout.preferredWidth: 172; Layout.preferredHeight: 41
                            model: ["All customers", "Retained", "Churned"]
                            enabled: backend.hasData
                            onActivated: backend.filterCustomers(currentText)
                        }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 18
                        Text { text: Math.round(backend.filteredCount).toString() + " matching records"; font.pixelSize: 11; color: "#7B8794" }
                        Text { text: backend.modelReady ? ("Likely churning: " + backend.riskCount + " customers (" + backend.riskPercentage + ")") : "Train a model to show likely churn percentages"; font.pixelSize: 11; color: "#7B8794" }
                        Item { Layout.fillWidth: true }
                        Text { text: "Search covers customer IDs and names"; font.pixelSize: 10; color: "#98A6B3" }
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 43; radius: 7; color: "#F4F7FB"
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 9
                            Repeater { model: [{t:"NAME", w:1.5},{t:"CUSTOMER ID", w:1.1},{t:"CONTRACT", w:1.2},{t:"TENURE", w:0.7},{t:"MONTHLY", w:0.9},{t:"LIKELY CHURN", w:0.8},{t:"OUTCOME", w:0.8}]
                                delegate: Text { Layout.fillWidth: true; Layout.preferredWidth: modelData.w * 100; text: modelData.t; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 0.6; color: "#7B8794"; elide: Text.ElideRight }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        visible: backend.visibleCustomers.length > 0
                        Repeater {
                            model: backend.visibleCustomers
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: backend.compactRows ? 38 : 46; color: index % 2 === 0 ? "#FFFFFF" : "#F9FBFF"
                                RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 9
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 160; text: modelData.customerName; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#102A43"; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 120; text: modelData.customerId; font.pixelSize: 12; color: "#486581"; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 130; text: modelData.contract; font.pixelSize: 12; color: "#486581"; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 70; text: modelData.tenure; font.pixelSize: 12; color: "#486581"; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 100; text: modelData.monthly; font.pixelSize: 12; color: "#486581"; elide: Text.ElideRight }
                                    Text { Layout.fillWidth: true; Layout.preferredWidth: 90; text: modelData.riskText; font.pixelSize: 12; font.weight: Font.DemiBold; color: (modelData.risk !== null && modelData.risk >= backend.riskThreshold) ? "#C96A10" : "#1D4ED8"; elide: Text.ElideRight }
                                    Item { Layout.fillWidth: true; Layout.preferredWidth: 90; height: 25
                                        Rectangle { anchors.verticalCenter: parent.verticalCenter; height: 24; width: badgeText.implicitWidth + 18; radius: 12
                                            color: modelData.status === "Churned" ? "#FFF4E8" : (modelData.status === "Retained" ? "#EFF6FF" : "#F3F6FA")
                                            Text { id: badgeText; anchors.centerIn: parent; text: modelData.status; font.pixelSize: 11; font.weight: Font.Medium; color: modelData.status === "Churned" ? "#C96A10" : (modelData.status === "Retained" ? "#1D4ED8" : "#7B8794") }
                                        }
                                    }
                                }
                                Rectangle { anchors.bottom: parent.bottom; height: 1; width: parent.width; color: "#EDF2F7" }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: backend.visibleCustomers.length === 0
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
                        Item { Layout.fillHeight: true }
                        Text { Layout.alignment: Qt.AlignHCenter; text: backend.hasData ? "No customers match your filters" : "No customer data yet"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#243B53" }
                        Text { Layout.alignment: Qt.AlignHCenter; text: backend.hasData ? "Try another customer name, customer ID, or outcome filter." : "Import a dataset from Data Sources to populate this table."; font.pixelSize: 12; color: "#7B8794" }
                        Item { Layout.fillHeight: true }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Text { text: backend.hasData ? "Page " + backend.pageNumber + " of " + backend.pageCount : "No data loaded"; font.pixelSize: 11; color: "#7B8794" }
                        Item { Layout.fillWidth: true }
                        UiButton { label: "Previous"; iconName: "previous"; primary: false; buttonHeight: 34; disabled: !backend.hasData || backend.pageNumber <= 1; onClicked: backend.movePage(-1) }
                        UiButton { label: "Next"; iconName: "next"; primary: false; buttonHeight: 34; disabled: !backend.hasData || backend.pageNumber >= backend.pageCount; onClicked: backend.movePage(1) }
                    }
                }
            }
            Item { height: 15 }
        }
    }
}
