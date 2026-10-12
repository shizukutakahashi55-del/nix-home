import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var app
    readonly property var runner: app.runner

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Flow {
            Layout.fillWidth: true
            spacing: 8
            Btn { label: root.width < 640 ? "1 · Validar" : "1 · Validar (dry-build)"; enabled: !root.runner.running; onClicked: root.app.runStep("validate") }
            Btn { label: root.width < 640 ? "2 · Probar" : "2 · Probar (test)"; enabled: !root.runner.running; onClicked: root.app.runStep("test") }
            Btn { label: root.width < 640 ? "3 · Aplicar" : "3 · Aplicar (switch)"; kind: "primary"; enabled: !root.runner.running; onClicked: root.app.runStep("switch") }
            Btn {
                label: "Ir al error ↗"
                visible: !root.runner.running && root.runner.exitCode > 0 && root.runner.errorFiles > 0
                kind: "danger"
                onClicked: { const r = root.runner.firstErrorRef(); if (r) root.app.openFile(r.file, r.line) }
            }
            Btn { label: "Detener"; icon: "■"; kind: "danger"; visible: root.runner.running; onClicked: root.runner.stop() }
            Btn { label: "Copiar"; onClicked: root.app.copyOutput() }
            Btn { label: "Limpiar"; enabled: !root.runner.running; onClicked: root.runner.clear() }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Pal.rLg
            color: Pal.termBg
            border.color: Pal.border
            clip: true

            // Barra de título de la terminal
            Rectangle {
                id: titleBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 38
                color: Pal.alpha(Pal.text, 0.04)
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Pal.border }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 7
                    Rectangle { width: 10; height: 10; radius: 5; color: Pal.err }
                    Rectangle { width: 10; height: 10; radius: 5; color: Pal.warn }
                    Rectangle { width: 10; height: 10; radius: 5; color: Pal.ok }
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 76
                    anchors.right: parent.right
                    anchors.rightMargin: 110
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                    text: root.runner.title !== "" ? root.runner.title : "terminal"
                    color: Pal.textDim
                    font.family: Pal.mono
                    font.pixelSize: Pal.fs(11)
                }
                Badge {
                    visible: root.runner.title !== ""
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    tone: root.runner.running ? "accent" : (root.runner.exitCode === 0 ? "ok" : "err")
                    text: root.runner.running ? "ejecutando…" : (root.runner.exitCode === 0 ? "OK" : "falló (" + root.runner.exitCode + ")")
                }
            }

            ListView {
                id: out
                anchors.top: titleBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                anchors.rightMargin: 20
                clip: true
                model: root.runner.lines
                boundsBehavior: Flickable.StopAtBounds
                property bool follow: true
                onMovementEnded: follow = atYEnd
                onCountChanged: if (follow) Qt.callLater(() => out.positionViewAtEnd())

                delegate: Item {
                    required property string text
                    required property string kind
                    required property string file
                    required property int line
                    width: out.width
                    height: lineText.implicitHeight + 2

                    Text {
                        id: lineText
                        anchors.left: parent.left
                        anchors.right: link.visible ? link.left : parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.text
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAnywhere
                        font.family: Pal.mono
                        font.pixelSize: Pal.fs(12)
                        color: parent.kind === "err" ? Pal.err
                             : parent.kind === "warn" ? Pal.warn
                             : parent.kind === "ok" ? Pal.ok
                             : parent.kind === "cmd" ? Pal.accentText
                             : Pal.text
                    }
                    Text {
                        id: link
                        visible: parent.file !== ""
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "editar ↗"
                        font.pixelSize: Pal.fs(11)
                        color: Pal.accentText
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.app.openFile(parent.parent.file, parent.parent.line)
                        }
                    }
                }
            }
            VScroll { target: out; anchors.right: parent.right; anchors.rightMargin: 5; anchors.top: titleBar.bottom; anchors.bottom: parent.bottom; anchors.margins: 8 }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 19
                visible: root.runner.lines.count === 0
                horizontalAlignment: Text.AlignHCenter
                color: Pal.textFaint
                font.pixelSize: Pal.fs(12)
                lineHeight: 1.4
                text: "La salida de validación, prueba e instalación aparece aquí en vivo.\nTambién puedes escribir cualquier comando abajo (se ejecuta en tu repositorio)."
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Field {
                id: cmd
                Layout.fillWidth: true
                mono: true
                icon: "$"
                placeholder: "git status, nix flake check, journalctl -xe -n 50…"
                onAccepted: { if (cmd.text.trim() !== "") { root.app.runFree(cmd.text.trim()); cmd.text = "" } }
            }
            Btn {
                label: "Ejecutar"
                kind: "primary"
                enabled: !root.runner.running && cmd.text.trim() !== ""
                onClicked: { root.app.runFree(cmd.text.trim()); cmd.text = "" }
            }
        }
    }
}
