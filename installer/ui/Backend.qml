import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property string bin: Quickshell.env("NIXHOME_BACKEND") ?? "nix-home-installer"
    property string repo: Quickshell.env("NIXHOME_REPO") ?? ""

    function call(cmd, extra, cb) {
        const args = [cmd, root.repo].concat(extra ?? [])
        job.createObject(root, { command: [root.bin].concat(args), cb: cb })
    }

    Component {
        id: job
        Item {
            id: j
            property var cb
            property var command: []
            property bool done: false
            property int code: 0

            function finish(res) {
                if (j.done) return
                j.done = true
                if (j.cb) j.cb(res)
                j.destroy(200)
            }

            Process {
                command: j.command
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        let res
                        try { res = JSON.parse(text) }
                        catch (e) { res = { ok: false, data: null, error: text !== "" ? text : "Respuesta vacía del backend." } }
                        j.finish(res)
                    }
                }
                onExited: (exitCode, exitStatus) => { j.code = exitCode; grace.start() }
            }

            Timer {
                id: grace
                interval: 500
                onTriggered: j.finish({ ok: false, data: null, error: "No pude ejecutar '" + root.bin + "' (código " + j.code + "). ¿Compilaste el backend? Revisa NIXHOME_BACKEND en run.sh." })
            }
        }
    }
}
