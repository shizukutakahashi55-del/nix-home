import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var app

    property string mode: "search"
    property var results: []
    property int selected: -1
    property bool searching: false
    property string errText: ""
    property bool missing: false
    property string target: ""
    property int searchGen: 0
    property string pendingQuery: ""
    property bool rerun: false
    readonly property bool narrow: width < 720

    readonly property var current: selected >= 0 && selected < results.length ? results[selected] : null
    readonly property var targetFiles: app.targets.map(t => t.file)

    function suggest(pkg) {
        const hay = (pkg.attr + " " + (pkg.desc ?? "")).toLowerCase()
        for (let i = 0; i < app.categories.length; i++) {
            const c = app.categories[i]
            if (root.targetFiles.indexOf(c.file) < 0) continue
            if ((c.keywords ?? []).some(k => hay.indexOf(k.toLowerCase()) >= 0)) return c.file
        }
        if (root.target !== "" && root.targetFiles.indexOf(root.target) >= 0) return root.target
        const home = app.targets.find(t => t.kind === "home")
        return home ? home.file : (root.targetFiles[0] ?? "")
    }

    function select(i) {
        root.selected = i
        if (i >= 0 && root.mode === "search" && root.results[i]) root.target = root.suggest(root.results[i])
    }

    function buildInstalled() {
        const q = field.text.trim().toLowerCase()
        const out = []
        for (const t of app.targets)
            for (const p of t.packages)
                if (q === "" || p.attr.toLowerCase().indexOf(q) >= 0 || t.file.toLowerCase().indexOf(q) >= 0)
                    out.push({ attr: p.attr, version: "", desc: t.file, file: t.file, line: p.line, unfree: false })
        root.results = out
        root.selected = out.length > 0 ? 0 : -1
    }

    function setMode(m) {
        root.mode = m
        root.errText = ""
        root.missing = false
        if (m === "installed") { debounce.stop(); root.buildInstalled() }
        else { root.results = []; root.selected = -1; root.startSearch() }
    }

    function startSearch() {
        if (root.mode === "installed") { root.buildInstalled(); return }
        const q = field.text.trim()
        if (q.length < 2) {
            root.rerun = false
            if (proc.running) proc.running = false
            root.results = []
            root.selected = -1
            root.searching = false
            return
        }
        root.pendingQuery = q
        if (proc.running) { root.rerun = true; proc.running = false; return }
        root.runSearch(q)
    }

    function runSearch(q) {
        proc.buf = []
        proc.gotGen = false
        proc.valid = false
        proc.err = ""
        proc.terms = q.split(/\s+/).filter(t => t !== "")
        root.searchGen++
        root.searching = true
        root.errText = ""
        root.missing = false
        proc.running = true
    }

    function parseItem(o) {
        if (!o || typeof o !== "object") return null
        const attr = o.package_attr_name ?? o.attr ?? o.attribute ?? o.name ?? ""
        if (attr === "") return null
        return {
            attr: attr,
            version: String(o.package_pversion ?? o.version ?? ""),
            desc: String(o.package_description ?? o.description ?? ""),
            unfree: o.package_unfree === true || o.unfree === true,
            file: "", line: 0
        }
    }

    function chooseCategory(c) {
        field.text = (c.keywords && c.keywords.length > 0) ? c.keywords[0] : c.label
        if (root.mode !== "search") root.mode = "search"
        root.startSearch()
    }

    Timer { id: debounce; interval: 350; onTriggered: root.startSearch() }

    Process {
        id: proc
        property var buf: []
        property var terms: []
        property bool gotGen: false
        property bool valid: false
        property string err: ""

        command: ["sh", "-c",
            'echo "$1"; shift; ' +
            'command -v nix-search >/dev/null 2>&1 || { echo __NO_NIX_SEARCH__; exit 127; }; ' +
            'exec nix-search "$@"',
            "sh", String(root.searchGen)
        ].concat(["--json", "--max-results", "40"],
                 (root.app.channel !== "" ? ["--channel", root.app.channel] : []),
                 ["--"], proc.terms)

        stdout: SplitParser {
            onRead: line => {
                if (!proc.gotGen) { proc.gotGen = true; proc.valid = (line === String(root.searchGen)); return }
                if (!proc.valid || line === "") return
                if (line === "__NO_NIX_SEARCH__") { root.missing = true; return }
                let parsed
                try { parsed = JSON.parse(line) } catch (e) { return }
                const list = Array.isArray(parsed) ? parsed : [parsed]
                for (let i = 0; i < list.length; i++) {
                    const it = root.parseItem(list[i])
                    if (it) proc.buf.push(it)
                }
                root.results = proc.buf.slice()
                if (root.selected < 0 && root.results.length > 0) root.select(0)
            }
        }
        stderr: SplitParser {
            onRead: line => { if (line.trim() !== "") proc.err = line.trim() }
        }
        onRunningChanged: {
            if (running) return
            root.searching = false
            if (root.rerun) { root.rerun = false; root.runSearch(root.pendingQuery); return }
            if (!proc.valid) return
            if (proc.buf.length === 0) { root.results = []; root.selected = -1; root.errText = proc.err }
        }
    }

    Connections {
        target: root.app
        function onTargetsChanged() { if (root.mode === "installed") root.buildInstalled() }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Field {
                id: field
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                icon: "⌕"
                placeholder: root.mode === "search" ? (root.narrow ? "Buscar paquetes…" : "Buscar paquetes en nixpkgs (" + (root.app.channel !== "" ? root.app.channel : "unstable") + ")…") : "Filtrar paquetes de tu configuración…"
                onEdited: { if (root.mode === "installed") root.buildInstalled(); else debounce.restart() }
                onAccepted: { debounce.stop(); root.startSearch() }
            }
            Segmented {
                Layout.preferredHeight: 48
                value: root.mode
                options: [{ id: "search", label: "Buscar" }, { id: "installed", label: root.narrow ? "Mi config" : "En mi configuración" }]
                onPicked: id => root.setMode(id)
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: root.mode === "search"
            Repeater {
                model: root.app.categories
                delegate: Rectangle {
                    height: 30
                    width: chip.implicitWidth + 24
                    radius: Pal.rMd + 4
                    color: cm.containsMouse ? Pal.accentSoft : Pal.card
                    border.color: cm.containsMouse ? Pal.alpha(Pal.accent, 0.5) : Pal.border
                    Behavior on color { ColorAnimation { duration: Pal.animFast } }
                    Text { id: chip; anchors.centerIn: parent; text: modelData.label; color: cm.containsMouse ? Pal.accentText : Pal.textDim; font.pixelSize: Pal.fs(11) }
                    MouseArea { id: cm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.chooseCategory(modelData) }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Pal.rLg
            color: Pal.card
            border.color: Pal.border

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 10
                anchors.rightMargin: 18
                clip: true
                spacing: 4
                model: root.results
                currentIndex: root.selected
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property var where: root.app.inConfig[modelData.attr] ?? []
                    readonly property bool sel: index === root.selected
                    width: list.width
                    height: Pal.fs(68)
                    radius: Pal.rMd
                    color: sel ? Pal.accentSoft : (hov.containsMouse ? Pal.hover : "transparent")
                    border.width: 1
                    border.color: sel ? Pal.alpha(Pal.accent, 0.5) : "transparent"
                    Behavior on color { ColorAnimation { duration: Pal.animFast } }

                    MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true; onClicked: root.select(index) }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: Pal.rMd
                            color: row.sel ? Pal.accent : Pal.raised
                            Text {
                                anchors.centerIn: parent
                                text: modelData.attr.charAt(0).toUpperCase()
                                color: row.sel ? Pal.onAccent : Pal.accentText
                                font.pixelSize: Pal.fs(16)
                                font.bold: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                clip: true
                                spacing: 8
                                Text { text: modelData.attr; color: Pal.text; font.pixelSize: Pal.fs(14); font.bold: true }
                                Text { visible: modelData.version !== ""; text: modelData.version; color: Pal.textFaint; font.pixelSize: Pal.fs(11) }
                                Badge { visible: modelData.unfree; text: "unfree"; tone: "warn" }
                                Badge { visible: root.mode === "search" && row.where.length > 0; text: "✔ en tu config"; tone: "ok" }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.desc
                                color: Pal.textDim
                                font.pixelSize: Pal.fs(11)
                                elide: Text.ElideRight
                            }
                        }
                        Btn {
                            visible: root.mode === "installed"
                            small: true
                            label: "Editar"
                            onClicked: root.app.openFile(modelData.file, modelData.line)
                        }
                    }
                }
            }
            VScroll { target: list; anchors.right: parent.right; anchors.rightMargin: 5; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.topMargin: 10; anchors.bottomMargin: 10 }

            ColumnLayout {
                anchors.centerIn: parent
                visible: root.results.length === 0
                spacing: 8
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.missing || root.errText !== "" ? "⚠" : (root.searching ? "…" : "⌕")
                    color: root.missing || root.errText !== "" ? Pal.err : Pal.textFaint
                    font.pixelSize: Pal.fs(34)
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.missing ? "No encuentro nix-search" : (root.searching ? "Buscando…" : (root.errText !== "" ? "La búsqueda falló" : (root.mode === "search" ? "Escribe al menos 2 letras" : "Sin paquetes")))
                    color: root.missing || root.errText !== "" ? Pal.err : Pal.text
                    font.pixelSize: Pal.fs(16)
                    font.bold: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 520
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Pal.textDim
                    font.pixelSize: Pal.fs(12)
                    text: root.missing ? "Instala nix-search-cli (por ejemplo: nix shell nixpkgs#nix-search-cli) y vuelve a abrir el instalador."
                        : (root.errText !== "" ? root.errText : "")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: bar.implicitHeight + 28
            radius: Pal.rLg
            color: Pal.card
            border.color: Pal.border

            ColumnLayout {
                id: bar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 18
                anchors.rightMargin: 14
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: root.current ? root.current.attr : "Nada seleccionado"
                        color: Pal.text
                        font.pixelSize: Pal.fs(14)
                        font.bold: true
                    }
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: root.mode === "search" ? "Se añade al archivo elegido; los cambios no se aplican hasta que los pruebes."
                                                     : (root.current ? root.current.file + ":" + root.current.line : "")
                        color: Pal.textFaint
                        font.pixelSize: Pal.fs(11)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text { visible: root.mode === "search" && !root.narrow; text: "Destino"; color: Pal.textDim; font.pixelSize: Pal.fs(11) }
                    Dropdown {
                        app: root.app
                        visible: root.mode === "search"
                        Layout.fillWidth: true
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 380
                        model: root.targetFiles
                        value: root.target
                        onPicked: v => root.target = v
                    }
                    Item { Layout.fillWidth: true }
                    Btn {
                        visible: root.mode === "search"
                        label: root.narrow ? "" : "Probar build"
                        icon: "⚒"
                        enabled: root.current !== null
                        onClicked: root.app.buildTest(root.current.attr)
                    }
                    Btn {
                        visible: root.mode === "search"
                        label: root.current && (root.app.inConfig[root.current.attr] ?? []).length > 0 ? "Ya añadido" : "Añadir"
                        icon: "＋"
                        kind: "primary"
                        enabled: root.current !== null && root.target !== "" && !((root.app.inConfig[root.current.attr] ?? []).indexOf(root.target) >= 0)
                        onClicked: root.app.addPackage(root.current.attr, root.target)
                    }
                    Btn {
                        visible: root.mode === "installed"
                        label: "Quitar de la configuración"
                        kind: "danger"
                        enabled: root.current !== null
                        onClicked: root.app.removePackage(root.current.attr, root.current.file)
                    }
                }
            }
        }
    }
}
