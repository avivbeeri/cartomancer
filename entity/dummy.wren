import "math" for Vec
import "./core/entity" for Entity
import "./actions" for MoveAction
import "./stats" for StatGroup

class Dummy is Entity {
  construct new() {
    super()
    this["stats"] = StatGroup.new({
      "atk": 1,
      "def": 1,
      "hp": 1,
      "hp-max": 1
    })
  }

  update() {
    return MoveAction.new(Vec.new(1, 0), true)
  }
}

