import QtQuick
import QtQuick.Layouts

Flickable {
  id: root

  default property alias content: col.data

  contentWidth: width
  contentHeight: col.implicitHeight + 56
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  flickableDirection: Flickable.VerticalFlick

  ColumnLayout {
    id: col
    x: 32
    y: 24
    width: root.width - 64
    spacing: 22
  }
}
