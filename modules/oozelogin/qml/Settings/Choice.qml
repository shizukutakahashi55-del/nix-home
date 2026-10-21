import QtQuick
import "../Core"
import "../Ui"

Rectangle {

  antialiasing: true
  id: root

  property var model: []
  property string current: ""
  signal picked(string choice)

  implicitWidth: row.implicitWidth + 6
  implicitHeight: 36
  width: implicitWidth
  height: implicitHeight
  radius: 10
  color: Qt.rgba(0, 0, 0, 0.25)

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: root.model

      delegate: Rectangle {
        required property var modelData
        readonly property bool on: modelData.value === root.current
        width: lbl.implicitWidth + 28
        height: 30
        radius: 8
        color: on ? Config.primary : (area.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

        Label {
          id: lbl
          anchors.centerIn: parent
          text: modelData.label
          font.pixelSize: 13
          font.weight: parent.on ? Font.DemiBold : Font.Normal
          color: parent.on ? Config.onPrimary : Config.text
          elide: Text.ElideNone
        }
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.picked(modelData.value)
        }
      }
    }
  }
}
