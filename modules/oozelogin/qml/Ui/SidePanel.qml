import QtQuick
import QtQuick.Layouts
import "../Core"

Glass {
  id: root

  property real u: 1
  readonly property real pad: 14 * u
  property string armed: ""
  property bool expanded: false

  readonly property real headerHeight: 46 * u
  readonly property string currentSessionName: {
    for (const s of Sys.sessions) if (s.id === Auth.sessionId) return s.name
    return Strings.t("noSessions")
  }
  readonly property string langName: {
    for (const l of Strings.languages) if (l.code === Strings.lang) return l.name
    return Strings.lang
  }

  width: root.expanded ? 300 * u : 250 * u
  height: root.expanded ? col.implicitHeight + pad * 2 : headerHeight + pad * 2
  clip: true

  Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  function collapse() { root.expanded = false }

  onExpandedChanged: { if (!root.expanded) root.armed = "" }

  Component.onCompleted: root.expanded = Config.v.sessionPanelExpanded

  Connections {
    target: Config
    function onLoadedChanged() { if (Config.loaded) root.expanded = Config.v.sessionPanelExpanded }
  }

  Timer {
    id: disarm
    interval: 3000
    onTriggered: root.armed = ""
  }

  function press(kind) {
    if (root.armed === kind) {
      root.armed = ""
      if (kind === "restart") Sys.reboot()
      else Sys.poweroff()
      return
    }
    root.armed = kind
    disarm.restart()
  }

  function cycleLanguage() {
    const list = Strings.languages
    let i = 0
    for (let k = 0; k < list.length; k++) if (list[k].code === Strings.lang) i = k
    Strings.runtimeLang = list[(i + 1) % list.length].code
  }

  ColumnLayout {
    id: col
    x: root.pad
    y: root.pad
    width: root.width - root.pad * 2
    spacing: 4 * root.u

    Rectangle {

      antialiasing: true
      id: header
      Layout.fillWidth: true
      Layout.preferredHeight: root.headerHeight
      radius: 10 * root.u
      color: headerArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"

      Behavior on color { ColorAnimation { duration: 120 } }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12 * root.u
        anchors.rightMargin: 12 * root.u
        spacing: 14 * root.u

        Icon {
          glyph: Glyph.monitor
          font.pixelSize: 22 * root.u
          color: Config.iconSoft
          Layout.preferredWidth: 26 * root.u
        }

        Label {
          text: root.expanded ? Strings.t("session") : root.currentSessionName
          font.pixelSize: 16 * root.u
          font.weight: root.expanded ? Font.Medium : Font.Normal
          color: Config.textSoft
          Layout.fillWidth: true
        }

        Icon {
          glyph: Glyph.chevron
          font.pixelSize: 18 * root.u
          color: Config.iconSoft
          rotation: root.expanded ? -90 : 90
          Behavior on rotation { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
      }

      MouseArea {
        id: headerArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
      }
    }

    ColumnLayout {
      id: body
      Layout.fillWidth: true
      spacing: 4 * root.u
      opacity: root.expanded ? 1 : 0
      enabled: root.expanded

      Behavior on opacity { NumberAnimation { duration: 140 } }

      Repeater {
        model: Sys.sessions

        delegate: PanelRow {
          required property var modelData
          Layout.fillWidth: true
          u: root.u
          glyph: Glyph.monitor
          text: modelData.name
          selected: modelData.id === Auth.sessionId
          onClicked: { Auth.pickSession(modelData.id, modelData.exec); root.collapse() }
        }
      }

      Label {
        visible: Sys.sessions.length === 0
        Layout.leftMargin: 12 * root.u
        text: Strings.t("noSessions")
        font.pixelSize: 15 * root.u
        color: Config.textSoft
      }

      Rectangle {

        antialiasing: true
        visible: Config.v.showKeyboard || Config.v.showPower
        Layout.fillWidth: true
        Layout.topMargin: 10 * root.u
        Layout.bottomMargin: 6 * root.u
        Layout.leftMargin: 12 * root.u
        Layout.rightMargin: 12 * root.u
        height: 1
        color: Qt.rgba(1, 1, 1, 0.14)
      }

      Label {
        visible: Config.v.showKeyboard
        Layout.leftMargin: 12 * root.u
        Layout.topMargin: 4 * root.u
        Layout.bottomMargin: 6 * root.u
        text: Strings.t("langKeyboard")
        font.pixelSize: 15 * root.u
        font.weight: Font.Medium
        color: Config.textSoft
      }

      PanelRow {
        visible: Config.v.showKeyboard
        Layout.fillWidth: true
        u: root.u
        glyph: Glyph.globe
        text: root.langName
        onClicked: root.cycleLanguage()
      }

      PanelRow {
        visible: Config.v.showKeyboard && Sys.layouts.length > 0
        Layout.fillWidth: true
        u: root.u
        glyph: Glyph.keyboard
        text: Strings.layoutName(Sys.layouts[Sys.layoutIndex] || "")
        onClicked: Sys.cycleLayout()
      }

      Rectangle {

        antialiasing: true
        visible: Config.v.showKeyboard && Config.v.showPower
        Layout.fillWidth: true
        Layout.topMargin: 10 * root.u
        Layout.bottomMargin: 6 * root.u
        Layout.leftMargin: 12 * root.u
        Layout.rightMargin: 12 * root.u
        height: 1
        color: Qt.rgba(1, 1, 1, 0.14)
      }

      PanelRow {
        visible: Config.v.showPower
        Layout.fillWidth: true
        u: root.u
        chevron: false
        glyph: Glyph.restart
        text: root.armed === "restart" ? Strings.t("sure") : Strings.t("restart")
        danger: root.armed === "restart"
        onClicked: root.press("restart")
      }

      PanelRow {
        visible: Config.v.showPower
        Layout.fillWidth: true
        u: root.u
        chevron: false
        glyph: Glyph.power
        text: root.armed === "shutdown" ? Strings.t("sure") : Strings.t("shutdown")
        danger: root.armed === "shutdown"
        onClicked: root.press("shutdown")
      }
    }
  }
}
