import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: win
    title: "Nix Home · Instalador"
    implicitWidth: 1260
    implicitHeight: 820
    color: "transparent"

    property int tab: 0
    property string repo: ""
    property string host: "nixos"
    property string channel: Quickshell.env("NIXHOME_CHANNEL") ?? ""
    property bool repoReady: false
    property var changed: []
    property var targets: []
    property var inConfig: ({})
    property var allFiles: []
    property var categories: []
    property string diffText: ""
    property string toastText: ""
    property bool toastOk: true
    property string pendingStep: ""
    property string pendingAttr: ""
    property bool ready: false
    property bool ddOpen: false

    readonly property var tabInfo: [
        { title: "Paquetes", sub: "Busca en nixpkgs y añádelos a tu configuración" },
        { title: "Cambios", sub: "Revisa todo lo que has modificado" },
        { title: "Terminal", sub: "Valida, prueba y aplica con salida en vivo" },
        { title: "Editor", sub: "Edita cualquier archivo .nix del repositorio" },
        { title: "Ajustes", sub: "Paletas de colores, formas, texto y ventana" }
    ]
    readonly property string toggleCmd: (win.repo !== "" ? shortPath(win.repo) + "/installer" : "~/nix-home/installer") + "/toggle.sh"

    // /home/usuario/nix-home → ~/nix-home
    function shortPath(p) {
        const h = Quickshell.env("HOME") ?? ""
        return (h !== "" && p.indexOf(h) === 0) ? "~" + p.slice(h.length) : p
    }

    readonly property alias backend: backend
    readonly property alias runner: runner

    function toast(msg, ok) {
        win.toastText = msg
        win.toastOk = ok !== false
        toastTimer.restart()
    }

    function refresh() {
        backend.call("status", [], res => {
            if (!res.ok) { win.toast(res.error, false); return }
            win.repo = res.data.repo
            backend.repo = res.data.repo
            win.host = res.data.host
            if (win.channel === "" && res.data.channel !== "") win.channel = res.data.channel
            win.changed = res.data.changed
            win.repoReady = true
            backend.call("targets", [], t => {
                if (!t.ok) { win.toast(t.error, false); return }
                const map = {}
                for (const f of t.data) for (const p of f.packages) {
                    if (!map[p.attr]) map[p.attr] = []
                    if (map[p.attr].indexOf(f.file) < 0) map[p.attr].push(f.file)
                }
                win.inConfig = map
                win.targets = t.data
            })
            backend.call("files", [], f => { if (f.ok) win.allFiles = f.data })
            backend.call("diff", [], d => { if (d.ok) win.diffText = d.data })
        })
    }

    function addPackage(attr, file) {
        backend.call("add", [file, attr], res => {
            if (res.ok) win.toast("＋ " + attr + " → " + file)
            else win.toast(res.error, false)
            win.refresh()
        })
    }

    function removePackage(attr, file) {
        backend.call("remove", [file, attr], res => {
            if (res.ok) win.toast("− " + attr + " ← " + file)
            else win.toast(res.error, false)
            win.refresh()
        })
    }

    function revertAll() {
        backend.call("revert", [], res => {
            if (res.ok) win.toast("Cambios deshechos (" + res.data.length + " archivo(s))")
            else win.toast(res.error, false)
            win.refresh()
        })
    }

    function openFile(rel, line) {
        win.tab = 3
        Qt.callLater(() => editor.open(rel, line))
    }

    function openDropdown(src, model, value, openUp, cb) {
        const p = src.mapToItem(overlay, 0, 0)
        dd.items = model
        dd.value = value
        dd.cb = cb
        dd.srcX = p.x
        dd.srcY = p.y
        dd.srcW = src.width
        dd.srcH = src.height
        dd.up = openUp
        win.ddOpen = true
    }
    function closeDropdown() { win.ddOpen = false }

    function copyText(t, msg) {
        Quickshell.execDetached(["sh", "-c", 'printf %s "$1" | wl-copy', "sh", t])
        win.toast(msg ?? "Copiado")
    }

    // Cierra el instalador (el proceso de quickshell termina del todo).
    function requestClose(force) {
        if (runner.running && !force) {
            win.toast("Hay un comando en ejecución: detenlo o espera a que termine.", false)
            return "busy"
        }
        Qt.quit()
        return "closed"
    }

    function copyOutput() {
        let t = ""
        for (let i = 0; i < runner.lines.count; i++) t += runner.lines.get(i).text + "\n"
        Quickshell.execDetached(["sh", "-c", 'printf %s "$1" | wl-copy', "sh", t])
        win.toast("Salida copiada")
    }

    readonly property var steps: ({
        "validate": { title: "nixos-rebuild dry-build", priv: false,
            script: 'nixos-rebuild dry-build --flake "$REPO#$HOST" --show-trace' },
        "test": { title: "nixos-rebuild test", priv: true,
            script: 'sudo -A nixos-rebuild test --flake "$REPO#$HOST" --show-trace' },
        "switch": { title: "nixos-rebuild switch", priv: true,
            script: 'sudo -A nixos-rebuild switch --flake "$REPO#$HOST" --show-trace' }
    })

    function runStep(id) {
        if (!win.repoReady) { win.toast("Repositorio no detectado todavía.", false); return }
        const s = win.steps[id]
        if (s.priv && runner.sudoPassword === "") { win.pendingStep = id; pwDialog.open(); return }
        win.tab = 2
        runner.start(s.title, s.script, { "STEP": id })
    }

    function buildTest(attr) {
        if (!win.repoReady) return
        win.tab = 2
        runner.start("nix build " + attr, 'nix build "$REPO#nixosConfigurations.$HOST.pkgs.$ATTR" --no-link --print-out-paths --show-trace', { "ATTR": attr })
    }

    function runFree(cmd) {
        win.tab = 2
        runner.start(cmd, cmd, ({}))
    }

    Binding { target: Pal; property: "autoCompact"; value: win.width < 900 }

    Backend { id: backend }

    Runner {
        id: runner
        cwd: win.repo
        repo: win.repo
        host: win.host
        onFinished: (code, title) => {
            win.refresh()
            if (title === "nixos-rebuild switch" && code === 0) {
                backend.call("accept", [], r => { win.toast("Configuración aplicada y aceptada ✔"); win.refresh() })
            }
        }
    }

    FileView {
        path: Quickshell.shellPath("../catalog/categories.json")
        blockLoading: true
        onLoaded: { try { win.categories = JSON.parse(text()) } catch (e) { win.categories = [] } }
    }

    Component.onCompleted: { win.refresh(); readyTimer.start() }
    Timer { id: readyTimer; interval: 1500; onTriggered: win.ready = true }

    // Si cierras la ventana con el gestor de ventanas, el proceso también se apaga.
    onVisibleChanged: if (!win.visible && win.ready) Qt.quit()

    IpcHandler {
        target: "installer"
        function close(): string { return win.requestClose(false) }
        function quit(): string { return win.requestClose(true) }
    }

    Timer { id: toastTimer; interval: 4200; onTriggered: win.toastText = "" }

    Shortcut { sequence: "Ctrl+1"; onActivated: win.tab = 0 }
    Shortcut { sequence: "Ctrl+2"; onActivated: win.tab = 1 }
    Shortcut { sequence: "Ctrl+3"; onActivated: win.tab = 2 }
    Shortcut { sequence: "Ctrl+4"; onActivated: win.tab = 3 }
    Shortcut { sequence: "Ctrl+5"; onActivated: win.tab = 4 }
    Shortcut { sequence: "Ctrl+Q"; onActivated: win.requestClose(false) }

    Item {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ───────────── Barra lateral ─────────────
            Rectangle {
                id: side
                property real sideW: Pal.compact ? 78 : 232
                Behavior on sideW { NumberAnimation { duration: Pal.anim; easing.type: Easing.OutCubic } }
                Layout.preferredWidth: Math.round(side.sideW)
                Layout.fillHeight: true
                color: Pal.panel
                topLeftRadius: Pal.winRadius
                bottomLeftRadius: Pal.winRadius
                clip: true

                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Pal.border }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    anchors.rightMargin: 16
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 46
                            radius: Pal.rLg
                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: Pal.accentHi }
                                GradientStop { position: 1.0; color: Pal.accent }
                            }
                            Text { anchors.centerIn: parent; text: "❄"; color: Pal.onAccent; font.pixelSize: Pal.fs(22) }
                        }
                        ColumnLayout {
                            visible: !Pal.compact
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: "Nix Home"; color: Pal.text; font.pixelSize: Pal.fs(17); font.bold: true }
                            Text { text: "INSTALADOR"; color: Pal.textFaint; font.pixelSize: Pal.fs(9); font.letterSpacing: 1.6 }
                        }
                    }

                    Item { Layout.preferredHeight: 16 }

                    NavItem { app: win; tabIndex: 0; name: "Paquetes"; icon: "⌕" }
                    NavItem { app: win; tabIndex: 1; name: "Cambios"; icon: "±" }
                    NavItem { app: win; tabIndex: 2; name: "Terminal"; icon: "▸" }
                    NavItem { app: win; tabIndex: 3; name: "Editor"; icon: "✎" }

                    Item { Layout.fillHeight: true }

                    NavItem { app: win; tabIndex: 4; name: "Ajustes"; icon: "⚙" }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 6; Layout.bottomMargin: 6; height: 1; color: Pal.border }

                    ColumnLayout {
                        visible: !Pal.compact
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "host · " + win.host; color: Pal.textDim; font.pixelSize: Pal.fs(11) }
                        Text {
                            Layout.fillWidth: true
                            text: win.repo !== "" ? win.shortPath(win.repo) : "buscando repositorio…"
                            color: Pal.textFaint
                            font.pixelSize: Pal.fs(10)
                            elide: Text.ElideMiddle
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8
                        Btn {
                            Layout.fillWidth: true
                            small: true
                            icon: Pal.compact ? "»" : "«"
                            label: Pal.compact ? "" : "Contraer"
                            onClicked: Pal.compactSidebar = !Pal.compactSidebar
                        }
                        Btn {
                            Layout.fillWidth: !Pal.compact
                            visible: !Pal.compact
                            small: true
                            kind: "danger"
                            icon: "⏻"
                            label: "Cerrar"
                            onClicked: win.requestClose(false)
                        }
                    }
                    Btn {
                        visible: Pal.compact
                        Layout.fillWidth: true
                        small: true
                        kind: "danger"
                        icon: "⏻"
                        onClicked: win.requestClose(false)
                    }
                }
            }

            // ───────────── Contenido ─────────────
            Rectangle {
                id: main
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Pal.bg
                topRightRadius: Pal.winRadius
                bottomRightRadius: Pal.winRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: win.width < 700 ? 14 : 26
                    anchors.topMargin: win.width < 700 ? 14 : 22
                    spacing: 18

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: win.tabInfo[win.tab].title
                                color: Pal.text
                                font.pixelSize: Pal.fs(win.width < 700 ? 20 : 24)
                                font.bold: true
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: win.height > 520
                                elide: Text.ElideRight
                                text: win.tabInfo[win.tab].sub
                                color: Pal.textDim
                                font.pixelSize: Pal.fs(12)
                            }
                        }
                        Badge { visible: win.width > 1020; text: "host  " + win.host; tone: "dim" }
                        Badge { visible: win.width > 1020 && win.channel !== ""; text: "nixpkgs  " + win.channel; tone: "accent" }
                        Badge { visible: win.width > 800 && win.changed.length > 0; text: win.changed.length + " sin aplicar"; tone: "warn" }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        SearchPage { anchors.fill: parent; app: win; visible: win.tab === 0 }
                        ChangesPage { anchors.fill: parent; app: win; visible: win.tab === 1 }
                        TerminalPage { anchors.fill: parent; app: win; visible: win.tab === 2 }
                        EditorPage { id: editor; anchors.fill: parent; app: win; visible: win.tab === 3 }
                        SettingsPage { anchors.fill: parent; app: win; visible: win.tab === 4 }
                    }
                }

                // Aviso flotante
                Rectangle {
                    visible: win.toastText !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 104
                    z: 90
                    height: 42
                    width: Math.min(parent.width - 60, toastLabel.implicitWidth + 58)
                    radius: Pal.rLg
                    color: Pal.raised
                    border.color: win.toastOk ? Pal.alpha(Pal.ok, 0.6) : Pal.alpha(Pal.err, 0.6)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8; height: 8; radius: 4
                        color: win.toastOk ? Pal.ok : Pal.err
                    }
                    Text {
                        id: toastLabel
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 34
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        elide: Text.ElideRight
                        text: win.toastText
                        color: Pal.text
                        font.pixelSize: Pal.fs(12)
                    }
                }

                // Contraseña de sudo
                Rectangle {
                    id: pwDialog
                    visible: false
                    anchors.fill: parent
                    z: 100
                    color: Pal.alpha(Qt.rgba(0, 0, 0, 1), 0.62)
                    topRightRadius: Pal.winRadius
                    bottomRightRadius: Pal.winRadius

                    function open() { visible = true; pw.text = ""; pw.focusInput() }
                    function close() { visible = false }

                    MouseArea { anchors.fill: parent }

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(440, pwDialog.width - 32)
                        height: pwCol.implicitHeight + 48
                        radius: Pal.rLg + 4
                        color: Pal.raised
                        border.color: Pal.alpha(Pal.accent, 0.7)

                        ColumnLayout {
                            id: pwCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 24
                            spacing: 12
                            RowLayout {
                                spacing: 10
                                Rectangle {
                                    width: 34; height: 34; radius: Pal.rMd; color: Pal.accentSoft
                                    Text { anchors.centerIn: parent; text: "🔑"; font.pixelSize: Pal.fs(16) }
                                }
                                Text { text: "Contraseña de sudo"; color: Pal.text; font.pixelSize: Pal.fs(16); font.bold: true }
                            }
                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: "Hace falta para activar la configuración (nixos-rebuild test/switch). Se guarda solo en memoria mientras esta ventana siga abierta."
                                color: Pal.textDim
                                font.pixelSize: Pal.fs(11)
                            }
                            Field {
                                id: pw
                                Layout.fillWidth: true
                                password: true
                                placeholder: "contraseña"
                                onAccepted: okBtn.clicked()
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Item { Layout.fillWidth: true }
                                Btn { label: "Cancelar"; onClicked: { win.pendingStep = ""; pwDialog.close() } }
                                Btn {
                                    id: okBtn
                                    label: "Continuar"
                                    kind: "primary"
                                    onClicked: {
                                        if (pw.text === "") return
                                        runner.sudoPassword = pw.text
                                        pw.text = ""
                                        pwDialog.close()
                                        const s = win.pendingStep
                                        win.pendingStep = ""
                                        if (s !== "") win.runStep(s)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Capa superior: menús desplegables (reciben los clics por encima de todo)
        Item {
            id: overlay
            anchors.fill: parent
            z: 300

            MouseArea {
                anchors.fill: parent
                visible: win.ddOpen
                onClicked: win.closeDropdown()
            }

            Rectangle {
                id: dd
                property var items: []
                property string value: ""
                property var cb
                property real srcX: 0
                property real srcY: 0
                property real srcW: 200
                property real srcH: 38
                property bool up: true

                visible: win.ddOpen
                width: srcW
                height: Math.min(300, ddView.contentHeight + 10)
                x: Math.max(8, Math.min(srcX, overlay.width - width - 8))
                y: up ? Math.max(8, srcY - height - 6) : Math.min(srcY + srcH + 6, overlay.height - height - 8)
                radius: Pal.rMd
                color: Pal.raised
                border.color: Pal.accent

                MouseArea { anchors.fill: parent }

                ListView {
                    id: ddView
                    anchors.fill: parent
                    anchors.margins: 5
                    clip: true
                    model: dd.items
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        required property var modelData
                        width: ddView.width
                        height: 32
                        radius: Pal.rSm
                        color: ddm.containsMouse ? Pal.accentSoft : "transparent"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            elide: Text.ElideMiddle
                            text: modelData
                            color: modelData === dd.value ? Pal.accentText : Pal.text
                            font.pixelSize: Pal.fs(12)
                            font.bold: modelData === dd.value
                        }
                        MouseArea {
                            id: ddm
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const f = dd.cb
                                win.closeDropdown()
                                if (f) f(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
