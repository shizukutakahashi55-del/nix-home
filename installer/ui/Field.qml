import QtQuick

Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: ""
    property string icon: ""
    property bool password: false
    property bool mono: false
    signal accepted()
    signal edited()

    implicitHeight: 42
    radius: Pal.rMd
    color: Pal.card
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Pal.accent : Pal.border
    Behavior on border.color { ColorAnimation { duration: Pal.animFast } }

    function focusInput() { input.forceActiveFocus() }

    Text {
        id: ico
        visible: root.icon !== ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        text: root.icon
        color: input.activeFocus ? Pal.accentText : Pal.textFaint
        font.pixelSize: Pal.fs(15)
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: root.icon !== "" ? 40 : 14
        anchors.rightMargin: 14
        verticalAlignment: TextInput.AlignVCenter
        color: Pal.text
        selectionColor: Pal.accent
        selectedTextColor: Pal.onAccent
        font.pixelSize: Pal.fs(13)
        font.family: root.mono ? Pal.mono : ""
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        clip: true
        onAccepted: root.accepted()
        onTextEdited: root.edited()
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.icon !== "" ? 40 : 14
        anchors.right: parent.right
        anchors.rightMargin: 14
        elide: Text.ElideRight
        visible: input.text.length === 0
        text: root.placeholder
        color: Pal.textFaint
        font.pixelSize: Pal.fs(13)
    }
}
