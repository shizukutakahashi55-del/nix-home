import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "Core"
import "Ui"

ShellRoot {
  Process {
    id: readyMark
    command: ["sh", "-c", ': > "$1"', "sh", Config.cacheDir + "/greeter.ready"]
  }

  QtObject {
    id: boot
    readonly property bool ready: Config.loaded && Sys.usersLoaded && Sys.sessionsLoaded

    function begin() {
      Auth.bootstrap()
      if (!Config.preview) readyMark.running = true
    }

    onReadyChanged: { if (ready) begin() }
    Component.onCompleted: { if (ready) begin() }
  }

  Variants {
    model: Config.preview ? [] : Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      color: "black"
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "oozelogin"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      Scene {
        anchors.fill: parent
      }
    }
  }

  Variants {
    model: Config.preview ? [0] : []

    FloatingWindow {
      required property var modelData
      title: "OozeLogin preview"
      implicitWidth: 1280
      implicitHeight: 800
      color: "black"
      onVisibleChanged: { if (!visible) Qt.quit() }

      Scene {
        anchors.fill: parent
      }
    }
  }
}
