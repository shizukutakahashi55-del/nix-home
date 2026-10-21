import QtQuick
import QtQuick.Layouts
import "../Core"

Rectangle {

  antialiasing: true
  id: root

  property real u: 1
  property string glyph: ""
  property string text: ""
  property bool selected: false
  property bool chevron: true
  property bool danger: false
  signal clicked()

  implicitHeight: 46 * u
  radius: 10 * u
  color: root.selected ? Qt.rgba(1, 1, 1, 0.10) : (area.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

  Behavior on color { ColorAnimation { duration: 120 } }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 12 * root.u
    anchors.rightMargin: 12 * root.u
    spacing: 14 * root.u

    Icon {
      glyph: root.glyph
      font.pixelSize: 22 * root.u
      color: root.danger ? Config.error : (root.selected ? Config.text : Config.iconSoft)
      Layout.preferredWidth: 26 * root.u
    }

    Label {
      text: root.text
      font.pixelSize: 16 * root.u
      color: root.danger ? Config.error : (root.selected ? Config.text : Config.textSoft)
      Layout.fillWidth: true
    }

    Icon {
      visible: root.chevron
      glyph: Glyph.chevron
      font.pixelSize: 18 * root.u
      color: Config.iconSoft
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
