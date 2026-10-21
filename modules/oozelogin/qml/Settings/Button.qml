import QtQuick
import "../Core"
import "../Ui"

Rectangle {

  antialiasing: true
  id: root

  property string text: ""
  property string glyph: ""
  property bool primary: false
  property bool busy: false
  signal clicked()

  implicitWidth: content.implicitWidth + 32
  implicitHeight: 36
  width: implicitWidth
  height: implicitHeight
  radius: 10
  opacity: root.busy ? 0.6 : 1
  color: root.primary ? (area.containsMouse ? Qt.lighter(Config.primary, 1.1) : Config.primary)
                      : (area.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))

  Row {
    id: content
    anchors.centerIn: parent
    spacing: 8

    Icon {
      visible: root.glyph !== ""
      glyph: root.glyph
      font.pixelSize: 16
      color: root.primary ? Config.onPrimary : Config.text
      anchors.verticalCenter: parent.verticalCenter
    }
    Label {
      text: root.text
      font.pixelSize: 14
      font.weight: Font.Medium
      color: root.primary ? Config.onPrimary : Config.text
      elide: Text.ElideNone
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: { if (!root.busy) root.clicked() }
  }
}
