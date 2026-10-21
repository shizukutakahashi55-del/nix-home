import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Page {
  id: page

  property string status: ""
  property string report: ""
  readonly property string user: Quickshell.env("USER") || ""
  readonly property var userSync: (Config.syncData.users && Config.syncData.users[page.user]) ? Config.syncData.users[page.user] : null

  Process {
    id: syncProc
    command: [Quickshell.env("OOZELOGIN_SYNC") || "oozelogin-sync"]
    stdout: StdioCollector {
      id: syncOut
    }
    stderr: StdioCollector {
      id: syncErr
    }
    onExited: (code, status) => {
      const out = (String(syncOut.text) + "\n" + String(syncErr.text)).trim()
      page.report = out
      page.status = code === 0
        ? (out.indexOf("avatar NO encontrado") >= 0 ? Strings.t("syncNoAvatar") : Strings.t("syncDone"))
        : Strings.t("syncFail")
      Config.reload()
      Sys.reloadUsers()
    }
  }

  Section {
    title: Strings.t("syncTitle")
    hint: Strings.t("syncHint")

    FormRow {
      label: Strings.t("useOozeColors")
      Toggle {
        checked: Config.v.themeSource === "oozeshell"
        onToggled: v => Config.set("themeSource", v ? "oozeshell" : "custom")
      }
    }

    FormRow {
      label: Strings.t("useOozeWall")
      Toggle {
        checked: Config.v.wallpaperMode === "sync"
        onToggled: v => Config.set("wallpaperMode", v ? "sync" : "fixed")
      }
    }

    FormRow {
      label: Strings.t("syncStatus")
      Label {
        text: Config.syncData.wallpaper ? Config.syncData.wallpaper : Strings.t("syncNever")
        color: Config.subtext
        font.pixelSize: 14
        elide: Text.ElideNone
      }
    }

    FormRow {
      label: Strings.t("syncAvatar")
      hint: Strings.t("syncAvatarHint")
      RoundImage {
        width: 40
        height: 40
        source: page.userSync && page.userSync.avatar ? Config.avatarUrl(Config.dir + "/" + page.userSync.avatar) : ""
      }
    }

    FormRow {
      visible: page.report !== ""
      label: Strings.t("syncDetails")
      Label {
        text: page.report
        color: Config.subtext
        font.pixelSize: 12
        elide: Text.ElideNone
        wrapMode: Text.WrapAnywhere
      }
    }

    FormRow {
      last: true
      label: page.status
      Button {
        primary: true
        glyph: Glyph.sync
        text: syncProc.running ? Strings.t("syncRunning") : Strings.t("syncNow")
        busy: syncProc.running
        onClicked: { page.status = ""; syncProc.running = true }
      }
    }
  }
}
