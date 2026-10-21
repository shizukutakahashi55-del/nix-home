import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Ui"

Page {
  Section {
    title: Strings.t("panels")

    ToggleRow { label: Strings.t("showTopBar"); key: "showTopBar" }
    ToggleRow { label: Strings.t("showInfoPanel"); key: "showInfoPanel" }
    ToggleRow { label: Strings.t("showClock"); key: "showClock" }
    ToggleRow { label: Strings.t("showWeather"); key: "showWeather" }
    ToggleRow { label: Strings.t("showStats"); key: "showStats" }
    ToggleRow { label: Strings.t("showSessionPanel"); key: "showSessionPanel" }
    ToggleRow { label: Strings.t("showKeyboard"); key: "showKeyboard" }
    ToggleRow { label: Strings.t("showPower"); key: "showPower" }
    ToggleRow { label: Strings.t("showUsers"); key: "showUsers" }
    ToggleRow { label: Strings.t("showTagline"); key: "showTagline" }
    ToggleRow { label: Strings.t("showFooter"); key: "showFooter" }
    ToggleRow { label: Strings.t("showDots"); key: "showDots" }
    ToggleRow { label: Strings.t("labelBubbles"); key: "labelBubbles" }
    ToggleRow { label: Strings.t("sessionPanelExpanded"); key: "sessionPanelExpanded" }
    ToggleRow { label: Strings.t("clock24h"); key: "clock24h"; last: true }
  }

  Section {
    title: Strings.t("texts")

    TextRow { label: Strings.t("brand"); key: "brand" }
    TextRow { label: Strings.t("subtitle"); key: "subtitle" }
    TextRow { label: Strings.t("tagline"); key: "tagline"; placeholder: "..." }
    TextRow { label: Strings.t("footerBrand"); key: "footerBrand"; last: true }
  }
}
