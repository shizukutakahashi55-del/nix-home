import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Page {
  readonly property var sessionModel: [{ value: "", label: Strings.t("defaultSessionAuto") }]
    .concat(Sys.sessions.map(s => ({ value: s.id, label: s.name })))

  Section {
    title: Strings.t("language")

    FormRow {
      label: Strings.t("language")
      last: true
      Choice {
        model: [
          { value: "auto", label: Strings.t("langAuto") },
          { value: "es", label: "Español" },
          { value: "en", label: "English" }
        ]
        current: Config.v.language
        onPicked: v => Config.set("language", v)
      }
    }
  }

  Section {
    title: Strings.t("remember")

    ToggleRow { label: Strings.t("rememberUser"); key: "rememberUser" }
    ToggleRow { label: Strings.t("rememberSession"); key: "rememberSession" }
    FormRow {
      label: Strings.t("defaultSession")
      last: true
      Choice {
        model: sessionModel
        current: Config.v.defaultSession
        onPicked: v => Config.set("defaultSession", v)
      }
    }
  }
}
