import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item { id: root
    ScrollView { id: viewport; anchors.fill: parent; clip: true; contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout { width: viewport.availableWidth; spacing: 18
            Item { height: 8 }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Model laboratory'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Train a baseline and inspect honest holdout performance'; font.pixelSize: 13; color: '#7B8794' }
                }
                Item { Layout.fillWidth: true }
                UiButton { label: backend.modelTraining ? 'Training…' : 'Train baseline'; iconName: 'model'; disabled: backend.modelTraining || !backend.hasData; onClicked: backend.startTraining() }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 82; radius: 12; color: '#EFF6FF'; border.color: '#D7E5FF'
                RowLayout { anchors.fill: parent; anchors.margins: 20; spacing: 13
                    AppIcon { iconName: 'model'; iconSize: 23; color: '#2563EB' }
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: 'Logistic Regression · baseline classifier'; font.pixelSize: 14; font.weight: Font.DemiBold; color: '#1D4ED8' }
                        Text { text: backend.modelMessage; font.pixelSize: 11; color: '#486581'; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    }
                    BusyIndicator { running: backend.modelTraining; visible: running; Layout.preferredWidth: 32; Layout.preferredHeight: 32 }
                }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 14
                MetricCard { Layout.fillWidth: true; label: 'ROC-AUC'; value: backend.modelReady ? backend.modelMetrics.rocAuc.toFixed(3) : '—'; detail: '25% stratified holdout'; iconName: 'analytics'; accent: '#2563EB' }
                MetricCard { Layout.fillWidth: true; label: 'PR-AUC'; value: backend.modelReady ? backend.modelMetrics.prAuc.toFixed(3) : '—'; detail: 'Average precision'; iconName: 'analytics'; accent: '#F28C28' }
                MetricCard { Layout.fillWidth: true; label: 'Recall'; value: backend.modelReady ? (backend.modelMetrics.recall*100).toFixed(1) + '%' : '—'; detail: 'Positive class, threshold 0.50'; iconName: 'check'; accent: '#2563EB' }
                MetricCard { Layout.fillWidth: true; label: 'Precision'; value: backend.modelReady ? (backend.modelMetrics.precision*100).toFixed(1) + '%' : '—'; detail: 'Positive class, threshold 0.50'; iconName: 'model'; accent: '#F28C28' }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 15; Layout.alignment: Qt.AlignTop
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 440; Layout.preferredHeight: 360; Layout.alignment: Qt.AlignTop; color: '#FFFFFF'; radius: 14; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 15
                        Text { text: 'Experiment details'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
                        Repeater { model: [
                            {t:'Training examples',v:backend.modelReady ? backend.modelMetrics.trainRows : '—'},
                            {t:'Holdout examples',v:backend.modelReady ? backend.modelMetrics.testRows : '—'},
                            {t:'Allowed predictors',v:backend.modelReady ? backend.modelMetrics.features : '—'},
                            {t:'F1 at 0.50 threshold',v:backend.modelReady ? backend.modelMetrics.f1 : '—'},
                            {t:'True positive / False positive',v:backend.modelReady ? backend.modelMetrics.tp + ' / ' + backend.modelMetrics.fp : '—'},
                            {t:'True negative / False negative',v:backend.modelReady ? backend.modelMetrics.tn + ' / ' + backend.modelMetrics.fn : '—'}]
                            delegate: RowLayout { Layout.fillWidth: true
                                Text { text: modelData.t; font.pixelSize: 12; color: '#61748A'; Layout.fillWidth: true }
                                Text { text: String(modelData.v); font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43' }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Text { text: 'Random stratified holdout for cross-sectional demonstration, not a temporal validation.'; font.pixelSize: 11; color: '#7B8794'; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 600; Layout.preferredHeight: 530; Layout.alignment: Qt.AlignTop; color: '#FFFFFF'; radius: 14; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 12
                        Text { text: 'Strongest model coefficients'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { Layout.fillWidth: true; text: 'Associations in the fitted classifier, not explanations of what caused customers to churn.'; font.pixelSize: 11; color: '#7B8794'; wrapMode: Text.WordWrap }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
                        Repeater { model: backend.modelDrivers
                            delegate: ColumnLayout { Layout.fillWidth: true; spacing: 3
                                RowLayout { Layout.fillWidth: true
                                    Text { text: modelData.name; Layout.fillWidth: true; elide: Text.ElideRight; font.pixelSize: 11; color: '#243B53' }
                                    Text { text: modelData.effect; font.pixelSize: 10; color: modelData.effect.indexOf('Higher') === 0 ? '#C96A10' : '#1D4ED8' }
                                }
                                Rectangle { Layout.fillWidth: true; height: 5; radius: 3; color: '#EDF2F7'; clip: true
                                    Rectangle { width: parent.width*Math.min(1,modelData.weight/3); height: parent.height; radius: 3; color: modelData.effect.indexOf('Higher') === 0 ? '#F28C28' : '#2563EB' }
                                }
                            }
                        }
                        Text { visible: !backend.modelReady; text: 'Train the model to inspect learned feature weights.'; font.pixelSize: 12; color: '#7B8794' }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 91; radius: 12; color: '#FFF8F1'; border.color: '#FAD7B0'
                Text { anchors.fill: parent; anchors.margins: 18; text: 'Training excludes customer IDs and known post-outcome fields. Scores on training-set customers are exploratory; only the untouched holdout contributes to the evaluation above. Temporal validation and calibration are needed before deployment.'; font.pixelSize: 12; color: '#8A5A12'; wrapMode: Text.WordWrap; verticalAlignment: Text.AlignVCenter }
            }
            Item { height: 12 }
        }
    }
}
