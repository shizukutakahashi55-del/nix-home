import QtQuick
import "../Core"
import "../Ui"

Item {
  id: root

  property int from: 0
  property int to: 100
  property int value: 0
  property string suffix: ""
  signal moved(int newValue)

  width: 260
  height: 30

  readonly property real ratio: (root.value - root.from) / Math.max(1, root.to - root.from)

  function setFromX(x) {
    const r = Math.max(0, Math.min(1, x / track.width))
    const v = Math.round(root.from + r * (root.to - root.from))
    if (v !== root.value) root.moved(v)
  }

  Rectangle {

    antialiasing: true
    id: track
    anchors.left: parent.left
    anchors.right: valueLabel.left
    anchors.rightMargin: 14
    anchors.verticalCenter: parent.verticalCenter
    height: 4
    radius: 2
    color: Qt.rgba(1, 1, 1, 0.14)

    Rectangle {

      antialiasing: true
      width: parent.width * root.ratio
      height: parent.height
      radius: 2
      color: Config.primary
    }

    Rectangle {

      antialiasing: true
      x: parent.width * root.ratio - width / 2
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      radius: 8
      color: Config.primary
      border.width: 3
      border.color: Config.bg
    }

    MouseArea {
      anchors.fill: parent
      anchors.topMargin: -12
      anchors.bottomMargin: -12
      cursorShape: Qt.PointingHandCursor
      onPressed: mouse => root.setFromX(mouse.x)
      onPositionChanged: mouse => { if (pressed) root.setFromX(mouse.x) }
    }
  }

  Label {
    id: valueLabel
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: 46
    horizontalAlignment: Text.AlignRight
    text: root.value + root.suffix
    font.pixelSize: 13
    color: Config.subtext
  }
}
