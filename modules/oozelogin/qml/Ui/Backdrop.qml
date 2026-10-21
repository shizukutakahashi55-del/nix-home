import QtQuick
import QtQuick.Effects
import "../Core"

Item {
  id: root

  property alias glass: glassFx

  Rectangle {

    antialiasing: true
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.tint(Config.bg, Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.22)) }
      GradientStop { position: 1.0; color: Config.bg }
    }
  }

  Image {
    id: wp
    anchors.fill: parent
    source: Config.wallpaperUrl
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    sourceSize: Qt.size(Math.max(1, root.width), Math.max(1, root.height))
    visible: false
  }

  MultiEffect {
    id: glassFx
    anchors.fill: parent
    source: wp
    autoPaddingEnabled: false
    blurEnabled: true
    blur: 1.0
    blurMax: 48
    brightness: -0.05
    visible: Config.v.panelBlur && wp.status === Image.Ready
  }

  MultiEffect {
    anchors.fill: parent
    source: wp
    autoPaddingEnabled: false
    blurEnabled: Config.v.bgBlur > 0
    blur: Config.v.bgBlur / 100
    blurMax: 64
    visible: wp.status === Image.Ready
  }

  Rectangle {

    antialiasing: true
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, Config.v.bgDim / 100)
  }

  Rectangle {

    antialiasing: true
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
      GradientStop { position: 0.30; color: "transparent" }
      GradientStop { position: 0.68; color: "transparent" }
      GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.6) }
    }
  }
}
