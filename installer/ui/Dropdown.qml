import QtQuick

// Solo el botón: el menú desplegable se dibuja en la capa superior de la
// ventana (Installer.qml → overlay) para que reciba los clics por encima de todo.
Item {
    id: root
    property var app
    property var model: []
    property string value: ""
    property bool openUp: true
    signal picked(string v)

    implicitHeight: 38
    implicitWidth: 260

    Rectangle {
        anchors.fill: parent
        radius: Pal.rMd
        color: Pal.raised
        border.color: (root.app && root.app.ddOpen) ? Pal.accent : Pal.border

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.right: arrow.left
            elide: Text.ElideMiddle
            text: root.value !== "" ? root.value : "Elegir archivo…"
            color: Pal.text
            font.pixelSize: Pal.fs(12)
        }
        Text {
            id: arrow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            text: root.openUp ? "▴" : "▾"
            color: Pal.textDim
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.app) root.app.openDropdown(root, root.model, root.value, root.openUp, v => root.picked(v))
        }
    }
}
