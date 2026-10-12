import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var app

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.rightMargin: 16
        clip: true
        contentWidth: width
        contentHeight: col.implicitHeight + 8
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: flick.width
            spacing: 16

            // ───────────── Paleta ─────────────
            Section {
                title: "Paleta de colores"
                subtitle: "El cambio se aplica al instante y se recuerda la próxima vez que abras el instalador."

                Flow {
                    Layout.fillWidth: true
                    spacing: 12
                    Repeater {
                        model: Pal.themes
                        delegate: Rectangle {
                            id: card
                            required property var modelData
                            readonly property bool sel: Pal.themeId === modelData.id
                            width: 206
                            height: 132
                            radius: Pal.rLg
                            color: hov.containsMouse ? Pal.hover : "transparent"
                            border.width: sel ? 2 : 1
                            border.color: sel ? Pal.accent : Pal.border
                            Behavior on border.color { ColorAnimation { duration: Pal.animFast } }

                            // Vista previa
                            Rectangle {
                                id: pv
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 8
                                height: 84
                                radius: Pal.rMd
                                color: card.modelData.bg
                                clip: true

                                Rectangle {
                                    x: 6; y: 6
                                    width: 34
                                    height: pv.height - 12
                                    radius: Pal.rSm
                                    color: card.modelData.panel
                                    Column {
                                        anchors.left: parent.left; anchors.right: parent.right
                                        anchors.top: parent.top; anchors.margins: 6
                                        spacing: 5
                                        Rectangle { width: parent.width; height: 6; radius: 3; color: card.modelData.accent }
                                        Rectangle { width: parent.width * 0.7; height: 6; radius: 3; color: card.modelData.textFaint }
                                        Rectangle { width: parent.width * 0.85; height: 6; radius: 3; color: card.modelData.textFaint }
                                    }
                                }
                                Rectangle {
                                    x: 46; y: 6
                                    width: pv.width - 52
                                    height: 24
                                    radius: Pal.rSm
                                    color: card.modelData.card
                                    border.color: card.modelData.border
                                    Rectangle { x: 8; anchors.verticalCenter: parent.verticalCenter; width: 34; height: 7; radius: 3; color: card.modelData.text }
                                    Rectangle { anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter; width: 28; height: 14; radius: Pal.rSm; color: card.modelData.accent }
                                }
                                Rectangle {
                                    x: 46; y: 36
                                    width: pv.width - 52
                                    height: pv.height - 42
                                    radius: Pal.rSm
                                    color: card.modelData.termBg
                                    Column {
                                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 7
                                        spacing: 4
                                        Rectangle { width: 56; height: 5; radius: 2; color: card.modelData.ok }
                                        Rectangle { width: 38; height: 5; radius: 2; color: card.modelData.warn }
                                        Rectangle { width: 46; height: 5; radius: 2; color: card.modelData.err }
                                    }
                                }
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.right: check.left
                                anchors.rightMargin: 6
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 12
                                elide: Text.ElideRight
                                text: card.modelData.name
                                color: Pal.text
                                font.pixelSize: Pal.fs(12)
                                font.bold: card.sel
                            }
                            Text {
                                id: check
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 11
                                text: card.sel ? "✔" : (card.modelData.dark ? "🌙" : "☀")
                                color: card.sel ? Pal.accentText : Pal.textFaint
                                font.pixelSize: Pal.fs(13)
                            }
                            MouseArea {
                                id: hov
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Pal.themeId = card.modelData.id
                            }
                        }
                    }
                }
            }

            // ───────────── Acento ─────────────
            Section {
                title: "Color de acento"
                subtitle: "Sustituye el acento de la paleta (botones, selección, indicadores)."

                Flow {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        height: 34
                        width: autoLbl.implicitWidth + 36
                        radius: 17
                        color: Pal.accentCustom === "" ? Pal.accentSoft : Pal.raised
                        border.width: Pal.accentCustom === "" ? 2 : 1
                        border.color: Pal.accentCustom === "" ? Pal.accent : Pal.border
                        Rectangle {
                            anchors.left: parent.left; anchors.leftMargin: 9
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16; height: 16; radius: 8; color: Pal.t.accent
                        }
                        Text { id: autoLbl; anchors.centerIn: parent; anchors.horizontalCenterOffset: 9; text: "De la paleta"; color: Pal.text; font.pixelSize: Pal.fs(12) }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Pal.accentCustom = "" }
                    }

                    Repeater {
                        model: Pal.accents
                        delegate: Rectangle {
                            required property string modelData
                            readonly property bool sel: Pal.accentCustom.toLowerCase() === modelData
                            readonly property color swatch: modelData
                            readonly property bool light: Pal.lum(swatch) > 0.6
                            width: 34; height: 34; radius: 17
                            color: swatch
                            border.width: sel ? 3 : 0
                            border.color: Pal.text
                            scale: sm.containsMouse ? 1.1 : 1
                            Behavior on scale { NumberAnimation { duration: Pal.animFast } }
                            Text { visible: parent.sel; anchors.centerIn: parent; text: "✔"; color: parent.light ? "#14121a" : "#ffffff"; font.pixelSize: Pal.fs(13); font.bold: true }
                            MouseArea { id: sm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Pal.accentCustom = modelData }
                        }
                    }
                }
            }

            // ───────────── Forma y texto ─────────────
            Section {
                title: "Forma y texto"

                SettingRow {
                    label: "Esquinas"
                    hint: "Qué tan redondeados se ven botones, tarjetas y campos."
                    Segmented {
                        value: String(Pal.radiusStyle)
                        options: [{ id: "0", label: "Rectas" }, { id: "1", label: "Suaves" }, { id: "2", label: "Redondas" }]
                        onPicked: id => Pal.radiusStyle = parseInt(id)
                    }
                }
                SettingRow {
                    label: "Tamaño del texto"
                    hint: "Escala toda la tipografía de la interfaz."
                    Segmented {
                        value: String(Pal.fontScale)
                        options: [{ id: "0.9", label: "Pequeño" }, { id: "1", label: "Normal" }, { id: "1.1", label: "Grande" }, { id: "1.25", label: "Enorme" }]
                        onPicked: id => Pal.fontScale = parseFloat(id)
                    }
                }
                SettingRow {
                    label: "Fuente monoespaciada"
                    hint: "Para terminal, editor y diff (p. ej. JetBrainsMono Nerd Font, Fira Code)."
                    Field {
                        Layout.preferredWidth: 240
                        mono: true
                        text: Pal.monoFont
                        placeholder: "monospace"
                        onEdited: Pal.monoFont = text
                    }
                }
            }

            // ───────────── Ventana ─────────────
            Section {
                title: "Ventana"

                SettingRow {
                    label: "Opacidad del fondo"
                    hint: "Menos de 100 % deja ver el escritorio (útil con blur en tu compositor)."
                    Range {
                        Layout.preferredWidth: 220
                        from: 0.5; to: 1.0; step: 0.05
                        value: Pal.winOpacity
                        onMoved: v => Pal.winOpacity = v
                    }
                    Text { Layout.preferredWidth: 42; horizontalAlignment: Text.AlignRight; text: Math.round(Pal.winOpacity * 100) + " %"; color: Pal.textDim; font.pixelSize: Pal.fs(12) }
                }
                SettingRow {
                    label: "Barra lateral compacta"
                    hint: "Solo iconos. También se alterna con el botón « de la barra."
                    Toggle { checked: Pal.compactSidebar; onToggled: v => Pal.compactSidebar = v }
                }
                SettingRow {
                    label: "Animaciones"
                    hint: "Transiciones suaves al pasar el ratón y cambiar de color."
                    Toggle { checked: Pal.animations; onToggled: v => Pal.animations = v }
                }
            }

            // ───────────── Atajo ─────────────
            Section {
                title: "Atajo de teclado (abrir / cerrar)"
                subtitle: "Super+Shift+U de ejemplo. toggle.sh abre el instalador y, si ya está abierto, lo cierra y apaga el proceso. Si hay un comando en ejecución no lo cierra."

                Repeater {
                    model: [
                        { name: "Hyprland (Lua)", line: "hl.bind(mainMod .. \" + SHIFT + U\", hl.dsp.exec_cmd(\"" + root.app.toggleCmd + "\"))" },
                        { name: "niri", line: "Mod+Shift+U repeat=false { spawn \"" + root.app.toggleCmd + "\"; }" },
                        { name: "MangoWC", line: "bind=SUPER+SHIFT,U,spawn_shell," + root.app.toggleCmd }
                    ]
                    delegate: ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Badge { text: modelData.name; tone: "accent" }
                            Item { Layout.fillWidth: true }
                            Btn { small: true; label: "Copiar"; onClicked: root.app.copyText(modelData.line, "Línea copiada") }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Pal.rMd
                            color: Pal.termBg
                            border.color: Pal.border
                            clip: true
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                text: modelData.line
                                color: Pal.text
                                font.family: Pal.mono
                                font.pixelSize: Pal.fs(12)
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 8
                Item { Layout.fillWidth: true }
                Btn { label: "Restablecer ajustes"; kind: "danger"; onClicked: { Pal.resetAll(); root.app.toast("Ajustes restablecidos") } }
            }
        }
    }
    VScroll { target: flick; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom }
}
