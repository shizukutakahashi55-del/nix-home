pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string dir: Quickshell.env("OOZELOGIN_DIR") || "/var/lib/oozelogin"
  readonly property string cacheDir: Quickshell.env("OOZELOGIN_CACHE") || "/var/cache/oozelogin"
  readonly property string baseFile: Quickshell.env("OOZELOGIN_BASE") || ""
  readonly property bool preview: Quickshell.env("OOZELOGIN_PREVIEW") === "1"
  readonly property string configFile: root.dir + "/config.json"
  readonly property string syncFile: root.dir + "/sync.json"
  readonly property string stateFile: root.cacheDir + "/state.json"
  readonly property string wallDir: root.dir + "/wallpapers"

  readonly property var defaults: ({
    brand: "OozeLogin",
    subtitle: "greetd + Quickshell",
    tagline: "Un mejor mañana, empieza aquí",
    footerBrand: "OozeShell",
    language: "auto",
    font: "",
    uiScale: 100,
    themeSource: "custom",
    customColors: {
      bg: "#1b1516",
      surface: "#2a2022",
      primary: "#e8a984",
      onPrimary: "#2b1a10",
      text: "#f3e6dc",
      subtext: "#b9a294",
      error: "#ef7b7b"
    },
    wallpaperMode: "fixed",
    wallpaper: "",
    bgBlur: 0,
    bgDim: 30,
    panelBlur: true,
    panelOpacity: 52,
    panelRadius: 22,
    showTopBar: true,
    showInfoPanel: true,
    showClock: true,
    showWeather: true,
    showStats: true,
    showSessionPanel: true,
    showKeyboard: true,
    showPower: true,
    showUsers: true,
    showTagline: true,
    showFooter: true,
    showDots: true,
    labelBubbles: true,
    bubbleOpacity: 62,
    sessionPanelExpanded: false,
    clock24h: true,
    weatherCity: "",
    weatherFahrenheit: false,
    rememberUser: true,
    rememberSession: true,
    defaultSession: ""
  })

  property var base: ({})
  property var syncData: ({})
  property var overrides: ({})
  property var saved: ({})
  property bool loaded: false
  property bool writable: true
  property int wpPick: -1
  property int randomSeed: Math.floor(Math.random() * 1000000)
  property var wallpapers: []

  function merge(a, b) {
    const o = Object.assign({}, a)
    for (const k in b) {
      if (k === "customColors" && b[k] && typeof b[k] === "object") o[k] = Object.assign({}, a[k], b[k])
      else o[k] = b[k]
    }
    return o
  }

  readonly property var v: root.merge(root.merge(root.defaults, root.base), root.overrides)

  readonly property var colors: {
    const c = Object.assign({}, root.v.customColors)
    if (root.v.themeSource === "oozeshell" && root.syncData.colors)
      return Object.assign(c, root.syncData.colors)
    return c
  }

  readonly property color bg: root.colors.bg
  readonly property color surface: root.colors.surface
  readonly property color primary: root.colors.primary
  readonly property color onPrimary: root.colors.onPrimary
  readonly property color text: root.colors.text
  readonly property color subtext: root.colors.subtext
  readonly property color error: root.colors.error
  readonly property color textSoft: Qt.tint(root.text, Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.03))
  readonly property color iconSoft: Qt.tint(root.text, Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.22))

  readonly property string fontFamily: root.v.font !== "" ? root.v.font : Qt.application.font.family

  readonly property string currentWallpaper: {
    const list = root.wallpapers
    if (root.wpPick >= 0 && root.wpPick < list.length) return list[root.wpPick]
    const mode = root.v.wallpaperMode
    if (mode === "sync" && root.syncData.wallpaper) return root.syncData.wallpaper
    if (mode === "random" && list.length > 0) return list[root.randomSeed % list.length]
    if (root.v.wallpaper !== "" && list.indexOf(root.v.wallpaper) >= 0) return root.v.wallpaper
    return list.length > 0 ? list[0] : ""
  }

  readonly property string wallpaperUrl: root.currentWallpaper === "" ? "" : root.fileUrl(root.wallDir + "/" + root.currentWallpaper)

  function fileUrl(path) {
    if (!path) return ""
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  function avatarUrl(path) { return root.fileUrl(path) }

  function set(key, value) {
    const o = Object.assign({}, root.overrides)
    o[key] = value
    root.overrides = o
    root.saveConfig()
  }

  function setColor(name, hex) {
    const cur = Object.assign({}, root.overrides.customColors || {})
    cur[name] = hex
    root.set("customColors", cur)
  }

  function reload() {
    if (!loader.running) loader.running = true
    wallScan.running = false
    wallScan.running = true
  }

  function saveConfig() {
    saver.json = JSON.stringify(root.overrides)
    saver.target = root.configFile
    saver.targetDir = root.dir
    if (saver.running) saver.pending = true
    else saver.running = true
  }

  function setState(key, value) {
    const s = Object.assign({}, root.saved)
    s[key] = value
    root.saved = s
    stateSaver.json = JSON.stringify(s)
    if (stateSaver.running) stateSaver.pending = true
    else stateSaver.running = true
  }

  Component.onCompleted: root.reload()

  Process {
    id: loader
    command: ["sh", "-c",
      'for f in "$1" "$2" "$3" "$4"; do [ -n "$f" ] && cat "$f" 2>/dev/null; printf "\\n##SEP##\\n"; done; [ -w "$5" ] && echo "##W1##" || echo "##W0##"',
      "sh", root.baseFile, root.syncFile, root.configFile, root.stateFile, root.dir]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = this.text.split("##SEP##")
        const parse = s => {
          const t = String(s || "").trim()
          if (t === "" || t.indexOf("##W") === 0) return {}
          try {
            const j = JSON.parse(t)
            return (j && typeof j === "object") ? j : {}
          } catch (e) { return {} }
        }
        root.base = parse(parts[0])
        root.syncData = parse(parts[1])
        root.overrides = parse(parts[2])
        root.saved = parse(parts[3])
        root.writable = String(parts[4] || "").indexOf("##W1##") >= 0
        root.loaded = true
      }
    }
  }

  Process {
    id: wallScan
    command: ["sh", "-c",
      'for f in "$1"/*; do [ -f "$f" ] || continue; case "${f##*.}" in jpg|jpeg|png|webp|bmp|avif|JPG|JPEG|PNG|WEBP) echo "${f##*/}";; esac; done | sort',
      "sh", root.wallDir]
    stdout: StdioCollector {
      onStreamFinished: {
        const t = this.text.trim()
        root.wallpapers = t === "" ? [] : t.split("\n")
      }
    }
  }

  Process {
    id: saver
    property string json: ""
    property string target: ""
    property string targetDir: ""
    property bool pending: false
    command: ["sh", "-c", 'mkdir -p "$1" && printf %s "$3" > "$2.tmp" && mv -f "$2.tmp" "$2"', "sh", saver.targetDir, saver.target, saver.json]
    onRunningChanged: {
      if (!running && saver.pending) { saver.pending = false; saver.running = true }
    }
  }

  Process {
    id: stateSaver
    property string json: ""
    property bool pending: false
    command: ["sh", "-c", 'mkdir -p "$1" && printf %s "$3" > "$2.tmp" && mv -f "$2.tmp" "$2"', "sh", root.cacheDir, root.stateFile, stateSaver.json]
    onRunningChanged: {
      if (!running && stateSaver.pending) { stateSaver.pending = false; stateSaver.running = true }
    }
  }
}
