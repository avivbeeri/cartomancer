import "core/entity" for Entity
import "core/dataobject" for DataObject
import "./stats" for StatGroup

class Player is Entity {
  construct new() {
    super()
    _action = null
    this["stats"] = StatGroup.new({
      "atk": 1,
      "def": 0,
      "hp": 1,
      "hp-max": 1,
      "mana": 0,
      "mana-max": 0,
      "speed": 6
    })
    this["inventory"] = []
  }

  speed { this["stats"].get("speed") }

  action { _action }
  action=(v) {
    _action = v
  }

  update() {
    var action = _action
    _action = null
    return action
  }
}
