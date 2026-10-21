pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string sessionsDir: Quickshell.env("OOZELOGIN_SESSIONS") || "/run/current-system/sw/share/wayland-sessions"
  readonly property string compositor: Quickshell.env("OOZELOGIN_COMPOSITOR") || ""
  readonly property var layouts: {
    const raw = String(Quickshell.env("OOZELOGIN_LAYOUTS") || "").trim()
    return raw === "" ? [] : raw.split(",").map(s => s.trim()).filter(s => s !== "")
  }

  property bool active: false
  property bool capsLock: false
  property int cpu: 0
  property real ramUsed: 0
  property real ramTotal: 0
  property int gpu: -1
  property int battery: -1
  property string batteryStatus: ""
  readonly property bool hasBattery: root.battery >= 0
  readonly property bool charging: root.batteryStatus === "Charging" || root.batteryStatus === "Full"
  readonly property bool hasGpu: root.gpu >= 0

  property var users: []
  property var sessions: []
  property bool usersLoaded: false
  property bool sessionsLoaded: false
  property int layoutIndex: 0

  property bool weatherOk: false
  property real weatherTemp: 0
  property int weatherCode: 0
  property real weatherLat: 0
  property real weatherLon: 0
  property string weatherCityResolved: ""

  readonly property var weatherInfo: root.describeWeather(root.weatherCode)

  function describeWeather(code) {
    if (code === 0) return { glyph: Glyph.sunny, key: "wxClear" }
    if (code === 1 || code === 2) return { glyph: Glyph.partly, key: "wxPartly" }
    if (code === 3) return { glyph: Glyph.cloudy, key: "wxCloudy" }
    if (code === 45 || code === 48) return { glyph: Glyph.fog, key: "wxFog" }
    if (code >= 51 && code <= 57) return { glyph: Glyph.rainy, key: "wxDrizzle" }
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) return { glyph: Glyph.pouring, key: "wxRain" }
    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return { glyph: Glyph.snowy, key: "wxSnow" }
    if (code >= 95) return { glyph: Glyph.storm, key: "wxStorm" }
    return { glyph: Glyph.cloudy, key: "wxCloudy" }
  }

  function reloadUsers() {
    usersProc.running = false
    usersProc.running = true
  }

  function reboot() { powerProc.command = ["systemctl", "reboot"]; powerProc.running = true }
  function poweroff() { powerProc.command = ["systemctl", "poweroff"]; powerProc.running = true }

  function cycleLayout() {
    if (root.layouts.length < 2) return
    root.layoutIndex = (root.layoutIndex + 1) % root.layouts.length
    if (root.compositor === "hyprland")
      layoutProc.command = ["hyprctl", "switchxkblayout", "all", String(root.layoutIndex)]
    else if (root.compositor === "niri")
      layoutProc.command = ["niri", "msg", "action", "switch-layout", String(root.layoutIndex)]
    else
      return
    layoutProc.running = false
    layoutProc.running = true
  }

  function refreshWeather() {
    const city = String(Config.v.weatherCity || "").trim()
    if (!root.active || city === "" || !Config.v.showWeather || !Config.v.showInfoPanel) { root.weatherOk = false; return }
    if (root.weatherCityResolved === city && root.weatherLat !== 0) { wxProc.running = false; wxProc.running = true; return }
    geoProc.running = false
    geoProc.running = true
  }

  readonly property string weatherSig: Config.v.weatherCity + "|" + Config.v.weatherFahrenheit + "|" + Config.v.showWeather + "|" + Config.v.showInfoPanel
  onWeatherSigChanged: { if (Config.loaded) root.refreshWeather() }
  onActiveChanged: { if (root.active && Config.loaded) root.refreshWeather() }

  Connections {
    target: Config
    function onLoadedChanged() { if (Config.loaded) root.refreshWeather() }
  }

  Timer {
    interval: 1800000
    running: true
    repeat: true
    onTriggered: root.refreshWeather()
  }

  Process {
    id: powerProc
  }

  Process {
    id: layoutProc
  }

  Process {
    id: geoProc
    command: ["curl", "-fsS", "--max-time", "8",
      "https://geocoding-api.open-meteo.com/v1/search?count=1&format=json&name=" + encodeURIComponent(String(Config.v.weatherCity || "").trim())]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const j = JSON.parse(this.text)
          if (j.results && j.results.length > 0) {
            root.weatherLat = j.results[0].latitude
            root.weatherLon = j.results[0].longitude
            root.weatherCityResolved = String(Config.v.weatherCity || "").trim()
            wxProc.running = false
            wxProc.running = true
          }
        } catch (e) {}
      }
    }
  }

  Process {
    id: wxProc
    command: ["curl", "-fsS", "--max-time", "8",
      "https://api.open-meteo.com/v1/forecast?latitude=" + root.weatherLat + "&longitude=" + root.weatherLon
      + "&current=temperature_2m,weather_code&temperature_unit=" + (Config.v.weatherFahrenheit ? "fahrenheit" : "celsius")]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const j = JSON.parse(this.text)
          root.weatherTemp = j.current.temperature_2m
          root.weatherCode = j.current.weather_code
          root.weatherOk = true
        } catch (e) {}
      }
    }
  }

  Process {
    id: capsProc
    running: root.active
    command: ["sh", "-c", [
      'last=x',
      'while :; do',
      '  s=0',
      '  for f in /sys/class/leds/*::capslock/brightness; do',
      '    [ -r "$f" ] || continue',
      '    read -r v < "$f"',
      '    [ "$v" != 0 ] && s=1',
      '  done',
      '  [ "$s" != "$last" ] && { echo "$s"; last=$s; }',
      '  sleep 0.3',
      'done'
    ].join("\n")]
    stdout: SplitParser {
      onRead: line => { root.capsLock = line.trim() === "1" }
    }
  }

  Process {
    id: statsProc
    running: root.active && (Config.v.showStats || Config.v.showTopBar)
    command: ["sh", "-c", [
      'pt=0; pi=0',
      'while :; do',
      '  read -r _ a b c d e f g h _ < /proc/stat',
      '  t=$((a+b+c+d+e+f+g+h)); i=$((d+e))',
      '  dt=$((t-pt)); di=$((i-pi)); pt=$t; pi=$i',
      '  cpu=0; [ "$dt" -gt 0 ] && cpu=$(( (dt-di)*100/dt ))',
      '  set -- $(awk \'/^MemTotal:/{t=$2}/^MemAvailable:/{a=$2}END{print t,a}\' /proc/meminfo)',
      '  mt=$1; ma=$2',
      '  gpu=-1',
      '  for f in /sys/class/drm/card*/device/gpu_busy_percent; do [ -r "$f" ] && { gpu=$(cat "$f"); break; }; done',
      '  if [ "$gpu" = -1 ] && command -v nvidia-smi >/dev/null 2>&1; then',
      '    g=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)',
      '    [ -n "$g" ] && gpu=$g',
      '  fi',
      '  bp=-1; bs=""',
      '  for b in /sys/class/power_supply/BAT*; do [ -r "$b/capacity" ] && { bp=$(cat "$b/capacity"); bs=$(cat "$b/status" 2>/dev/null); break; }; done',
      '  echo "$cpu|$mt|$ma|$gpu|$bp|$bs"',
      '  sleep 2',
      'done'
    ].join("\n")]
    stdout: SplitParser {
      onRead: line => {
        const p = line.split("|")
        if (p.length < 6) return
        root.cpu = Math.max(0, Math.min(100, parseInt(p[0]) || 0))
        const total = (parseInt(p[1]) || 0) / 1048576
        const avail = (parseInt(p[2]) || 0) / 1048576
        root.ramTotal = total
        root.ramUsed = Math.max(0, total - avail)
        root.gpu = parseInt(p[3])
        root.battery = parseInt(p[4])
        root.batteryStatus = String(p[5]).trim()
      }
    }
  }

  Process {
    id: usersProc
    running: true
    command: ["sh", "-c", [
      'D="$1"',
      'getent passwd | awk -F: \'$3>=1000 && $3<60000 && $7!~/(nologin|false)$/ {print $1"|"$5"|"$6}\' | while IFS="|" read -r u g h; do',
      '  a=""',
      '  for p in "$D"/avatars/"$u".* "/var/lib/AccountsService/icons/$u" "$h/.face"; do [ -r "$p" ] && [ -f "$p" ] && { a="$p"; break; }; done',
      '  echo "$u|${g%%,*}|$a"',
      'done'
    ].join("\n"), "sh", Config.dir]
    stdout: StdioCollector {
      onStreamFinished: {
        const out = []
        for (const line of this.text.trim().split("\n")) {
          if (line === "") continue
          const p = line.split("|")
          out.push({ name: p[0], real: p[1] || "", avatar: p[2] || "" })
        }
        root.users = out
        root.usersLoaded = true
      }
    }
  }

  Process {
    id: sessionsProc
    running: true
    command: ["sh", "-c", [
      'for f in "$1"/*.desktop; do',
      '  [ -r "$f" ] || continue',
      '  n=$(sed -n "s/^Name=//p" "$f" | head -n1)',
      '  d=$(sed -n "s/^DesktopNames=//p" "$f" | head -n1)',
      '  e=$(sed -n "s/^Exec=//p" "$f" | head -n1)',
      '  [ -n "$e" ] && echo "${f##*/}|$n|$d|$e"',
      'done'
    ].join("\n"), "sh", root.sessionsDir]
    stdout: StdioCollector {
      onStreamFinished: {
        const out = []
        for (const line of this.text.trim().split("\n")) {
          if (line === "") continue
          const i1 = line.indexOf("|")
          const i2 = line.indexOf("|", i1 + 1)
          const i3 = line.indexOf("|", i2 + 1)
          out.push({ id: line.slice(0, i1), name: line.slice(i1 + 1, i2), desktop: line.slice(i2 + 1, i3), exec: line.slice(i3 + 1) })
        }
        if (out.length === 0 && Config.preview) {
          out.push({ id: "hyprland.desktop", name: "Hyprland", desktop: "Hyprland", exec: "Hyprland" })
          out.push({ id: "niri.desktop", name: "Niri", desktop: "niri", exec: "niri-session" })
          out.push({ id: "mango.desktop", name: "MangoWC", desktop: "mango", exec: "mango" })
        }
        root.sessions = out
        root.sessionsLoaded = true
      }
    }
  }
}
