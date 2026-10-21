import QtQuick
import "../Core"

Item {
  id: root

  readonly property real u: Math.max(0.55, Math.min(2.2, height / 1080 * Config.v.uiScale / 100))

  Component.onCompleted: Sys.active = true

  Backdrop {
    id: bg
    anchors.fill: parent
  }

  MouseArea {
    anchors.fill: parent
    onClicked: { auth.focusInput(); sidePanel.collapse() }
  }

  TopBar {
    id: topBar
    visible: Config.v.showTopBar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    u: root.u
  }

  InfoPanel {
    visible: Config.v.showInfoPanel
    backdrop: bg
    u: root.u
    x: 36 * root.u
    y: (Config.v.showTopBar ? topBar.height : 0) + 72 * root.u
  }

  SidePanel {
    id: sidePanel
    visible: Config.v.showSessionPanel
    backdrop: bg
    u: root.u
    x: root.width - width - 36 * root.u
    y: (Config.v.showTopBar ? topBar.height : 0) + 72 * root.u
  }

  AuthBlock {
    id: auth
    u: root.u
    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.max((Config.v.showTopBar ? topBar.height : 0) + 24 * root.u, root.height * 0.5 - height * 0.5 - 18 * root.u)
  }

  Tagline {
    u: root.u
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 96 * root.u
  }

  Row {
    visible: Config.v.showFooter
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.leftMargin: 36 * root.u
    anchors.bottomMargin: 32 * root.u
    spacing: 12 * root.u

    Icon {
      glyph: Glyph.leaf
      color: Config.primary
      font.pixelSize: 30 * root.u
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      text: Config.v.footerBrand
      font.pixelSize: 20 * root.u
      font.weight: Font.Medium
      color: Qt.tint(Config.text, Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.3))
    }
  }

  Dots {
    u: root.u
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.rightMargin: 40 * root.u
    anchors.bottomMargin: 38 * root.u
  }
}
