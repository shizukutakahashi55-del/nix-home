import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var app
    property int tabIndex: 0
    property string name: ""
    property string icon: ""
    readonly property bool active: app.tab === tabIndex
    readonly property bool showDot: (tabIndex === 1 && app.changed.length > 0) || (tabIndex === 2 && app.runner.running)

    Layout.fillWidth: true
    Layout.preferredHeight: 44
    radius: Pal.rMd
    color: active ? Pal.accentSoft : (nm.containsMouse ? Pal.hover : "transparent")
    Behavior on color { ColorAnimation { duration: Pal.anim } }

    Rectangle {
        visible: root.active
        width: 3
        height: 20
        radius: 2
        color: Pal.accent
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 12
        Text {
            Layout.preferredWidth: 22
            horizontalAlignment: Text.AlignHCenter
            text: root.icon
            color: root.active ? Pal.accentText : Pal.textDim
            font.pixelSize: Pal.fs(18)
        }
        Text {
            visible: !Pal.compact
            Layout.fillWidth: true
            text: root.name
            color: root.active ? Pal.text : Pal.textDim
            font.pixelSize: Pal.fs(13)
            font.bold: root.active
        }
        Badge {
            visible: !Pal.compact && root.tabIndex === 1 && root.app.changed.length > 0
            text: root.app.changed.length
            tone: "accent"
        }
        Rectangle {
            visible: !Pal.compact && root.tabIndex === 2 && root.app.runner.running
            width: 8; height: 8; radius: 4; color: Pal.ok
        }
        Text {
            visible: !Pal.compact && !root.showDot
            text: "⌃" + (root.tabIndex + 1)
            color: Pal.textFaint
            font.pixelSize: Pal.fs(10)
        }
    }

    Rectangle {
        visible: Pal.compact && root.showDot
        width: 9; height: 9; radius: 5
        color: root.tabIndex === 2 ? Pal.ok : Pal.accent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 7
    }

    MouseArea {
        id: nm
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.app.tab = root.tabIndex
    }
}
