import QtQuick
import "../Core"
import "../Ui"

Rectangle {

  antialiasing: true
  id: root

  property string text: ""
  property string placeholder: ""
  property bool mono: false
  property var validator: null
  signal committed(string entered)

  width: 260
  height: 36
  radius: 10
  color: Qt.rgba(0, 0, 0, 0.25)
  border.width: 1
  border.color: input.activeFocus ? Config.primary : Qt.rgba(1, 1, 1, 0.10)

  TextInput {
    id: input
    anchors.fill: parent
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    verticalAlignment: TextInput.AlignVCenter
    clip: true
    color: Config.text
    font.family: root.mono ? "monospace" : Config.fontFamily
    font.pixelSize: 14
    selectionColor: Config.primary
    selectedTextColor: Config.onPrimary
    text: root.text
    onEditingFinished: root.committed(text)

    Label {
      anchors.fill: parent
      visible: input.text.length === 0
      text: root.placeholder
      color: Config.subtext
      opacity: 0.7
      font.pixelSize: 14
    }
  }
}
