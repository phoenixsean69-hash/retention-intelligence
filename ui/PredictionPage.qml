import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal navigateRequested(int page)
    property var chosen: ({})
    ScrollView { id: viewport; anchors.fill: parent; clip: true; contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout { width: viewport.availableWidth; spacing: 18
            Item { height: 8 }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Prediction studio'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Inspect model-generated customer risk scores'; font.pixelSize: 13; color: '#7B8794' }
                }
                Item { Layout.fillWidth: true }
                UiButton { label: 'Export scores'; iconName: 'download'; primary: false; disabled: !backend.modelReady; onClicked: backend.exportRiskCsv() }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 84; radius: 12; color: '#FFF8F1'; border.color: '#FAD7B0'
                RowLayout { anchors.fill: parent; anchors.margins: 18; spacing: 13
                    AppIcon { iconName: 'alert'; iconSize: 23; color: '#C96A10' }
                    ColumnLayout { Layout.fillWidth: true; spacing: 5
                        Text { text: 'Exploratory risk estimates — not 30-day forecasts'; font.pixelSize: 14; font.weight: Font.DemiBold; color: '#8A5A12' }
                        Text { Layout.fillWidth: true; text: 'Scores come from a model trained on this same snapshot. Holdout metrics are separate; these ranks are not prospectively validated or proof of retention impact.'; color: '#8A5A12'; font.pixelSize: 11; wrapMode: Text.WordWrap }
                    }
                }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 14
                MetricCard { Layout.fillWidth: true; label: 'Customers scored'; iconName: 'people'; value: backend.modelReady ? backend.scoredCount.toString() : '—'; detail: 'Retained / unknown-label records'; accent: '#2563EB' }
                MetricCard { Layout.fillWidth: true; label: 'Above risk threshold'; iconName: 'alert'; value: backend.modelReady ? backend.riskCount.toString() : '—'; detail: 'Threshold ' + backend.riskThreshold + '%'; accent: '#F28C28' }
                MetricCard { Layout.fillWidth: true; label: 'Model version'; iconName: 'model'; value: backend.modelReady ? backend.modelVersion : 'Not trained'; detail: 'Retrospective classifier'; accent: '#1D4ED8' }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 16; Layout.alignment: Qt.AlignTop
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 690; Layout.preferredHeight: 570; Layout.alignment: Qt.AlignTop; radius: 14; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 22; spacing: 13
                        RowLayout { Layout.fillWidth: true
                            Text { text: 'Customer risk ranking'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43'; Layout.fillWidth: true }
                            Text { text: 'Top 60'; font.pixelSize: 11; color: '#7B8794' }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#E9EFF6' }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            Text { text: 'CUSTOMER ID'; font.pixelSize: 10; font.weight: Font.Bold; color: '#829AB1'; Layout.fillWidth: true }
                            Text { text: 'RISK SCORE'; font.pixelSize: 10; font.weight: Font.Bold; color: '#829AB1' }
                        }
                        ListView { id: ranked; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 1; model: backend.riskCustomers
                            delegate: Rectangle { width: ranked.width; height: 45; radius: 7; color: mouse.containsMouse ? '#F2F7FF' : (index % 2 ? '#F9FBFE' : '#FFFFFF')
                                RowLayout { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                                    Text { text: modelData.customerId; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#243B53'; Layout.fillWidth: true }
                                    Rectangle { width: 150; height: 8; radius: 4; color: '#E9EFF7'; clip: true
                                        Rectangle { width: parent.width * modelData.probability/100; height: parent.height; radius: 4; color: modelData.probability >= backend.riskThreshold ? '#F28C28' : '#2563EB' }
                                    }
                                    Text { text: modelData.probability.toFixed(1) + '%'; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43'; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                                }
                                MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { lookup.text = modelData.customerId; root.chosen = backend.customerRisk(modelData.customerId) } }
                            }
                        }
                        Text { visible: !backend.modelReady; Layout.fillWidth: true; wrapMode: Text.WordWrap; text: backend.modelMessage; color: '#7B8794'; font.pixelSize: 12 }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 370; Layout.preferredHeight: 380; Layout.alignment: Qt.AlignTop; radius: 14; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 22; spacing: 14
                        Text { text: 'Inspect a customer'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { text: 'Select a ranked record or enter a customer ID.'; font.pixelSize: 12; color: '#7B8794'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        TextField { id: lookup; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: 'Customer ID'; enabled: backend.modelReady }
                        UiButton { label: 'Inspect score'; primary: true; disabled: !backend.modelReady; iconName: 'search'; onClicked: root.chosen = backend.customerRisk(lookup.text) }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#E9EFF6' }
                        Text { text: root.chosen.customerId ? root.chosen.customerId : 'No customer selected'; font.pixelSize: 13; color: '#486581' }
                        Text { text: root.chosen.probability !== undefined ? root.chosen.probability.toFixed(1) + '%' : '—'; font.pixelSize: 36; font.weight: Font.DemiBold; color: root.chosen.probability >= backend.riskThreshold ? '#C96A10' : '#1D4ED8' }
                        Text { Layout.fillWidth: true; text: root.chosen.customerId ? 'Model-estimated historical churn propensity. Not an action-effect estimate.' : 'Select a record to see its estimated risk.'; color: '#7B8794'; font.pixelSize: 11; wrapMode: Text.WordWrap }
                        Item { Layout.fillHeight: true }
                        UiButton { label: 'Open retention workspace'; iconName: 'retention'; primary: false; onClicked: root.navigateRequested(4) }
                    }
                }
            }
            Item { height: 12 }
        }
    }
}
