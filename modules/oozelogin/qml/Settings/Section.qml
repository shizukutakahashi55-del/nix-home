import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

ColumnLayout {
  id: root

  property string title: ""
  property string hint: ""
  default property alias content: body.data

  Layout.fillWidth: true
  spacing: 8

  Label {
    text: root.title.toUpperCase()
    font.pixelSize: 12
    font.weight: Font.DemiBold
    font.letterSpacing: 1.4
    color: Config.primary
  }

  Label {
    visible: root.hint !== ""
    text: root.hint
    font.pixelSize: 13
    color: Config.subtext
    wrapMode: Text.WordWrap
    elide: Text.ElideNone
    Layout.fillWidth: true
  }

  Rectangle {

    antialiasing: true
    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + 8
    radius: 14
    color: Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.06)

    ColumnLayout {
      id: body
      anchors.fill: parent
      anchors.margins: 4
      spacing: 0
    }
  }
}
