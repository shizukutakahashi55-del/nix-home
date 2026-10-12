import QtQuick

Item {
    id: root
    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Pal.accent : Pal.raised
        border.width: root.checked ? 0 : 1
        border.color: Pal.border
        Behavior on color { ColorAnimation { duration: Pal.anim } }

        Rectangle {
            width: 18
            height: 18
            radius: 9
            y: 3
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Pal.onAccent : Pal.textDim
            Behavior on x { NumberAnimation { duration: Pal.anim; easing.type: Easing.OutCubic } }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
