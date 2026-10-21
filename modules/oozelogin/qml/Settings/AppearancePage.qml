import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Page {
  id: page

  readonly property var colorKeys: [
    { key: "bg", label: "colorBg" },
    { key: "surface", label: "colorSurface" },
    { key: "primary", label: "colorPrimary" },
    { key: "onPrimary", label: "colorOnPrimary" },
    { key: "text", label: "colorText" },
    { key: "subtext", label: "colorSubtext" },
    { key: "error", label: "colorError" }
  ]

  Process {
    id: addProc
    property string src: ""
    command: ["sh", "-c",
      'p="$1"; case "$p" in "~/"*) p="$HOME/${p#\\~/}";; esac; [ -f "$p" ] && mkdir -p "$2" && cp -f -- "$p" "$2"/',
      "sh", addProc.src, Config.wallDir]
    onExited: { Config.reload() }
  }

  Section {
    title: Strings.t("wallpaper")
    hint: Strings.t("wallpaperHint")

    FormRow {
      label: Strings.t("wallpaperMode")
      Choice {
        model: [
          { value: "fixed", label: Strings.t("modeFixed") },
          { value: "random", label: Strings.t("modeRandom") },
          { value: "sync", label: Strings.t("modeSync") }
        ]
        current: Config.v.wallpaperMode
        onPicked: v => Config.set("wallpaperMode", v)
      }
    }

    Item {
      Layout.fillWidth: true
      implicitHeight: Config.wallpapers.length > 0 ? grid.implicitHeight + 28 : 52

      Label {
        visible: Config.wallpapers.length === 0
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: Strings.t("wallpaperNone")
        color: Config.subtext
        font.pixelSize: 14
      }

      Flow {
        id: grid
        x: 16
        y: 14
        width: parent.width - 32
        spacing: 12

        Repeater {
          model: Config.wallpapers

          delegate: Rectangle {
            required property string modelData
            readonly property bool picked: Config.v.wallpaper === modelData || (Config.v.wallpaper === "" && Config.wallpapers[0] === modelData)
            width: 176
            height: 100
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.3)
            border.width: picked ? 2 : 1
            border.color: picked ? Config.primary : Qt.rgba(1, 1, 1, 0.12)

            Image {
              anchors.fill: parent
              anchors.margins: 3
              source: Config.fileUrl(Config.wallDir + "/" + parent.modelData)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              sourceSize: Qt.size(352, 200)
            }

            Rectangle {

              antialiasing: true
              visible: parent.picked
              anchors.right: parent.right
              anchors.top: parent.top
              anchors.margins: 8
              width: 24
              height: 24
              radius: 12
              color: Config.primary
              Icon {
                anchors.centerIn: parent
                glyph: Glyph.check
                font.pixelSize: 14
                color: Config.onPrimary
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: { Config.set("wallpaper", parent.modelData); Config.set("wallpaperMode", "fixed") }
            }
          }
        }
      }
    }

    FormRow {
      last: true
      label: Strings.t("addImage")
      hint: Strings.t("addImageHint")
      TextBox {
        id: pathBox
        placeholder: "~/Pictures/wall.jpg"
      }
      Button {
        text: Strings.t("add")
        glyph: Glyph.plus
        onClicked: { addProc.src = pathBox.text; addProc.running = false; addProc.running = true }
      }
    }
  }

  Section {
    title: Strings.t("panels")

    SliderRow { label: Strings.t("bgBlur"); key: "bgBlur"; from: 0; to: 100; suffix: "%" }
    SliderRow { label: Strings.t("bgDim"); key: "bgDim"; from: 0; to: 80; suffix: "%" }
    ToggleRow { label: Strings.t("panelBlur"); hint: Strings.t("panelBlurHint"); key: "panelBlur" }
    SliderRow { label: Strings.t("panelOpacity"); key: "panelOpacity"; from: 10; to: 95; suffix: "%" }
    SliderRow { label: Strings.t("bubbleOpacity"); key: "bubbleOpacity"; from: 30; to: 95; suffix: "%" }
    SliderRow { label: Strings.t("panelRadius"); key: "panelRadius"; from: 0; to: 40; suffix: "px" }
    SliderRow { label: Strings.t("uiScale"); key: "uiScale"; from: 60; to: 160; suffix: "%" }
    TextRow { label: Strings.t("font"); hint: Strings.t("fontHint"); key: "font"; placeholder: "Inter"; last: true }
  }

  Section {
    title: Strings.t("colors")

    FormRow {
      label: Strings.t("themeSource")
      last: Config.v.themeSource !== "custom"
      Choice {
        model: [
          { value: "custom", label: Strings.t("themeCustom") },
          { value: "oozeshell", label: Strings.t("themeOoze") }
        ]
        current: Config.v.themeSource
        onPicked: v => Config.set("themeSource", v)
      }
    }

    Repeater {
      model: Config.v.themeSource === "custom" ? page.colorKeys : []

      delegate: FormRow {
        required property var modelData
        required property int index
        last: index === page.colorKeys.length - 1
        label: Strings.t(modelData.label)
        ColorField {
          value: Config.colors[modelData.key]
          onCommitted: v => Config.setColor(modelData.key, v)
        }
      }
    }
  }
}
