import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property int pageIndex: 2
    readonly property var content: ({
        2: {title:"Churn analytics",desc:"Compare segments, study churn drivers and inspect customer behavior.",phase:"STAGE 2",features:["Tenure and service distribution", "Segment-level churn comparisons", "Interactive breakdowns and drill-downs"]},
        3: {title:"Prediction studio",desc:"Generate calibrated customer-level churn probabilities after model validation.",phase:"STAGE 3",features:["Individual and batch scoring", "Risk thresholds and probability calibration", "Explainable customer predictions"]},
        4: {title:"Retention workspace",desc:"Turn model insights into trackable customer-retention actions.",phase:"STAGE 4",features:["Prioritized retention cases", "Intervention assignments and follow-ups", "Outcome tracking and evaluation"]},
        6: {title:"Model laboratory",desc:"Train, compare and monitor reproducible machine-learning experiments.",phase:"STAGE 3",features:["Logistic Regression and CatBoost", "Holdout evaluation and precision-recall", "Model versioning and explanations"]},
        7: {title:"Reports",desc:"Export clearly labeled business analyses and model evaluation summaries.",phase:"STAGE 5",features:["Churn analysis exports", "Model-performance documentation", "Retention operations summaries"]},
        8: {title:"Settings",desc:"Configure the desktop workspace and local application preferences.",phase:"STAGE 5",features:["Theme and appearance", "Data and model storage locations", "Backup and export preferences"]}
    })
    readonly property var pageInfo: content[pageIndex] || content[2]
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 34
        spacing: 15
        Text { text: root.pageInfo.title; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#102A43" }
        Text { text: root.pageInfo.desc; font.pixelSize: 13; color: "#7B8794" }
        Item { height: 25 }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 375; radius: 13
            color: "#FFFFFF"; border.color: "#E6ECF5"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 32; spacing: 16
                Rectangle { width: 84; height: 28; radius: 14; color: "#FFF4E8"
                    Text { anchors.centerIn: parent; text: root.pageInfo.phase; font.pixelSize: 11; font.weight: Font.Bold; color: "#C96A10" }
                }
                Text { text: "Planned for a later milestone"; font.pixelSize: 19; font.weight: Font.DemiBold; color: "#102A43" }
                Text { text: "This module is not active yet. We won't display simulated predictions or invented campaign results."; font.pixelSize: 12; color: "#7B8794"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#EDF2F7" }
                Text { text: "WHAT WE'LL BUILD"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1; color: "#98A6B3" }
                Repeater {
                    model: root.pageInfo.features
                    delegate: RowLayout { spacing: 11
                        Rectangle { width: 8; height: 8; radius: 4; color: "#F28C28" }
                        Text { text: modelData; font.pixelSize: 13; color: "#486581" }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
