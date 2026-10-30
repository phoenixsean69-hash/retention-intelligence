import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    ScrollView { id: viewport; anchors.fill: parent; clip: true; contentWidth: availableWidth; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout { width: viewport.availableWidth; spacing: 18
            Item { height: 8 }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30
                ColumnLayout { spacing: 5
                    Text { text: 'Retention workspace'; font.pixelSize: 26; font.weight: Font.DemiBold; color: '#102A43' }
                    Text { text: 'Record, assign and review customer follow-up actions'; font.pixelSize: 13; color: '#7B8794' }
                }
                Item { Layout.fillWidth: true }
                Rectangle { height: 30; width: 145; radius: 15; color: '#EFF6FF'
                    Text { text: backend.openCaseCount + ' active cases'; anchors.centerIn: parent; font.pixelSize: 11; color: '#1D4ED8'; font.weight: Font.DemiBold }
                }
            }
            RowLayout { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; spacing: 16; Layout.alignment: Qt.AlignTop
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 380; Layout.preferredHeight: 420; Layout.alignment: Qt.AlignTop; radius: 14; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 22; spacing: 11
                        Text { text: 'Create retention case'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43' }
                        Text { Layout.fillWidth: true; text: 'This is a record of an intended action, not a claim that the customer was saved.'; font.pixelSize: 11; color: '#7B8794'; wrapMode: Text.WordWrap }
                        Text { text: 'Customer ID'; font.pixelSize: 11; font.weight: Font.DemiBold; color: '#486581' }
                        TextField { id: customerId; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: 'e.g. CUST-0005'; enabled: backend.hasData }
                        Text { text: 'Intervention'; font.pixelSize: 11; font.weight: Font.DemiBold; color: '#486581' }
                        ComboBox { id: action; Layout.fillWidth: true; Layout.preferredHeight: 42; model: ['Review account','Service quality follow-up','Billing assistance','Support callback','Offer review','Other'] }
                        Text { text: 'Case note'; font.pixelSize: 11; font.weight: Font.DemiBold; color: '#486581' }
                        TextArea { id: note; Layout.fillWidth: true; Layout.preferredHeight: 78; placeholderText: 'Reason, next step or context…'; wrapMode: TextEdit.Wrap; background: Rectangle { color: '#F9FBFE'; border.color: '#DBE5F0'; radius: 8 } }
                        Item { Layout.fillHeight: true }
                        UiButton { label: 'Create case'; iconName: 'check'; disabled: !backend.hasData; onClicked: { backend.createCase(customerId.text,action.currentText,note.text); if (backend.noticeText.indexOf('created') !== -1) { customerId.text = ''; note.text = '' } } }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 690; Layout.preferredHeight: 540; Layout.alignment: Qt.AlignTop; radius: 14; color: '#FFFFFF'; border.color: '#E6ECF5'
                    ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 13
                        RowLayout { Layout.fillWidth: true
                            Text { text: 'Cases for this dataset'; font.pixelSize: 17; font.weight: Font.DemiBold; color: '#102A43'; Layout.fillWidth: true }
                            Text { text: backend.retentionCases.length + ' shown'; font.pixelSize: 11; color: '#7B8794' }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: '#EDF2F7' }
                        ListView { id: cases; Layout.fillWidth: true; Layout.fillHeight: true; model: backend.retentionCases; spacing: 10; clip: true
                            delegate: Rectangle { width: cases.width; height: 110; color: index % 2 ? '#F9FBFE' : '#FFFFFF'; radius: 9; border.color: '#EDF2F7'
                                ColumnLayout { anchors.fill: parent; anchors.margins: 12; spacing: 5
                                    RowLayout { Layout.fillWidth: true
                                        Text { text: modelData.customerId + '  ·  #' + modelData.id; font.pixelSize: 12; font.weight: Font.DemiBold; color: '#102A43'; Layout.fillWidth: true }
                                        ComboBox { Layout.preferredWidth: 128; Layout.preferredHeight: 30
                                            model: ['Open','Contacted','Resolved','Closed']
                                            currentIndex: Math.max(0, ['Open','Contacted','Resolved','Closed'].indexOf(modelData.status))
                                            onActivated: backend.updateCase(modelData.id,currentText)
                                        }
                                    }
                                    Text { text: modelData.action; font.pixelSize: 12; color: '#1D4ED8'; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: modelData.note ? modelData.note : 'No note provided'; font.pixelSize: 11; color: '#5C6F82'; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: 'Created ' + modelData.created; font.pixelSize: 10; color: '#98A6B3' }
                                }
                            }
                        }
                        Text { visible: cases.count === 0; Layout.fillWidth: true; text: 'No cases for this dataset. Create one using the form.'; color: '#7B8794'; font.pixelSize: 12; wrapMode: Text.WordWrap }
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; implicitHeight: 82; radius: 12; color: '#FFF8F1'; border.color: '#FAD7B0'
                Text { anchors.fill: parent; anchors.margins: 18; text: 'Statuses describe case handling, not causal impact. Measuring whether an intervention prevents churn requires follow-up outcomes and a meaningful comparison group.'; wrapMode: Text.WordWrap; font.pixelSize: 12; color: '#8A5A12'; verticalAlignment: Text.AlignVCenter }
            }
            Text { Layout.fillWidth: true; Layout.leftMargin: 30; Layout.rightMargin: 30; text: backend.noticeText; color: '#486581'; font.pixelSize: 11; wrapMode: Text.WordWrap }
            Item { height: 10 }
        }
    }
}
