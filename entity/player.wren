import "core/entity" for Entity
import "core/dataobject" for DataObject

class Player is Entity {
  construct new() {
    super()
    _action = null
    this["#speed"] = 6
    this["health"] = 1
  }

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


class PlayerData is DataObject {
  construct new() {
    super()
    this["hunger"] = 5
    this["energy"] = 5
    this["temperature"] = 1
  }
}
