import QtQuick
import "../Core"

Text {
  property string glyph: ""
  text: glyph
  color: Config.text
  font.family: "Symbols Nerd Font"
  font.pixelSize: 18
  horizontalAlignment: Text.AlignHCenter
  verticalAlignment: Text.AlignVCenter
}
