import QtQuick
import QtQuick.Layouts
import "../Core"

ColumnLayout {
  id: root

  property real u: 1
  property bool reveal: false

  readonly property var current: {
    for (const user of Sys.users) if (user.name === Auth.username) return user
    return null
  }
  readonly property bool capsOnly: Auth.statusText === "" && Sys.capsLock
  readonly property string statusLine: Auth.statusText !== "" ? Auth.statusText : (Sys.capsLock ? Strings.t("capsOn") : (Config.preview ? Strings.t("previewHint") : ""))
  readonly property string shownName: root.current && root.current.real !== "" ? root.current.real : Auth.username

  spacing: 0

  function focusInput() { field.forceActiveFocus() }

  Connections {
    target: Auth
    function onBusyChanged() { if (!Auth.busy) field.forceActiveFocus() }
    function onFailCountChanged() { shake.restart() }
    function onUsernameChanged() { field.forceActiveFocus() }
  }

  Component.onCompleted: field.forceActiveFocus()

  RoundImage {
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: 170 * root.u
    Layout.preferredHeight: 170 * root.u
    source: root.current && root.current.avatar !== "" ? Config.avatarUrl(root.current.avatar) : ""
    ringWidth: 3 * root.u
    ringColor: Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.85)
  }

  Pill {
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 12 * root.u
    u: root.u
    text: root.shownName
    pixelSize: 30
    weight: Font.Light
    letterSpacing: 1.5
    textColor: Qt.tint(Config.text, Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.3))
    opacityBoost: -0.12
  }

  Rectangle {

    antialiasing: true
    id: pill
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 22 * root.u
    Layout.preferredWidth: 420 * root.u
    Layout.preferredHeight: 64 * root.u
    radius: height / 2
    color: Qt.rgba(Config.bg.r, Config.bg.g, Config.bg.b, 0.58)
    border.width: 1
    border.color: Auth.failed ? Config.error : (field.activeFocus ? Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.55) : Qt.rgba(1, 1, 1, 0.12))

    Behavior on border.color { ColorAnimation { duration: 150 } }

    transform: Translate { id: shiftX }

    SequentialAnimation {
      id: shake
      NumberAnimation { target: shiftX; property: "x"; to: -14 * root.u; duration: 50 }
      NumberAnimation { target: shiftX; property: "x"; to: 14 * root.u; duration: 70 }
      NumberAnimation { target: shiftX; property: "x"; to: -9 * root.u; duration: 60 }
      NumberAnimation { target: shiftX; property: "x"; to: 9 * root.u; duration: 60 }
      NumberAnimation { target: shiftX; property: "x"; to: 0; duration: 50 }
    }

    Icon {
      id: lockIcon
      anchors.left: parent.left
      anchors.leftMargin: 24 * root.u
      anchors.verticalCenter: parent.verticalCenter
      glyph: Glyph.lock
      font.pixelSize: 24 * root.u
      color: Config.subtext
    }

    TextInput {
      id: field
      anchors.left: lockIcon.right
      anchors.leftMargin: 16 * root.u
      anchors.right: capsSlot.left
      anchors.rightMargin: 12 * root.u
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height
      verticalAlignment: TextInput.AlignVCenter
      clip: true
      color: Config.text
      font.family: Config.fontFamily
      font.pixelSize: 20 * root.u
      selectionColor: Config.primary
      selectedTextColor: Config.onPrimary
      echoMode: (Auth.awaiting && Auth.promptEcho) || root.reveal ? TextInput.Normal : TextInput.Password
      passwordCharacter: "•"
      readOnly: Auth.busy || Auth.launching
      inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
      text: Auth.input
      onTextChanged: { if (Auth.input !== text) Auth.input = text }
      Keys.onReturnPressed: Auth.submit()
      Keys.onEnterPressed: Auth.submit()
      Keys.onEscapePressed: Auth.clear()

      Label {
        anchors.fill: parent
        visible: field.text.length === 0
        text: Auth.awaiting && Auth.prompt !== "" ? Auth.prompt : Strings.t("password")
        font.pixelSize: 20 * root.u
        color: Config.textSoft
        opacity: 0.72
      }
    }

    Item {
      id: capsSlot
      anchors.right: eye.left
      anchors.rightMargin: Sys.capsLock ? 6 * root.u : 0
      anchors.verticalCenter: parent.verticalCenter
      width: Sys.capsLock ? 32 * root.u : 0
      height: 32 * root.u
      visible: Sys.capsLock

      Icon {
        anchors.centerIn: parent
        glyph: Glyph.capsLock
        font.pixelSize: 24 * root.u
        color: Config.primary
      }
    }

    Item {
      id: eye
      anchors.right: parent.right
      anchors.rightMargin: 20 * root.u
      anchors.verticalCenter: parent.verticalCenter
      width: 36 * root.u
      height: 36 * root.u
      visible: !(Auth.awaiting && Auth.promptEcho)

      Icon {
        anchors.centerIn: parent
        glyph: root.reveal ? Glyph.eyeOff : Glyph.eye
        font.pixelSize: 24 * root.u
        color: eyeArea.containsMouse ? Config.text : Config.subtext
      }
      MouseArea {
        id: eyeArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.reveal = !root.reveal; field.forceActiveFocus() }
      }
    }
  }

  Item {
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 10 * root.u
    Layout.preferredWidth: 420 * root.u
    Layout.preferredHeight: 38 * root.u

    Pill {
      anchors.centerIn: parent
      width: Math.min(implicitWidth, parent.width)
      u: root.u
      pixelSize: 14
      text: root.statusLine
      tint: Auth.failed ? Config.error : Config.primary
      tintAmount: Auth.failed ? 0.30 : (root.capsOnly ? 0.25 : 0)
      opacityBoost: Auth.failed ? 0.26 : (root.capsOnly ? 0.23 : 0)
    }
  }

  RowLayout {
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 14 * root.u
    spacing: 30 * root.u
    visible: Config.v.showUsers && Sys.users.length > 1

    Repeater {
      model: Sys.users

      delegate: ColumnLayout {
        id: chip
        required property var modelData
        readonly property bool selected: modelData.name === Auth.username
        spacing: 8 * root.u

        RoundImage {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 58 * root.u
          Layout.preferredHeight: 58 * root.u
          source: chip.modelData.avatar !== "" ? Config.avatarUrl(chip.modelData.avatar) : ""
          ringWidth: chip.selected ? 2 * root.u : 0
          ringColor: Qt.rgba(Config.primary.r, Config.primary.g, Config.primary.b, 0.9)
          opacity: chip.selected || chipArea.containsMouse ? 1 : 0.75
          Behavior on opacity { NumberAnimation { duration: 120 } }

          MouseArea {
            id: chipArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Auth.select(chip.modelData.name)
          }
        }

        Label {
          Layout.alignment: Qt.AlignHCenter
          text: chip.modelData.name
          font.pixelSize: 14 * root.u
          color: chip.selected ? Config.text : Config.subtext
        }
      }
    }
  }
}
