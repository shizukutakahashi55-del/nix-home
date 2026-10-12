import QtQuick

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    property real step: 0.05
    signal moved(real v)

    implicitWidth: 220
    implicitHeight: 26
    readonly property real ratio: (to - from) > 0 ? (value - from) / (to - from) : 0

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Pal.raised
        border.width: 1
        border.color: Pal.border
        Rectangle {
            width: handle.x + handle.width / 2
            height: parent.height
            radius: 3
            color: Pal.accent
        }
    }
    Rectangle {
        id: handle
        width: 20
        height: 20
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        x: root.ratio * (root.width - width)
        color: Pal.accent
        border.width: 4
        border.color: Pal.card
        scale: area.pressed ? 1.12 : 1
        Behavior on scale { NumberAnimation { duration: Pal.animFast } }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function setFrom(mx) {
            const r = Math.max(0, Math.min(1, (mx - handle.width / 2) / (root.width - handle.width)))
            let v = root.from + r * (root.to - root.from)
            v = Math.round(v / root.step) * root.step
            root.moved(Number(Math.max(root.from, Math.min(root.to, v)).toFixed(3)))
        }
        onPressed: mouse => setFrom(mouse.x)
        onPositionChanged: mouse => { if (pressed) setFrom(mouse.x) }
    }
}
