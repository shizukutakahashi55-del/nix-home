import QtQuick

Rectangle {
    id: root
    property string text: ""
    property string tone: "dim"     // ok | warn | err | accent | dim
    readonly property color fg: tone === "ok" ? Pal.ok
                              : tone === "warn" ? Pal.warn
                              : tone === "err" ? Pal.err
                              : tone === "accent" ? Pal.accentText
                              : Pal.textDim

    implicitHeight: Pal.fs(22)
    implicitWidth: lbl.implicitWidth + 18
    radius: height / 2
    color: tone === "dim" ? Pal.hover : Pal.alpha(fg, 0.15)

    Text {
        id: lbl
        anchors.centerIn: parent
        text: root.text
        color: root.fg
        font.pixelSize: Pal.fs(10)
        font.bold: true
    }
}
