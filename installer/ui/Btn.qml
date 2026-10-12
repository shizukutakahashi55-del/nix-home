import QtQuick

Rectangle {
    id: root
    property string label: ""
    property string icon: ""
    property string kind: "normal"      // primary | normal | danger | ghost
    property bool small: false
    signal clicked()

    implicitHeight: small ? 30 : 38
    implicitWidth: row.implicitWidth + (small ? 22 : 30)
    radius: Pal.rMd
    opacity: enabled ? 1 : 0.4
    scale: area.pressed ? 0.97 : 1
    Behavior on scale { NumberAnimation { duration: Pal.animFast } }

    color: kind === "primary" ? Pal.accent
         : kind === "danger" ? Pal.errBg
         : kind === "ghost" ? "transparent"
         : Pal.raised
    border.width: kind === "primary" ? 0 : 1
    border.color: kind === "danger" ? Pal.alpha(Pal.err, 0.35)
                : kind === "ghost" ? "transparent"
                : Pal.border
    gradient: kind === "primary" ? grad : null

    Gradient {
        id: grad
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: Pal.accent }
        GradientStop { position: 1.0; color: Pal.accentHi }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.kind === "primary" ? Qt.rgba(1, 1, 1, 0.16) : Pal.hover
        opacity: area.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Pal.animFast } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7
        Text {
            visible: root.icon !== ""
            text: root.icon
            anchors.verticalCenter: parent.verticalCenter
            color: label.color
            font.pixelSize: Pal.fs(root.small ? 12 : 14)
        }
        Text {
            id: label
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.kind === "primary" ? Pal.onAccent : (root.kind === "danger" ? Pal.err : Pal.text)
            font.pixelSize: Pal.fs(root.small ? 11 : 12)
            font.bold: root.kind === "primary"
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
