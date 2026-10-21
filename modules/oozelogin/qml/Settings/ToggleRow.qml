import QtQuick
import "../Core"

FormRow {
  id: root

  property string key: ""

  Toggle {
    checked: !!Config.v[root.key]
    onToggled: v => Config.set(root.key, v)
  }
}
