import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    ScrollView {
        id: viewport
        anchors.fill: parent; clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout {
            width: viewport.availableWidth; spacing: 22
            Item { height: 8 }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 6
                    Text { text: "Data sources"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#102A43" }
                    Text { text: "Manage the source data powering your customer intelligence"; font.pixelSize: 13; color: "#7B8794" }
                }
                Item { Layout.fillWidth: true }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 243
                radius: 12; color: "#FFFFFF"; border.color: "#E6ECF5"
                RowLayout { anchors.fill: parent; anchors.margins: 28; spacing: 24
                    Rectangle { Layout.preferredWidth: 76; Layout.preferredHeight: 76; radius: 20; color: "#EFF6FF"
                        AppIcon { anchors.centerIn: parent; iconName: "folder"; iconSize: 34; color: "#2563EB" }
                    }
                    ColumnLayout { Layout.fillWidth: true; spacing: 9
                        Text { text: "Import a customer dataset"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#102A43" }
                        Text { text: "Load CSV, XLSX or XLSM files from your computer. Data remains on this device."; font.pixelSize: 12; color: "#7B8794"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        Item { height: 5 }
                        RowLayout { spacing: 10
                            UiButton { label: "Choose data file"; iconName: "import"; disabled: backend.modelTraining; onClicked: backend.openDataset() }
                            Text { text: "CSV · Excel"; font.pixelSize: 11; color: "#98A6B3" }
                        }
                    }
                }
            }
            Rectangle {
                visible: backend.errorText.length > 0
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 64
                radius: 10; color: "#FFF4E8"; border.color: "#FAD7B0"
                Text { anchors.fill: parent; anchors.margins: 15; text: backend.errorText; font.pixelSize: 12; color: "#C96A10"; wrapMode: Text.WordWrap; verticalAlignment: Text.AlignVCenter }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 258
                radius: 12; color: "#FFFFFF"; border.color: "#E6ECF5"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 14
                    RowLayout { Layout.fillWidth: true
                        Text { text: "Current dataset"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#102A43" }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: loadedText.implicitWidth + 22; height: 25; radius: 13; color: backend.hasData ? "#EFF6FF" : "#F4F7FB"
                            Text { id: loadedText; anchors.centerIn: parent; text: backend.hasData ? "LOADED" : "NOT LOADED"; font.pixelSize: 10; font.weight: Font.DemiBold; color: backend.hasData ? "#1D4ED8" : "#7B8794" }
                        }
                    }
                    Text { text: backend.dataName; font.pixelSize: 14; font.weight: Font.Medium; color: "#486581"; elide: Text.ElideRight; Layout.fillWidth: true }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Repeater { model: [{label:"ROWS",value:backend.summary.total},{label:"COLUMNS",value:backend.summary.columns},{label:"LABELED OUTCOMES",value:backend.summary.known}]
                            delegate: Rectangle { Layout.fillWidth: true; height: 69; color: "#F8FAFD"; radius: 8
                                ColumnLayout { anchors.centerIn: parent; spacing: 5
                                    Text { text: Math.round(Number(modelData.value) || 0).toLocaleString(Qt.locale("en_US")); font.pixelSize: 20; font.weight: Font.DemiBold; color: "#102A43"; Layout.alignment: Qt.AlignHCenter }
                                    Text { text: modelData.label; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#9AA5B1"; Layout.alignment: Qt.AlignHCenter }
                                }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout { Layout.fillWidth: true
                        Text { text: "A working copy is stored in your local app-data folder."; font.pixelSize: 11; color: "#7B8794"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        UiButton { label: "Remove local dataset"; iconName: "alert"; primary: false; disabled: !backend.hasData; onClicked: removeDialog.open() }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 137
                radius: 12; color: "#FFF8F1"; border.color: "#FDE4C5"; border.width: 1
                ColumnLayout { anchors.fill: parent; anchors.margins: 22; spacing: 6
                    Text { text: "Supported schema"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#C96A10" }
                    Text { text: "Customer ID is required. Churn, Contract, tenure, MonthlyCharges and TotalCharges are recognized automatically if present. Missing churn labels are excluded from observed churn-rate calculations."; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pixelSize: 12; color: "#8A5A12" }
                }
            }
            Item { height: 10 }
        }
    }
    Dialog {
        id: removeDialog
        title: "Remove local dataset?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        width: 420
        onAccepted: backend.clearDataset()
        contentItem: Text { text: "This removes the app's stored copy and clears the dashboard. Your original source file is not deleted."; wrapMode: Text.WordWrap; font.pixelSize: 13; color: "#243B53"; padding: 12 }
    }
}
