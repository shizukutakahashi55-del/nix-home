import QtQuick
import "../Core"

Row {
  id: root

  property real u: 1
  readonly property int activeIndex: {
    if (Config.wpPick >= 0) return Config.wpPick
    return Math.max(0, Config.wallpapers.indexOf(Config.currentWallpaper))
  }

  spacing: 14 * u
  visible: Config.v.showDots && Config.wallpapers.length > 1

  Repeater {
    model: Config.wallpapers.length

    delegate: Rectangle {
      required property int index
      width: 10 * root.u
      height: 10 * root.u
      radius: width / 2
      color: index === root.activeIndex ? Config.primary : Qt.rgba(1, 1, 1, 0.28)

      Behavior on color { ColorAnimation { duration: 150 } }

      MouseArea {
        anchors.fill: parent
        anchors.margins: -6 * root.u
        cursorShape: Qt.PointingHandCursor
        onClicked: Config.wpPick = index
      }
    }
  }
}
