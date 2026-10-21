import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Rectangle {

  antialiasing: true
  id: root

  property int index: 0
  readonly property var pages: [
    { glyph: Glyph.palette, label: "navAppearance" },
    { glyph: Glyph.dashboard, label: "navInterface" },
    { glyph: Glyph.users, label: "navAccess" },
    { glyph: Glyph.sunny, label: "navWeather" },
    { glyph: Glyph.sync, label: "navOozeShell" }
  ]

  color: Qt.darker(Config.bg, 1.25)

  Process {
    id: previewProc
    command: ["sh", "-c", 'OOZELOGIN_PREVIEW=1 exec "$1" -p "$2"', "sh",
      Quickshell.env("OOZELOGIN_QS") || "qs", Quickshell.shellPath("shell.qml")]
  }

  Rectangle {

    antialiasing: true
    id: side
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: 230
    color: Qt.rgba(1, 1, 1, 0.025)

    Row {
      id: brand
      x: 24
      y: 26
      spacing: 12
      Icon {
        glyph: Glyph.leaf
        color: Config.primary
        font.pixelSize: 28
      }
      Label {
        anchors.verticalCenter: parent.verticalCenter
        text: "OozeLogin"
        font.pixelSize: 19
        font.weight: Font.Medium
      }
    }

    Column {
      anchors.top: brand.bottom
      anchors.topMargin: 28
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 12
      spacing: 4

      Repeater {
        model: root.pages

        delegate: Rectangle {
          required property var modelData
          required property int index
          width: parent.width
          height: 42
          radius: 10
          color: root.index === index ? Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.18)
                                      : (navArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

          Row {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Icon {
              glyph: modelData.glyph
              font.pixelSize: 20
              color: root.index === index ? Config.primary : Config.subtext
              anchors.verticalCenter: parent.verticalCenter
            }
            Label {
              text: Strings.t(modelData.label)
              font.pixelSize: 15
              color: root.index === index ? Config.text : Config.subtext
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: navArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.index = index
          }
        }
      }
    }
  }

  Item {
    anchors.left: side.right
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Rectangle {

      antialiasing: true
      id: header
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: 72
      color: "transparent"

      Label {
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        text: Strings.t(root.pages[root.index].label)
        font.pixelSize: 24
        font.weight: Font.Light
      }

      Row {
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Button {
          glyph: Glyph.sync
          text: Strings.t("reload")
          onClicked: Config.reload()
        }
        Button {
          primary: true
          glyph: Glyph.play
          text: Strings.t("preview")
          onClicked: { previewProc.running = false; previewProc.running = true }
        }
      }
    }

    Rectangle {

      antialiasing: true
      id: warn
      visible: Config.loaded && !Config.writable
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: header.bottom
      anchors.leftMargin: 32
      anchors.rightMargin: 32
      height: visible ? 44 : 0
      radius: 10
      color: Qt.rgba(Config.error.r, Config.error.g, Config.error.b, 0.16)
      border.width: 1
      border.color: Qt.rgba(Config.error.r, Config.error.g, Config.error.b, 0.5)

      Label {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        text: Strings.t("notWritable").replace("{dir}", Config.dir)
        font.pixelSize: 13
        color: Config.error
      }
    }

    StackLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: warn.visible ? warn.bottom : header.bottom
      anchors.topMargin: warn.visible ? 12 : 0
      anchors.bottom: parent.bottom
      currentIndex: root.index

      AppearancePage {}
      InterfacePage {}
      AccessPage {}
      WeatherPage {}
      OozeShellPage {}
    }
  }
}
