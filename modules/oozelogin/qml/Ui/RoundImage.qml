import QtQuick
import QtQuick.Effects
import "../Core"

Item {
  id: root

  property string source: ""
  property color ringColor: "transparent"
  property real ringWidth: 0
  property string initial: ""

  Rectangle {

    antialiasing: true
    anchors.fill: parent
    radius: width / 2
    color: "transparent"
    border.width: root.ringWidth
    border.color: root.ringColor
  }

  Item {
    id: inner
    anchors.fill: parent
    anchors.margins: root.ringWidth > 0 ? root.ringWidth + Math.max(2, root.width * 0.025) : 0

    Rectangle {

      antialiasing: true
      anchors.fill: parent
      radius: width / 2
      color: Config.surface
      visible: img.status !== Image.Ready
    }

    Icon {
      anchors.centerIn: parent
      glyph: Glyph.account
      color: Config.subtext
      font.pixelSize: inner.width * 0.52
      visible: img.status !== Image.Ready
    }

    Item {
      anchors.fill: parent
      layer.enabled: img.status === Image.Ready
      layer.smooth: true
      layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: innerMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
      }
      Image {
        id: img
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(512, 512)
        smooth: true
        mipmap: true
        visible: status === Image.Ready
      }
    }

    Item {
      id: innerMask
      anchors.fill: parent
      layer.enabled: true
      layer.smooth: true
      layer.samples: 4
      visible: false
      Rectangle {
        antialiasing: true
        anchors.fill: parent
        radius: width / 2
        color: "black"
      }
    }
  }
}
