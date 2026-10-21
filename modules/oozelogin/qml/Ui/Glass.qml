import QtQuick
import QtQuick.Effects
import "../Core"

Item {
  id: root

  property Item backdrop: null
  property real radius: Config.v.panelRadius
  property real alpha: Config.v.panelOpacity / 100
  default property alias content: holder.data

  Item {
    id: mask
    anchors.fill: parent
    layer.enabled: true
    layer.smooth: true
    layer.samples: 4
    visible: false
    Rectangle {
      antialiasing: true
      anchors.fill: parent
      radius: root.radius
      color: "black"
    }
  }

  Item {
    id: slice
    anchors.fill: parent
    visible: Config.v.panelBlur && root.backdrop !== null
    layer.enabled: slice.visible
    layer.smooth: true
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: mask
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1.0
    }
    ShaderEffectSource {
      anchors.fill: parent
      sourceItem: root.backdrop ? root.backdrop.glass : null
      sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
    }
  }

  Rectangle {

    antialiasing: true
    anchors.fill: parent
    radius: root.radius
    color: Qt.rgba(Config.bg.r, Config.bg.g, Config.bg.b, Config.v.panelBlur ? root.alpha : Math.min(1, root.alpha + 0.25))
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)
  }

  Item {
    id: holder
    anchors.fill: parent
  }
}
