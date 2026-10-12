import QtQuick

Rectangle {
    id: root
    property var options: []        // [{ id: "a", label: "A" }, …]
    property string value: ""
    signal picked(string id)

    implicitHeight: 36
    implicitWidth: row.implicitWidth + 8
    radius: Pal.rMd + 2
    color: Pal.raised
    border.color: Pal.border

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool sel: modelData.id === root.value
                height: root.height - 8
                width: lbl.implicitWidth + 26
                radius: Pal.rMd
                color: sel ? Pal.accent : (m.containsMouse ? Pal.hover : "transparent")
                Behavior on color { ColorAnimation { duration: Pal.animFast } }
                Text {
                    id: lbl
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent.sel ? Pal.onAccent : Pal.textDim
                    font.pixelSize: Pal.fs(12)
                    font.bold: parent.sel
                }
                MouseArea {
                    id: m
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(modelData.id)
                }
            }
        }
    }
}
