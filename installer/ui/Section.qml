import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 40
    radius: Pal.rLg
    color: Pal.card
    border.color: Pal.border

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Text { text: root.title; color: Pal.text; font.pixelSize: Pal.fs(15); font.bold: true }
            Text {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                wrapMode: Text.WordWrap
                color: Pal.textDim
                font.pixelSize: Pal.fs(11)
            }
        }
        ColumnLayout { id: body; Layout.fillWidth: true; spacing: 14 }
    }
}
