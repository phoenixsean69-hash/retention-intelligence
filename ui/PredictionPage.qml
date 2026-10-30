import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal navigateRequested(int page)
    property var chosen: ({})
    property var hostWindow: null
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
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 82; radius: 12; color: '#FFFFFF'; border.color: '#E6ECF5'
                RowLayout { anchors.fill: parent; anchors.margins: 18; spacing: 13
                    Rectangle { width: 4; height: 36; radius: 2; color: '#F28C28' }
                    ColumnLayout { Layout.fillWidth: true; spacing: 5
                        Text { text: 'Likely churn scores'; font.pixelSize: 14; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { Layout.fillWidth: true; text: 'These percentages rank customers by modeled churn likelihood within the current dataset.'; color: '#61748A'; font.pixelSize: 11; wrapMode: Text.WordWrap }
                    }
                }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 14
                MetricCard { Layout.fillWidth: true; label: 'Customers scored'; iconName: 'people'; value: backend.modelReady ? backend.scoredCount.toString() : '—'; detail: 'Retained / unknown-label records'; accent: '#2563EB' }
                MetricCard { Layout.fillWidth: true; label: 'Likely to churn'; iconName: 'alert'; value: backend.modelReady ? backend.riskCount.toString() : '—'; detail: backend.modelReady ? (backend.riskPercentage + ' above threshold') : 'Threshold ' + backend.riskThreshold + '%'; accent: '#F28C28' }
                MetricCard { Layout.fillWidth: true; label: 'Attention threshold'; iconName: 'analytics'; value: backend.riskThreshold + '%'; detail: 'Editable in Settings'; accent: '#2563EB' }
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
                            Text { text: 'CUSTOMER'; font.pixelSize: 10; font.weight: Font.Bold; color: '#829AB1'; Layout.fillWidth: true }
                            Text { text: 'LIKELY CHURN'; font.pixelSize: 10; font.weight: Font.Bold; color: '#829AB1' }
                        }
                        ListView { id: ranked; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 1; model: backend.riskCustomers
                            delegate: Rectangle { width: ranked.width; height: 54; radius: 7; color: mouse.containsMouse ? '#F2F7FF' : (index % 2 ? '#F9FBFE' : '#FFFFFF')
                                RowLayout { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                    ColumnLayout { Layout.fillWidth: true; spacing: 1
                                        Text { text: modelData.customerName ? modelData.customerName : modelData.customerId; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#243B53'; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: modelData.customerId; font.pixelSize: 10; color: '#7B8794'; Layout.fillWidth: true; elide: Text.ElideRight }
                                    }
                                    Rectangle { width: 150; height: 8; radius: 4; color: '#E9EFF7'; clip: true
                                        Rectangle { width: parent.width * modelData.probability/100; height: parent.height; radius: 4; color: modelData.probability >= backend.riskThreshold ? '#F28C28' : '#2563EB' }
                                    }
                                    Text { text: modelData.probability.toFixed(1) + '%'; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43'; Layout.preferredWidth: 68; horizontalAlignment: Text.AlignRight }
                                }
                                MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { lookup.text = modelData.customerId; root.chosen = backend.customerRisk(modelData.customerId) } }
                            }
                        }
                        Text { visible: !backend.modelReady; Layout.fillWidth: true; wrapMode: Text.WordWrap; text: backend.modelMessage; color: '#7B8794'; font.pixelSize: 12 }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 370; Layout.preferredHeight: 400; Layout.alignment: Qt.AlignTop; radius: 14; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 22; spacing: 14
                        Text { text: 'Inspect a customer'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { text: 'Select a ranked record or enter a customer ID.'; font.pixelSize: 12; color: '#7B8794'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        TextField { id: lookup; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: 'Customer ID'; enabled: backend.modelReady }
                        UiButton { label: 'Inspect score'; primary: true; disabled: !backend.modelReady; iconName: 'search'; onClicked: root.chosen = backend.customerRisk(lookup.text) }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#E9EFF6' }
                        Text { text: root.chosen.customerName ? root.chosen.customerName : (root.chosen.customerId ? root.chosen.customerId : 'No customer selected'); font.pixelSize: 15; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { text: root.chosen.customerId ? root.chosen.customerId : ''; font.pixelSize: 11; color: '#7B8794' }
                        Text { text: root.chosen.probability !== undefined ? root.chosen.probability.toFixed(1) + '%' : '—'; font.pixelSize: 36; font.weight: Font.DemiBold; color: root.chosen.probability >= backend.riskThreshold ? '#C96A10' : '#1D4ED8' }
                        Text { Layout.fillWidth: true; text: root.chosen.customerId ? 'Percentage of likely churning within the current scoring model.' : 'Select a record to see its estimated likelihood.'; color: '#7B8794'; font.pixelSize: 11; wrapMode: Text.WordWrap }
                        Item { Layout.fillHeight: true }
                        UiButton {
    label: 'Open retention workspace'
    primary: false
    onClicked: {
        if (root.hostWindow)
            root.hostWindow.navigate(4)
        else
            root.navigateRequested(4)
    }
}
                    }
                }
            }
            Item { height: 12 }
        }
    }
}
