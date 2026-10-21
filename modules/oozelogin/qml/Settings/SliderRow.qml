import QtQuick
import "../Core"

FormRow {
  id: root

  property string key: ""
  property int from: 0
  property int to: 100
  property string suffix: ""

  Slider {
    from: root.from
    to: root.to
    suffix: root.suffix
    value: Number(Config.v[root.key])
    onMoved: v => Config.set(root.key, v)
  }
}
