import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item { id: root
    ScrollView { id: viewport; anchors.fill: parent; clip: true; contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout { width: viewport.availableWidth; spacing: 18
            Item { height: 8 }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Reports & exports'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Export evidence-backed summaries for further analysis'; font.pixelSize: 13; color: '#7B8794' }
                }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 15; Layout.alignment: Qt.AlignTop
                Repeater { model: [
                    {t:'Churn analysis report',fmt:'PDF',detail:'Observed churn, segment rates, data quality and optional holdout evaluation.',kind:0,icon:'reports'},
                    {t:'Segment comparisons',fmt:'CSV',detail:'Observed segment counts and churn rates by contract, tenure, charges and payment method.',kind:1,icon:'analytics'},
                    {t:'Exploratory risk ranking',fmt:'CSV',detail:'Customer-level model scores with version and limitation labels.',kind:2,icon:'prediction'}]
                    delegate: Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 350; Layout.preferredHeight: 285; Layout.alignment: Qt.AlignTop; color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                        ColumnLayout { anchors.fill: parent; anchors.margins: 23; spacing: 13
                            Rectangle { width: 50; height: 50; radius: 13; color: modelData.kind === 2 ? '#FFF4E8' : '#EFF6FF'
                                AppIcon { anchors.centerIn: parent; iconName: modelData.icon; iconSize: 24; color: modelData.kind === 2 ? '#F28C28' : '#2563EB' }
                            }
                            Text { text: modelData.t; Layout.fillWidth: true; font.pixelSize: 16; font.weight: Font.DemiBold; color: '#102A43'; wrapMode: Text.WordWrap }
                            Text { text: modelData.detail; Layout.fillWidth: true; font.pixelSize: 12; color: '#7B8794'; wrapMode: Text.WordWrap }
                            Item { Layout.fillHeight: true }
                            UiButton { label: 'Export ' + modelData.fmt; iconName: 'download'; disabled: modelData.kind === 2 ? !backend.modelReady : !backend.hasData; onClicked: { if(modelData.kind === 0) backend.exportAnalysisPdf(); else if (modelData.kind === 1) backend.exportSegmentsCsv(); else backend.exportRiskCsv() } }
                        }
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 165; color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                ColumnLayout { anchors.fill: parent; anchors.margins: 23; spacing: 12
                    Text { text: 'Report context'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Dataset: ' + backend.dataName; font.pixelSize: 12; color: '#486581' }
                    Text { text: 'Model version: ' + backend.modelVersion; font.pixelSize: 12; color: '#486581' }
                    Text { text: 'Reports do not invent historical trends, retention savings, or forward-looking prediction horizons.'; font.pixelSize: 12; color: '#7B8794'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                }
            }
            Text { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; text: backend.noticeText; font.pixelSize: 12; color: '#486581'; wrapMode: Text.WordWrap }
            Item { height: 15 }
        }
    }
}
