import Quickshell
import QtQuick
import "Core"
import "Settings"

ShellRoot {
  FloatingWindow {
    title: Strings.t("settingsTitle")
    implicitWidth: 1080
    implicitHeight: 740
    color: Qt.darker(Config.bg, 1.25)
    onVisibleChanged: { if (!visible) Qt.quit() }

    SettingsView {
      anchors.fill: parent
    }
  }
}
