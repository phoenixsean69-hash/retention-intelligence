import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var activeRows: dimension.currentIndex === 0 ? backend.contractSegments : (dimension.currentIndex === 1 ? backend.tenureSegments : (dimension.currentIndex === 2 ? backend.chargeSegments : backend.paymentSegments))
    ScrollView {
        id: viewport; anchors.fill: parent; clip: true
        contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout {
            width: viewport.availableWidth; spacing: 19
            Item { height: 8 }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Churn analytics'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Explore observed outcomes across customer segments'; font.pixelSize: 13; color: '#7B8794' }
                }
                Item { Layout.fillWidth: true }
                UiButton { label: 'Export segments'; iconName: 'download'; primary: false; disabled: !backend.hasData; onClicked: backend.exportSegmentsCsv() }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 14
                Rectangle {
                    Layout.fillWidth: true; height: 66; radius: 12; color: '#EFF6FF'; border.color: '#D7E5FF'
                    RowLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                        AppIcon { iconName: 'analytics'; iconSize: 22; color: '#2563EB' }
                        ColumnLayout { Layout.fillWidth: true; spacing: 3
                            Text { text: backend.hasData ? backend.churnRate + ' observed churn rate' : 'No dataset loaded'; font.pixelSize: 15; font.weight: Font.DemiBold; color: '#1D4ED8' }
                            Text { text: 'Historical snapshot only — segment relationships are not causal explanations.'; font.pixelSize: 11; color: '#486581'; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }
                }
                Rectangle {
                    width: 214; height: 66; radius: 12; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 9; spacing: 3
                        Text { text: 'SEGMENT BY'; font.pixelSize: 10; font.weight: Font.DemiBold; color: '#7B8794' }
                        ComboBox { id: dimension; Layout.fillWidth: true; Layout.preferredHeight: 31; model: ['Contract','Tenure','Monthly charges','Payment method']; enabled: backend.hasData }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 16; Layout.alignment: Qt.AlignTop
                SegmentChart {
                    Layout.fillWidth: true; Layout.preferredWidth: 680; Layout.alignment: Qt.AlignTop
                    heading: 'Churn by ' + dimension.currentText.toLowerCase()
                    subtitle: 'Observed churn share. Select a bar to highlight it.'
                    rows: root.activeRows
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredWidth: 350; Layout.preferredHeight: 280; Layout.alignment: Qt.AlignTop
                    color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                    ColumnLayout { anchors.fill: parent; anchors.margins: 23; spacing: 12
                        Text { text: 'Dataset coverage'; font.pixelSize: 16; font.weight: Font.DemiBold; color: '#102A43' }
                        Rectangle { height: 1; Layout.fillWidth: true; color: '#EDF2F7' }
                        Repeater {
                            model: [ {t:'Customer rows',v:backend.dataQuality.rows}, {t:'Known churn labels',v:backend.summary.known}, {t:'Missing labels',v:backend.dataQuality.unlabeled}, {t:'Duplicate IDs',v:backend.dataQuality.duplicateIds} ]
                            delegate: RowLayout { Layout.fillWidth: true; spacing: 6
                                Text { text: modelData.t; font.pixelSize: 12; color: '#61748A'; Layout.fillWidth: true }
                                Text { text: Math.round(modelData.v).toString(); font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43' }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Text { text: 'Groups with no known outcomes are not shown. Small groups may produce unstable percentages.'; font.pixelSize: 11; color: '#7B8794'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 96; radius: 12; color: '#FFF8F1'; border.color: '#FAD7B0'
                RowLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    AppIcon { iconName: 'info'; iconSize: 23; color: '#C96A10' }
                    Text { Layout.fillWidth: true; text: 'No time-series trends are drawn from a single snapshot. Tenure and monthly-charge bands are descriptive groups in the dataset’s original units.'; wrapMode: Text.WordWrap; font.pixelSize: 12; color: '#8A5A12' }
                }
            }
            Item { height: 14 }
        }
    }
}
