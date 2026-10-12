import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var app
    property string file: ""
    property bool dirty: false
    property bool loading: false
    property string message: ""
    property bool messageOk: true
    property int pendingLine: 0
    property string filter: ""
    readonly property bool narrow: width < 760

    readonly property var visibleFiles: root.app.allFiles.filter(f => root.filter === "" || f.toLowerCase().indexOf(root.filter.toLowerCase()) >= 0)
    readonly property string fullPath: root.file !== "" ? root.app.repo + "/" + root.file : ""

    function open(rel, line) {
        root.pendingLine = line ?? 0
        if (rel === root.file) { root.reload(); return }
        root.file = rel
        root.reload()
    }

    function reload() {
        if (root.file === "") return
        root.loading = true
        root.message = ""
        viewer.path = ""
        viewer.path = root.fullPath
    }

    function gotoLine(n) {
        if (n <= 0) return
        const t = area.text
        let pos = 0
        for (let i = 1; i < n; i++) {
            const nl = t.indexOf("\n", pos)
            if (nl < 0) break
            pos = nl + 1
        }
        area.cursorPosition = pos
        area.forceActiveFocus()
        Qt.callLater(() => { flick.contentY = Math.max(0, area.cursorRectangle.y - flick.height / 3) })
    }

    function save() {
        if (root.file === "") return
        root.app.backend.call("snapshot", [root.file], res => {
            if (!res.ok) { root.message = res.error; root.messageOk = false; return }
            viewer.setText(area.text)
            root.dirty = false
            root.message = "Guardado."
            root.messageOk = true
            root.app.refresh()
        })
    }

    function checkSyntax() {
        if (root.file === "") return
        syntax.command = ["sh", "-c",
            'nix-instantiate --parse "$1" >/dev/null 2>"$2" && echo __OK__ || cat "$2"; rm -f "$2"',
            "sh", root.fullPath, "/tmp/nixhome-syntax-" + Date.now()]
        syntax.running = true
    }

    FileView {
        id: viewer
        blockLoading: true
        onLoaded: {
            area.text = viewer.text()
            root.dirty = false
            root.loading = false
            if (root.pendingLine > 0) { root.gotoLine(root.pendingLine); root.pendingLine = 0 }
        }
        onLoadFailed: error => { root.loading = false; root.message = "No pude leer el archivo."; root.messageOk = false }
    }

    Process {
        id: syntax
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t === "__OK__") { root.message = "Sintaxis correcta."; root.messageOk = true; return }
                root.message = t.split("\n").slice(0, 4).join("  ")
                root.messageOk = false
                const m = /:(\d+):\d+/.exec(t)
                if (m) root.gotoLine(parseInt(m[1]))
            }
        }
    }

    Shortcut { sequence: "Ctrl+S"; onActivated: root.save() }

    RowLayout {
        anchors.fill: parent
        spacing: 14

        ColumnLayout {
            visible: !root.narrow
            Layout.preferredWidth: Math.max(210, Math.min(300, root.width * 0.28))
            Layout.fillHeight: true
            spacing: 10
            Field {
                Layout.fillWidth: true
                icon: "⌕"
                placeholder: "Filtrar…"
                onEdited: root.filter = text
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Pal.rLg
                color: Pal.card
                border.color: Pal.border
                ListView {
                    id: flist
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 2
                    model: root.visibleFiles
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool sel: modelData === root.file
                        readonly property var parts: modelData.split("/")
                        width: flist.width
                        height: Pal.fs(42)
                        radius: Pal.rSm + 2
                        color: sel ? Pal.accentSoft : (fm.containsMouse ? Pal.hover : "transparent")
                        Rectangle {
                            visible: parent.sel
                            width: 3; height: 16; radius: 2; color: Pal.accent
                            anchors.left: parent.left; anchors.leftMargin: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            spacing: 1
                            Text {
                                width: parent.width
                                elide: Text.ElideRight
                                text: parent.parent.parts[parent.parent.parts.length - 1]
                                font.pixelSize: Pal.fs(12)
                                font.bold: parent.parent.sel
                                color: root.app.changed.indexOf(parent.parent.modelData) >= 0 ? Pal.warn : (parent.parent.sel ? Pal.text : Pal.textDim)
                            }
                            Text {
                                width: parent.width
                                visible: parent.parent.parts.length > 1
                                elide: Text.ElideLeft
                                text: parent.parent.parts.slice(0, -1).join("/")
                                font.pixelSize: Pal.fs(10)
                                color: Pal.textFaint
                            }
                        }
                        MouseArea { id: fm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.open(modelData, 0) }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // En ventanas estrechas la lista pasa a ser un selector
            Dropdown {
                visible: root.narrow
                Layout.fillWidth: true
                app: root.app
                openUp: false
                model: root.app.allFiles
                value: root.file
                onPicked: v => root.open(v, 0)
            }

            Text {
                Layout.fillWidth: true
                visible: !root.narrow
                elide: Text.ElideMiddle
                text: (root.file !== "" ? root.file : "Elige un archivo") + (root.dirty ? "  ●" : "")
                color: root.dirty ? Pal.warn : Pal.text
                font.pixelSize: Pal.fs(14)
                font.bold: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Btn { small: true; label: "Guardar"; icon: "💾"; kind: "primary"; enabled: root.file !== "" && root.dirty; onClicked: root.save() }
                Btn { small: true; label: "Sintaxis"; enabled: root.file !== ""; onClicked: root.checkSyntax() }
                Btn { small: true; label: "Recargar"; enabled: root.file !== ""; onClicked: root.reload() }
                Btn {
                    small: true
                    label: "Editor externo"
                    enabled: root.file !== ""
                    onClicked: Quickshell.execDetached(["sh", "-c", 'exec ${TERMINAL:-foot} -e ${EDITOR:-nvim} "$1"', "sh", root.fullPath])
                }
                Badge { visible: root.narrow && root.dirty; text: "sin guardar"; tone: "warn" }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Pal.rLg
                color: Pal.termBg
                border.width: area.activeFocus ? 2 : 1
                border.color: area.activeFocus ? Pal.accent : Pal.border

                Flickable {
                    id: flick
                    anchors.fill: parent
                    anchors.margins: 14
                    anchors.rightMargin: 20
                    clip: true
                    contentWidth: width
                    contentHeight: Math.max(area.implicitHeight, height)
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        id: gutter
                        x: 0
                        width: 38
                        horizontalAlignment: Text.AlignRight
                        color: Pal.textFaint
                        font.family: Pal.mono
                        font.pixelSize: Pal.fs(13)
                        text: Array.from({ length: Math.max(1, area.lineCount) }, (_, i) => i + 1).join("\n")
                    }

                    TextEdit {
                        id: area
                        x: 52
                        width: flick.width - 52
                        height: Math.max(implicitHeight, flick.height)
                        color: Pal.text
                        selectionColor: Pal.accent
                        selectedTextColor: Pal.onAccent
                        font.family: Pal.mono
                        font.pixelSize: Pal.fs(13)
                        wrapMode: TextEdit.NoWrap
                        readOnly: root.file === "" || root.loading
                        onTextChanged: if (!root.loading) root.dirty = true
                        onCursorRectangleChanged: {
                            const r = cursorRectangle
                            if (r.y < flick.contentY) flick.contentY = r.y
                            else if (r.y + r.height > flick.contentY + flick.height) flick.contentY = r.y + r.height - flick.height
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Tab) { area.insert(area.cursorPosition, "  "); event.accepted = true }
                        }
                    }
                }
                VScroll { target: flick; anchors.right: parent.right; anchors.rightMargin: 5; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 8 }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.message !== ""
                implicitHeight: msg.implicitHeight + 16
                radius: Pal.rMd
                color: root.messageOk ? Pal.okBg : Pal.errBg
                Text {
                    id: msg
                    anchors.fill: parent
                    anchors.margins: 8
                    anchors.leftMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: root.message
                    color: root.messageOk ? Pal.ok : Pal.err
                    font.pixelSize: Pal.fs(12)
                }
            }
        }
    }
}
