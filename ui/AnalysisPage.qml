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
                    Layout.fillWidth: true; height: 66; radius: 12; color: '#FFFFFF'; border.color: '#E6ECF5'
                    RowLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                        Rectangle { width: 4; height: 32; radius: 2; color: '#2563EB' }
                        ColumnLayout { Layout.fillWidth: true; spacing: 3
                            Text { text: backend.hasData ? backend.churnRate + ' observed churn rate' : 'No dataset loaded'; font.pixelSize: 15; font.weight: Font.DemiBold; color: '#102A43' }
                            Text { text: 'Segment relationships describe the snapshot; they do not by themselves prove the cause of churn.'; font.pixelSize: 11; color: '#486581'; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }
                }
                Rectangle {
                    width: 214; height: 66; radius: 12; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 9; spacing: 3
                        Text { text: 'SEGMENT BY'; font.pixelSize: 10; font.weight: Font.DemiBold; color: '#7B8794' }
                        ComboBox { id: dimension; Layout.fillWidth: true; Layout.preferredHeight: 31; model: ['Contract', 'Tenure', 'Monthly charges', 'Payment method']; enabled: backend.hasData }
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
                ColumnLayout {
                    Layout.fillWidth: true; Layout.preferredWidth: 350; Layout.alignment: Qt.AlignTop; spacing: 16
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 260
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
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 330
                        color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                        ColumnLayout { anchors.fill: parent; anchors.margins: 23; spacing: 12
                            Text { text: 'Recommendations to prevent churning'; font.pixelSize: 16; font.weight: Font.DemiBold; color: '#102A43' }
                            Rectangle { height: 1; Layout.fillWidth: true; color: '#EDF2F7' }
                            Repeater {
                                model: backend.preventionRecommendations
                                delegate: Rectangle {
                                    Layout.fillWidth: true; color: '#F9FBFF'; border.color: '#E6ECF5'; radius: 10; implicitHeight: 72
                                    ColumnLayout { anchors.fill: parent; anchors.margins: 12; spacing: 4
                                        RowLayout { Layout.fillWidth: true
                                            Text { text: modelData.title; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                            Text { text: modelData.priority; font.pixelSize: 10; color: modelData.priority === 'High priority' ? '#C96A10' : '#2563EB' }
                                        }
                                        Text { text: modelData.why; font.pixelSize: 11; color: '#486581'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                        Text { text: modelData.action; font.pixelSize: 11; color: '#61748A'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Item { height: 14 }
        }
    }
}
