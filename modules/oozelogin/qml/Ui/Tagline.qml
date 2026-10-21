import QtQuick
import QtQuick.Layouts
import "../Core"

RowLayout {
  id: root

  property real u: 1

  spacing: 26 * u
  visible: Config.v.showTagline && Config.v.tagline !== ""

  Rectangle {

    antialiasing: true
    Layout.preferredWidth: 64 * root.u
    Layout.preferredHeight: 1
    color: Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.55)
  }

  Pill {
    u: root.u
    text: Config.v.tagline.toUpperCase()
    pixelSize: 13
    letterSpacing: 4
    textColor: Qt.tint(Config.text, Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.4))
    opacityBoost: -0.2
  }

  Rectangle {

    antialiasing: true
    Layout.preferredWidth: 64 * root.u
    Layout.preferredHeight: 1
    color: Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.55)
  }
}
