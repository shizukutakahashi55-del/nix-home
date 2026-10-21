import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Page {
  Section {
    title: Strings.t("navWeather")

    ToggleRow { label: Strings.t("showWeather"); key: "showWeather" }
    TextRow { label: Strings.t("weatherCity"); hint: Strings.t("weatherCityHint"); key: "weatherCity"; placeholder: "City" }
    ToggleRow { label: Strings.t("weatherF"); key: "weatherFahrenheit"; last: true }
  }
}
