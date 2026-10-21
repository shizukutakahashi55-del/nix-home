import QtQuick
import "../Core"

FormRow {
  id: root

  property string key: ""
  property string placeholder: ""

  TextBox {
    placeholder: root.placeholder
    text: String(Config.v[root.key] ?? "")
    onCommitted: v => Config.set(root.key, v)
  }
}
