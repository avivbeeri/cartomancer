import "math" for Vec
import "./core/entity" for Entity
import "./actions" for MoveAction

class Dummy is Entity {
  construct new() {
    super()
  }

  update() {
    return MoveAction.new(Vec.new(1, 0), true)
  }
}

