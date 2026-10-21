import QtQuick
import QtQuick.Layouts
import "../Core"

Item {
  id: root

  property real u: 1
  property string glyph: ""
  property string label: ""
  property string valueText: ""
  property real fraction: 0

  implicitHeight: 40 * u

  RowLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: 28 * root.u
    spacing: 12 * root.u

    Icon {
      glyph: root.glyph
      font.pixelSize: 20 * root.u
      color: Config.text
      Layout.preferredWidth: 24 * root.u
    }
    Label {
      text: root.label
      font.pixelSize: 15 * root.u
      Layout.fillWidth: true
    }
    Label {
      text: root.valueText
      font.pixelSize: 15 * root.u
      color: Config.text
    }
  }

  Rectangle {

    antialiasing: true
    id: track
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: Math.max(1, Math.round(2 * root.u))
    radius: height / 2
    color: Qt.rgba(1, 1, 1, 0.12)

    Rectangle {

      antialiasing: true
      width: Math.max(track.height * 3, track.width * Math.max(0, Math.min(1, root.fraction)))
      height: parent.height
      radius: height / 2
      color: Config.primary
      Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
    }
  }
}
