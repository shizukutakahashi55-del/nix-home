import QtQuick
import "../Core"

Row {
  id: root

  property string value: ""
  signal committed(string entered)

  spacing: 10

  Rectangle {

    antialiasing: true
    width: 36
    height: 36
    radius: 10
    color: /^#[0-9a-fA-F]{6}$/.test(root.value) ? root.value : "transparent"
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.2)
  }

  TextBox {
    width: 120
    mono: true
    text: root.value
    onCommitted: v => { if (/^#[0-9a-fA-F]{6}$/.test(v)) root.committed(v.toLowerCase()) }
  }
}
