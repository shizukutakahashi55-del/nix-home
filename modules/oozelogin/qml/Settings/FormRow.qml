import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Item {
  id: root

  property string label: ""
  property string hint: ""
  property bool last: false
  default property alias control: slot.data

  Layout.fillWidth: true
  implicitHeight: Math.max(54, textCol.implicitHeight + 24)

  ColumnLayout {
    id: textCol
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.right: slot.left
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    spacing: 2

    Label {
      text: root.label
      font.pixelSize: 15
      Layout.fillWidth: true
    }
    Label {
      visible: root.hint !== ""
      text: root.hint
      font.pixelSize: 12
      color: Config.subtext
      wrapMode: Text.WordWrap
      elide: Text.ElideNone
      Layout.fillWidth: true
    }
  }

  Row {
    id: slot
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8
  }

  Rectangle {

    antialiasing: true
    visible: !root.last
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 16
    anchors.rightMargin: 16
    height: 1
    color: Qt.rgba(1, 1, 1, 0.06)
  }
}
