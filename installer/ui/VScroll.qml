import QtQuick

Item {
    id: root
    property Flickable target
    width: 8
    visible: target && target.visibleArea.heightRatio < 0.999

    Rectangle {
        id: thumb
        width: parent.width
        radius: 4
        color: drag.pressed || drag.containsMouse ? Pal.accent : Pal.border
        Behavior on color { ColorAnimation { duration: Pal.animFast } }
        height: Math.max(24, root.height * (root.target ? root.target.visibleArea.heightRatio : 1))
        y: root.target ? root.target.visibleArea.yPosition * root.height : 0

        MouseArea {
            id: drag
            anchors.fill: parent
            anchors.leftMargin: -6
            hoverEnabled: true
            drag.target: thumb
            drag.axis: Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: root.height - thumb.height
            onPositionChanged: if (pressed && root.target) {
                const r = thumb.y / Math.max(1, root.height - thumb.height)
                root.target.contentY = root.target.originY + r * (root.target.contentHeight - root.target.height)
            }
        }
    }
}
