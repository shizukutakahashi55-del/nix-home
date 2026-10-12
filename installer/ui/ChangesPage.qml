import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var app
    property bool confirmRevert: false

    readonly property var diffLines: root.app.diffText === "" ? [] : root.app.diffText.split("\n")

    Timer { id: confirmTimer; interval: 3500; onTriggered: root.confirmRevert = false }

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.app.changed.length === 0 ? "No hay cambios sin aplicar respecto al último estado aceptado."
                : root.app.changed.length + " archivo(s) modificado(s). Revisa el diff y luego valida o prueba."
            color: Pal.textDim
            font.pixelSize: Pal.fs(12)
        }
        Flow {
            Layout.fillWidth: true
            spacing: 8
            Btn { label: "Refrescar"; icon: "↻"; onClicked: root.app.refresh() }
            Btn {
                label: root.confirmRevert ? "¿Seguro? Pulsa otra vez" : "Deshacer todo"
                kind: "danger"
                enabled: root.app.changed.length > 0
                onClicked: {
                    if (!root.confirmRevert) { root.confirmRevert = true; confirmTimer.restart(); return }
                    root.confirmRevert = false
                    root.app.revertAll()
                }
            }
            Btn {
                label: "Validar y probar"
                icon: "→"
                kind: "primary"
                enabled: !root.app.runner.running
                onClicked: root.app.runStep("validate")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            Rectangle {
                visible: root.width > 760
                Layout.preferredWidth: Math.max(200, Math.min(280, root.width * 0.26))
                Layout.fillHeight: true
                radius: Pal.rLg
                color: Pal.card
                border.color: Pal.border
                ListView {
                    id: files
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 3
                    model: root.app.changed
                    delegate: Rectangle {
                        width: files.width
                        height: 42
                        radius: Pal.rMd
                        color: fm.containsMouse ? Pal.accentSoft : "transparent"
                        Rectangle {
                            width: 8; height: 8; radius: 4; color: Pal.warn
                            anchors.left: parent.left; anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            anchors.right: edit.left
                            anchors.rightMargin: 6
                            elide: Text.ElideMiddle
                            text: modelData
                            color: Pal.text
                            font.pixelSize: Pal.fs(12)
                        }
                        Text {
                            id: edit
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            text: "editar ↗"
                            color: Pal.accentText
                            font.pixelSize: Pal.fs(11)
                        }
                        MouseArea { id: fm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.app.openFile(modelData, 1) }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.app.changed.length === 0
                    text: "Sin cambios"
                    color: Pal.textFaint
                    font.pixelSize: Pal.fs(12)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Pal.rLg
                color: Pal.termBg
                border.color: Pal.border

                ListView {
                    id: diff
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.rightMargin: 20
                    clip: true
                    model: root.diffLines
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        width: diff.width
                        height: Pal.fs(19)
                        radius: 3
                        color: modelData.startsWith("+") && !modelData.startsWith("+++") ? Pal.diffAdd
                             : modelData.startsWith("-") && !modelData.startsWith("---") ? Pal.diffDel
                             : "transparent"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            text: modelData
                            textFormat: Text.PlainText
                            font.family: Pal.mono
                            font.pixelSize: Pal.fs(12)
                            color: modelData.startsWith("@@") ? Pal.accentText
                                 : modelData.startsWith("+++") || modelData.startsWith("---") ? Pal.textDim
                                 : modelData.startsWith("+") ? Pal.ok
                                 : modelData.startsWith("-") ? Pal.err
                                 : Pal.text
                        }
                    }
                }
                VScroll { target: diff; anchors.right: parent.right; anchors.rightMargin: 5; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 8 }
                Text {
                    anchors.centerIn: parent
                    visible: root.diffLines.length === 0
                    text: "El diff aparecerá aquí"
                    color: Pal.textFaint
                    font.pixelSize: Pal.fs(12)
                }
            }
        }
    }
}
