import QtQuick
import "../Core"

Rectangle {

  antialiasing: true
  id: root

  property real u: 1
  property string text: ""
  property real pixelSize: 14
  property int weight: Font.Normal
  property real letterSpacing: 0
  property color textColor: Config.text
  property color tint: "transparent"
  property real tintAmount: 0
  property real opacityBoost: 0

  readonly property bool bubble: Config.v.labelBubbles
  readonly property real fillAlpha: Math.max(0, Math.min(0.95, Config.v.bubbleOpacity / 100 + root.opacityBoost))
  readonly property color fill: Qt.rgba(
    Config.bg.r * (1 - root.tintAmount) + root.tint.r * root.tintAmount,
    Config.bg.g * (1 - root.tintAmount) + root.tint.g * root.tintAmount,
    Config.bg.b * (1 - root.tintAmount) + root.tint.b * root.tintAmount,
    1)

  visible: root.text !== ""
  implicitWidth: label.implicitWidth + 36 * root.u
  implicitHeight: label.implicitHeight + 14 * root.u
  radius: height / 2
  color: root.bubble ? Qt.rgba(root.fill.r, root.fill.g, root.fill.b, root.fillAlpha) : "transparent"
  border.width: root.bubble ? 1 : 0
  border.color: root.tintAmount > 0 ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.55) : Qt.rgba(1, 1, 1, 0.10)

  Behavior on color { ColorAnimation { duration: 150 } }

  Label {
    id: label
    anchors.centerIn: parent
    width: Math.min(implicitWidth, root.width - 36 * root.u)
    text: root.text
    color: root.textColor
    font.pixelSize: root.pixelSize * root.u
    font.weight: root.weight
    font.letterSpacing: root.letterSpacing * root.u
    horizontalAlignment: Text.AlignHCenter
    style: root.bubble ? Text.Normal : Text.Outline
    styleColor: Qt.rgba(0, 0, 0, 0.6)
  }
}
