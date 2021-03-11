import "math" for Vec
import "./core/entity" for Entity
import "./actions" for MoveAction
import "./stats" for StatGroup

class Dummy is Entity {
  construct new() {
    super()
    this["types"] = [ "creature", "enemy" ]
    this["stats"] = StatGroup.new({
      "atk": 1,
      "def": 1,
      "hp": 1,
      "hp-max": 1,
      "speed": 1
    })
  }

  speed { this["stats"].get("speed") }

  update() {
    return MoveAction.new(Vec.new(1, 0), true)
  }

  endTurn() {
    this["stats"].tick()
  }
}

