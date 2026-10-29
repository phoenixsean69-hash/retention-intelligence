import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item { id: root
    ScrollView { id: viewport; anchors.fill: parent; clip: true; contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout { width: viewport.availableWidth; spacing: 18
            Item { height: 8 }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Settings'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Local preferences for the analytics workspace'; font.pixelSize: 13; color: '#7B8794' }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 320; color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 20
                    Text { text: 'Analytics preferences'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                    Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
                    RowLayout { Layout.fillWidth: true
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: 'Risk attention threshold'; font.pixelSize: 13; font.weight: Font.DemiBold; color: '#243B53' }
                            Text { text: 'Determines which customers appear above the high-risk cutoff. Does not retrain the model.'; font.pixelSize: 11; color: '#7B8794'; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                        Slider { id: threshold; from: 10; to: 95; stepSize: 5; value: backend.riskThreshold; Layout.preferredWidth: 200; onMoved: backend.setRiskThreshold(Math.round(value)) }
                        Text { text: backend.riskThreshold + '%'; font.pixelSize: 15; font.weight: Font.Bold; color: '#2563EB'; Layout.preferredWidth: 48; horizontalAlignment: Text.AlignRight }
                    }
                    RowLayout { Layout.fillWidth: true
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: 'Financial display label'; font.pixelSize: 13; font.weight: Font.DemiBold; color: '#243B53' }
                            Text { text: 'Presentation only. The app does not convert currencies or infer the dataset currency.'; font.pixelSize: 11; color: '#7B8794'; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                        ComboBox { id: money; Layout.preferredWidth: 165; Layout.preferredHeight: 42; model: ['Source units','USD','ZIG','EUR','GBP']; Component.onCompleted: currentIndex = Math.max(0,['Source units','USD','ZIG','EUR','GBP'].indexOf(backend.currencyLabel)); onActivated: backend.setCurrencyLabel(currentText) }
                    }
                    RowLayout { Layout.fillWidth: true
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: 'Compact customer rows'; font.pixelSize: 13; font.weight: Font.DemiBold; color: '#243B53' }
                            Text { text: 'Reduce the spacing in customer tables.'; font.pixelSize: 11; color: '#7B8794' }
                        }
                        Switch { checked: backend.compactRows; onToggled: backend.setCompactRows(checked) }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 164; color: '#FFFFFF'; border.color: '#E6ECF5'; radius: 14
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 11
                    Text { text: 'Privacy & storage'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                    Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
                    Text { text: 'Imported data, application preferences and retention case logs stay on this computer in the local app-data directory.'; font.pixelSize: 12; color: '#486581'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    Text { text: 'Risk models are held in memory for this version, and must be retrained after restarting the application.'; font.pixelSize: 12; color: '#7B8794'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                }
            }
            Text { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; text: backend.noticeText; font.pixelSize: 12; color: '#486581' }
            Item { height: 12 }
        }
    }
}
