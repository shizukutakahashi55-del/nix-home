import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property string cwd: ""
    property string repo: ""
    property string host: "nixos"
    property string sudoPassword: ""
    property bool running: false
    property int exitCode: -1
    property string title: ""
    property int errorFiles: 0
    readonly property alias lines: lines
    signal finished(int code, string title)

    ListModel { id: lines }

    function stripAnsi(s) {
        return s.replace(/\x1b\[[0-9;?]*[A-Za-z]/g, "").replace(/\x1b\][^\x07]*\x07/g, "")
    }

    function fileRef(t) {
        let m = /\/nix\/store\/[a-z0-9]{32}-[^\/\s]*\/([^\s:()"']+\.nix):(\d+)/.exec(t)
        if (m) return { file: m[1], line: parseInt(m[2]) }
        if (root.repo !== "") {
            const i = t.indexOf(root.repo + "/")
            if (i >= 0) {
                const rest = t.slice(i + root.repo.length + 1)
                m = /^([^\s:()"']+\.nix):(\d+)/.exec(rest)
                if (m) return { file: m[1], line: parseInt(m[2]) }
            }
        }
        return null
    }

    function push(raw, forceKind) {
        let t = stripAnsi(raw)
        const cr = t.lastIndexOf("\r")
        if (cr >= 0) t = t.slice(cr + 1)
        let kind = forceKind ?? "out"
        if (!forceKind) {
            if (/^\s*(error|error:)/i.test(t) || /\berror:/.test(t)) kind = "err"
            else if (/^\s*warning/i.test(t)) kind = "warn"
        }
        const ref = root.fileRef(t)
        if (ref && kind !== "cmd") root.errorFiles++
        if (lines.count > 6000) lines.remove(0, 1000)
        lines.append({ text: t, kind: kind, file: ref ? ref.file : "", line: ref ? ref.line : 0 })
    }

    function clear() { lines.clear(); root.errorFiles = 0; root.exitCode = -1 }

    function firstErrorRef() {
        for (let i = 0; i < lines.count; i++) {
            const l = lines.get(i)
            if (l.file !== "") return { file: l.file, line: l.line }
        }
        return null
    }

    function start(title, script, extraEnv) {
        if (root.running) return false
        root.clear()
        root.title = title
        root.push("$ " + title, "cmd")
        const env = {
            "REPO": root.repo,
            "HOST": root.host,
            "NIXHOME_PW": root.sudoPassword,
            "SUDO_ASKPASS": Quickshell.shellPath("askpass.sh"),
            "NIX_CONFIG": "show-trace = true\nwarn-dirty = false"
        }
        for (const k in (extraEnv ?? {})) env[k] = extraEnv[k]
        proc.environment = env
        proc.command = ["sh", "-c", "exec 2>&1\n" + script]
        root.running = true
        proc.running = true
        return true
    }

    function stop() { if (root.running) proc.running = false }

    Process {
        id: proc
        workingDirectory: root.cwd !== "" ? root.cwd : Quickshell.env("HOME")
        stdout: SplitParser {
            onRead: data => root.push(data)
        }
        onExited: (code, status) => {
            root.running = false
            root.exitCode = code
            root.push(code === 0 ? "✔ Terminó correctamente" : "✘ Terminó con código " + code, code === 0 ? "ok" : "err")
            root.finished(code, root.title)
        }
    }
}
