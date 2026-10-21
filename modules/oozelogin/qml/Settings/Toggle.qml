import QtQuick
import "../Core"

Rectangle {

  antialiasing: true
  id: root

  property bool checked: false
  signal toggled(bool state)

  width: 46
  height: 26
  radius: 13
  color: root.checked ? Config.primary : Qt.rgba(1, 1, 1, 0.14)

  Behavior on color { ColorAnimation { duration: 140 } }

  Rectangle {

    antialiasing: true
    width: 20
    height: 20
    radius: 10
    y: 3
    x: root.checked ? parent.width - width - 3 : 3
    color: root.checked ? Config.onPrimary : Config.text
    Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled(!root.checked)
  }
}
