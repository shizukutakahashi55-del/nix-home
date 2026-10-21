import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Core"

Glass {
  id: root

  property real u: 1
  readonly property real pad: 26 * u

  width: 300 * u
  height: col.implicitHeight + pad * 2

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  ColumnLayout {
    id: col
    x: root.pad
    y: root.pad
    width: root.width - root.pad * 2
    spacing: 8 * root.u

    Label {
      visible: Config.v.showClock
      text: Strings.time(clock.date, Config.v.clock24h)
      font.pixelSize: 84 * root.u
      font.weight: Font.Thin
      color: Qt.tint(Config.text, Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.38))
      Layout.fillWidth: true
    }

    Label {
      visible: Config.v.showClock
      text: Strings.longDate(clock.date)
      font.pixelSize: 19 * root.u
      Layout.fillWidth: true
    }

    RowLayout {
      visible: Config.v.showWeather && Sys.weatherOk
      Layout.topMargin: 14 * root.u
      spacing: 14 * root.u

      Icon {
        glyph: Sys.weatherInfo.glyph
        font.pixelSize: 32 * root.u
        color: Config.text
      }
      ColumnLayout {
        spacing: 0
        Label {
          text: Math.round(Sys.weatherTemp) + (Config.v.weatherFahrenheit ? "°F" : "°C")
          font.pixelSize: 17 * root.u
        }
        Label {
          text: Strings.t(Sys.weatherInfo.key)
          font.pixelSize: 13 * root.u
          color: Config.subtext
        }
      }
    }

    Rectangle {

      antialiasing: true
      visible: Config.v.showStats && (Config.v.showClock || (Config.v.showWeather && Sys.weatherOk))
      Layout.fillWidth: true
      Layout.topMargin: 12 * root.u
      Layout.bottomMargin: 4 * root.u
      height: 1
      color: Qt.rgba(1, 1, 1, 0.10)
    }

    ColumnLayout {
      visible: Config.v.showStats
      Layout.fillWidth: true
      spacing: 8 * root.u

      StatRow {
        u: root.u
        glyph: Glyph.cpu
        label: Strings.t("cpu")
        valueText: Sys.cpu + "%"
        fraction: Sys.cpu / 100
        Layout.fillWidth: true
      }
      StatRow {
        u: root.u
        glyph: Glyph.memory
        label: Strings.t("ram")
        valueText: Sys.ramUsed.toFixed(1) + " / " + Sys.ramTotal.toFixed(1) + " GB"
        fraction: Sys.ramTotal > 0 ? Sys.ramUsed / Sys.ramTotal : 0
        Layout.fillWidth: true
      }
      StatRow {
        visible: Sys.hasGpu
        u: root.u
        glyph: Glyph.gpu
        label: Strings.t("gpu")
        valueText: Sys.gpu + "%"
        fraction: Sys.gpu / 100
        Layout.fillWidth: true
      }
      StatRow {
        visible: Sys.hasBattery
        u: root.u
        glyph: Sys.charging ? Glyph.batteryCharging : Glyph.battery
        label: Strings.t("battery")
        valueText: Sys.battery + "%"
        fraction: Sys.battery / 100
        Layout.fillWidth: true
      }
    }
  }
}
