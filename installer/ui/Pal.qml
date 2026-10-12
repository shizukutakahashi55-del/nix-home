pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ───────── Ajustes (se guardan en ~/.config/nix-home-installer/settings.json) ─────────
    property string themeId: "violeta"
    property string accentCustom: ""        // "" = el acento de la paleta
    property int radiusStyle: 1             // 0 rectas · 1 suaves · 2 redondas
    property real fontScale: 1.0
    property real winOpacity: 1.0
    property bool compactSidebar: false
    property bool autoCompact: false          // lo activa la ventana cuando es estrecha
    property bool animations: true
    property string monoFont: "monospace"
    property bool loaded: false

    // ───────── Paletas ─────────
    readonly property var themes: [
        { id: "violeta", name: "Violeta", dark: true,
          bg: "#111018", panel: "#191622", card: "#1b1724", raised: "#252032", border: "#352c44",
          accent: "#8e62d9", text: "#f3eaff", textDim: "#a59bb3", textFaint: "#7d7489",
          ok: "#8ed6a9", warn: "#e8c776", err: "#ef7f8e", termBg: "#0d0c12" },
        { id: "mocha", name: "Catppuccin Mocha", dark: true,
          bg: "#11111b", panel: "#181825", card: "#1e1e2e", raised: "#313244", border: "#45475a",
          accent: "#cba6f7", text: "#cdd6f4", textDim: "#a6adc8", textFaint: "#7f849c",
          ok: "#a6e3a1", warn: "#f9e2af", err: "#f38ba8", termBg: "#0b0b12" },
        { id: "tokyo", name: "Tokyo Night", dark: true,
          bg: "#16161e", panel: "#1a1b26", card: "#1f2335", raised: "#292e42", border: "#3b4261",
          accent: "#7aa2f7", text: "#c0caf5", textDim: "#9aa5ce", textFaint: "#565f89",
          ok: "#9ece6a", warn: "#e0af68", err: "#f7768e", termBg: "#13141c" },
        { id: "rosepine", name: "Rosé Pine", dark: true,
          bg: "#191724", panel: "#1f1d2e", card: "#26233a", raised: "#2a2740", border: "#403d52",
          accent: "#c4a7e7", text: "#e0def4", textDim: "#908caa", textFaint: "#6e6a86",
          ok: "#9ccfd8", warn: "#f6c177", err: "#eb6f92", termBg: "#14121f" },
        { id: "dracula", name: "Dracula", dark: true,
          bg: "#1e1f29", panel: "#21222c", card: "#282a36", raised: "#343746", border: "#44475a",
          accent: "#bd93f9", text: "#f8f8f2", textDim: "#b6b9c9", textFaint: "#6272a4",
          ok: "#50fa7b", warn: "#f1fa8c", err: "#ff5555", termBg: "#191a21" },
        { id: "nord", name: "Nord", dark: true,
          bg: "#242933", panel: "#2e3440", card: "#3b4252", raised: "#434c5e", border: "#4c566a",
          accent: "#88c0d0", text: "#eceff4", textDim: "#d8dee9", textFaint: "#7b88a1",
          ok: "#a3be8c", warn: "#ebcb8b", err: "#bf616a", termBg: "#20242d" },
        { id: "gruvbox", name: "Gruvbox", dark: true,
          bg: "#1d2021", panel: "#282828", card: "#32302f", raised: "#3c3836", border: "#504945",
          accent: "#fe8019", text: "#ebdbb2", textDim: "#bdae93", textFaint: "#928374",
          ok: "#b8bb26", warn: "#fabd2f", err: "#fb4934", termBg: "#171a1b" },
        { id: "everforest", name: "Everforest", dark: true,
          bg: "#1e2326", panel: "#232a2e", card: "#2d353b", raised: "#3d484d", border: "#475258",
          accent: "#a7c080", text: "#d3c6aa", textDim: "#9da9a0", textFaint: "#7a8478",
          ok: "#a7c080", warn: "#dbbc7f", err: "#e67e80", termBg: "#1a1f22" },
        { id: "oled", name: "Medianoche OLED", dark: true,
          bg: "#000000", panel: "#08080a", card: "#101013", raised: "#1a1a1f", border: "#27272d",
          accent: "#3b82f6", text: "#fafafa", textDim: "#a1a1aa", textFaint: "#71717a",
          ok: "#4ade80", warn: "#facc15", err: "#f87171", termBg: "#000000" },
        { id: "latte", name: "Catppuccin Latte (claro)", dark: false,
          bg: "#eff1f5", panel: "#e6e9ef", card: "#ffffff", raised: "#dce0e8", border: "#ccd0da",
          accent: "#8839ef", text: "#4c4f69", textDim: "#6c6f85", textFaint: "#8c8fa1",
          ok: "#40a02b", warn: "#df8e1d", err: "#d20f39", termBg: "#f7f8fb" }
    ]

    readonly property var accents: [
        "#a78bfa", "#60a5fa", "#22d3ee", "#2dd4bf", "#4ade80",
        "#a3e635", "#fbbf24", "#fb923c", "#f87171", "#f472b6"
    ]

    readonly property var radii: [[3, 5, 8], [7, 10, 16], [10, 14, 22]]

    // ───────── Derivados ─────────
    function findTheme(id) {
        for (let i = 0; i < themes.length; i++) if (themes[i].id === id) return themes[i]
        return themes[0]
    }
    function hasTheme(id) {
        for (let i = 0; i < themes.length; i++) if (themes[i].id === id) return true
        return false
    }
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
    function lum(c) { return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b }
    function fs(n) { return Math.round(n * fontScale) }

    readonly property var t: findTheme(themeId)
    readonly property bool dark: t.dark

    readonly property color cBg: t.bg
    readonly property color cPanel: t.panel
    readonly property color cCard: t.card
    readonly property color cTerm: t.termBg
    readonly property color cText: t.text

    readonly property color accent: accentCustom !== "" ? accentCustom : t.accent
    readonly property color accentHi: Qt.lighter(accent, 1.22)
    readonly property color accentSoft: alpha(accent, dark ? 0.18 : 0.14)
    readonly property color accentText: dark ? Qt.lighter(accent, 1.25) : Qt.darker(accent, 1.2)
    readonly property color onAccent: lum(accent) > 0.6 ? "#14121a" : "#ffffff"

    readonly property color bg: alpha(cBg, winOpacity)
    readonly property color panel: alpha(cPanel, winOpacity)
    readonly property color card: alpha(cCard, Math.min(1, winOpacity + 0.05))
    readonly property color termBg: alpha(cTerm, Math.min(1, winOpacity + 0.08))
    readonly property color raised: t.raised
    readonly property color border: t.border
    readonly property color text: t.text
    readonly property color textDim: t.textDim
    readonly property color textFaint: t.textFaint
    readonly property color ok: t.ok
    readonly property color warn: t.warn
    readonly property color err: t.err

    readonly property color hover: alpha(cText, 0.07)
    readonly property color press: alpha(cText, 0.12)
    readonly property color okBg: alpha(ok, 0.14)
    readonly property color warnBg: alpha(warn, 0.14)
    readonly property color errBg: alpha(err, 0.14)
    readonly property color diffAdd: alpha(ok, 0.13)
    readonly property color diffDel: alpha(err, 0.13)

    readonly property int rSm: radii[radiusStyle][0]
    readonly property int rMd: radii[radiusStyle][1]
    readonly property int rLg: radii[radiusStyle][2]

    readonly property bool compact: compactSidebar || autoCompact
    readonly property int anim: animations ? 150 : 0
    readonly property int animFast: animations ? 90 : 0
    readonly property string mono: monoFont !== "" ? monoFont : "monospace"

    // ───────── Persistencia ─────────
    readonly property string settingsDir: (Quickshell.env("XDG_CONFIG_HOME") || ((Quickshell.env("HOME") ?? "") + "/.config")) + "/nix-home-installer"
    readonly property string settingsPath: settingsDir + "/settings.json"

    function snapshot() {
        return {
            theme: themeId, accent: accentCustom, radius: radiusStyle, fontScale: fontScale,
            opacity: winOpacity, compactSidebar: compactSidebar, animations: animations, monoFont: monoFont
        }
    }

    function apply(o) {
        if (typeof o.theme === "string" && hasTheme(o.theme)) themeId = o.theme
        if (typeof o.accent === "string") accentCustom = /^#[0-9a-fA-F]{6}$/.test(o.accent) ? o.accent : ""
        if (typeof o.radius === "number") radiusStyle = Math.max(0, Math.min(2, Math.round(o.radius)))
        if (typeof o.fontScale === "number") fontScale = Math.max(0.8, Math.min(1.4, o.fontScale))
        if (typeof o.opacity === "number") winOpacity = Math.max(0.5, Math.min(1, o.opacity))
        if (typeof o.compactSidebar === "boolean") compactSidebar = o.compactSidebar
        if (typeof o.animations === "boolean") animations = o.animations
        if (typeof o.monoFont === "string") monoFont = o.monoFont
    }

    function resetAll() {
        themeId = "violeta"
        accentCustom = ""
        radiusStyle = 1
        fontScale = 1.0
        winOpacity = 1.0
        compactSidebar = false
        animations = true
        monoFont = "monospace"
    }

    function scheduleSave() { if (loaded) saver.restart() }

    onThemeIdChanged: scheduleSave()
    onAccentCustomChanged: scheduleSave()
    onRadiusStyleChanged: scheduleSave()
    onFontScaleChanged: scheduleSave()
    onWinOpacityChanged: scheduleSave()
    onCompactSidebarChanged: scheduleSave()
    onAnimationsChanged: scheduleSave()
    onMonoFontChanged: scheduleSave()

    Timer {
        id: saver
        interval: 400
        onTriggered: store.setText(JSON.stringify(root.snapshot(), null, 2))
    }

    FileView {
        id: store
        path: root.settingsPath
        blockLoading: true
        onLoaded: {
            try { root.apply(JSON.parse(text())) } catch (e) {}
            root.loaded = true
        }
        onLoadFailed: error => { root.loaded = true }
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.settingsDir])
}
