pragma Singleton
import Quickshell
import Quickshell.Services.Greetd
import QtQuick

Singleton {
  id: root

  readonly property bool live: !Config.preview && !!Quickshell.env("GREETD_SOCK")

  property string username: ""
  property string sessionId: ""
  property string sessionExec: ""
  property string input: ""
  property string prompt: ""
  property bool promptEcho: false
  property bool awaiting: false
  property bool busy: false
  property bool failed: false
  property bool launching: false
  property string message: ""
  property int failCount: 0
  property bool firstAnswered: false

  readonly property string statusText: {
    if (root.launching) return Strings.t("starting")
    if (root.busy) return Strings.t("checking")
    if (root.message !== "") return root.message
    return ""
  }

  function applySession() {
    const list = Sys.sessions
    if (list.length === 0) { root.sessionId = ""; root.sessionExec = ""; return }
    const remembered = (Config.saved.sessions || {})[root.username]
    const wanted = String(Config.v.defaultSession || "").toLowerCase()
    let pick = null
    if (Config.v.rememberSession && remembered) pick = list.find(s => s.id === remembered)
    if (!pick && wanted !== "")
      pick = list.find(s => s.id.toLowerCase() === wanted || s.id.toLowerCase() === wanted + ".desktop" || s.name.toLowerCase() === wanted)
    if (!pick) pick = list[0]
    root.sessionId = pick.id
    root.sessionExec = pick.exec
  }

  function bootstrap() {
    const users = Sys.users
    let name = ""
    if (users.length > 0) {
      const last = Config.v.rememberUser ? Config.saved.lastUser : ""
      const hit = users.find(u => u.name === last)
      name = hit ? hit.name : users[0].name
    }
    root.username = name
    root.applySession()
  }

  function select(name) {
    if (root.busy) return
    root.username = name
    root.applySession()
    root.input = ""
    root.failed = false
    root.message = ""
    root.awaiting = false
    root.prompt = ""
    if (Config.v.rememberUser && !Config.preview) Config.setState("lastUser", name)
  }

  function pickSession(id, exec) {
    root.sessionId = id
    root.sessionExec = exec
    if (Config.v.rememberSession && !Config.preview && root.username !== "") {
      const map = Object.assign({}, Config.saved.sessions || {})
      map[root.username] = id
      Config.setState("sessions", map)
    }
  }

  function submit() {
    if (root.busy || root.launching || root.username === "") return
    root.failed = false
    root.message = ""
    if (root.awaiting) {
      root.awaiting = false
      root.busy = true
      const answer = root.input
      root.input = ""
      if (root.live) Greetd.respond(answer)
      else mock.restart()
      return
    }
    root.busy = true
    root.firstAnswered = false
    if (root.live) Greetd.createSession(root.username)
    else mock.restart()
  }

  function clear() {
    root.input = ""
    root.failed = false
    root.message = ""
  }

  function fail(text) {
    root.busy = false
    root.launching = false
    root.input = ""
    root.awaiting = false
    root.prompt = ""
    root.message = text
    root.failed = true
    root.failCount++
    failTimer.restart()
  }

  function launch() {
    root.launching = true
    root.busy = false
    const id = root.sessionId.replace(/\.desktop$/, "")
    const entry = Sys.sessions.find(s => s.id === root.sessionId)
    const names = entry && entry.desktop ? entry.desktop.split(";").filter(x => x !== "").join(":") : ""
    const env = [
      "XDG_SESSION_TYPE=wayland",
      "XDG_SESSION_DESKTOP=" + id
    ]
    if (names !== "") env.push("XDG_CURRENT_DESKTOP=" + names)
    Greetd.launch([root.sessionExec], env, true)
  }

  Timer {
    id: failTimer
    interval: 3000
    onTriggered: { root.failed = false; if (!root.busy && !root.awaiting) root.message = "" }
  }

  Timer {
    id: mock
    interval: 700
    onTriggered: {
      if (root.input === "ooze") {
        root.input = ""
        root.busy = false
        root.launching = true
        mockEnd.restart()
      } else {
        root.fail(Strings.t("wrong"))
      }
    }
  }

  Timer {
    id: mockEnd
    interval: 1500
    onTriggered: root.launching = false
  }

  Connections {
    target: Greetd

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      if (responseRequired) {
        if (!root.firstAnswered) {
          root.firstAnswered = true
          const answer = root.input
          root.input = ""
          Greetd.respond(answer)
        } else {
          root.prompt = message
          root.promptEcho = echoResponse
          root.awaiting = true
          root.busy = false
          root.input = ""
        }
      } else {
        root.message = message
        Greetd.respond("")
      }
    }

    function onAuthFailure(message) {
      Greetd.cancelSession()
      root.fail(message !== "" ? message : Strings.t("wrong"))
    }

    function onReadyToLaunch() {
      root.launch()
    }
  }
}
