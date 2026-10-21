import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Core"

Rectangle {

  antialiasing: true
  id: root

  property real u: 1

  height: 52 * u
  color: Qt.rgba(Config.bg.r, Config.bg.g, Config.bg.b, 0.55)

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Rectangle {

    antialiasing: true
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 1
    color: Qt.rgba(1, 1, 1, 0.06)
  }

  RowLayout {
    anchors.left: parent.left
    anchors.leftMargin: 32 * root.u
    anchors.verticalCenter: parent.verticalCenter
    spacing: 14 * root.u

    Icon {
      glyph: Glyph.leaf
      color: Config.primary
      font.pixelSize: 26 * root.u
    }
    Label {
      text: Config.v.brand
      font.pixelSize: 18 * root.u
      font.weight: Font.Medium
    }
    Rectangle {
      antialiasing: true
      visible: Config.v.subtitle !== ""
      Layout.preferredWidth: 1
      Layout.preferredHeight: 20 * root.u
      color: Qt.rgba(1, 1, 1, 0.18)
    }
    Label {
      visible: Config.v.subtitle !== ""
      text: Config.v.subtitle
      font.pixelSize: 15 * root.u
      color: Config.subtext
    }
  }

  RowLayout {
    anchors.right: parent.right
    anchors.rightMargin: 32 * root.u
    anchors.verticalCenter: parent.verticalCenter
    spacing: 16 * root.u

    RowLayout {
      visible: Sys.hasBattery
      spacing: 8 * root.u
      Icon {
        glyph: Sys.charging ? Glyph.batteryCharging : (Sys.battery < 15 ? Glyph.batteryLow : Glyph.battery)
        font.pixelSize: 22 * root.u
        color: Sys.battery < 15 && !Sys.charging ? Config.error : Config.text
      }
      Label {
        text: Sys.battery + "%"
        font.pixelSize: 15 * root.u
      }
    }

    Rectangle {

      antialiasing: true
      visible: Sys.hasBattery
      Layout.preferredWidth: 1
      Layout.preferredHeight: 20 * root.u
      color: Qt.rgba(1, 1, 1, 0.18)
    }

    Label {
      text: Strings.shortDate(clock.date)
      font.pixelSize: 15 * root.u
    }

    Label {
      text: Strings.time(clock.date, Config.v.clock24h)
      font.pixelSize: 15 * root.u
    }
  }
}
