import QtQuick
import QtQuick.Layouts

GridLayout {
    id: root
    property string label: ""
    property string hint: ""
    default property alias control: ctl.data

    Layout.fillWidth: true
    columns: root.width > 560 ? 2 : 1
    columnSpacing: 18
    rowSpacing: 8

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text { Layout.fillWidth: true; text: root.label; color: Pal.text; font.pixelSize: Pal.fs(13); wrapMode: Text.WordWrap }
        Text {
            Layout.fillWidth: true
            visible: root.hint !== ""
            text: root.hint
            wrapMode: Text.WordWrap
            color: Pal.textFaint
            font.pixelSize: Pal.fs(11)
        }
    }
    RowLayout {
        id: ctl
        Layout.alignment: root.columns === 2 ? Qt.AlignRight : Qt.AlignLeft
        spacing: 10
    }
}
