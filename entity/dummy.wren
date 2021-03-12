import "math" for Vec
import "./core/entity" for Entity
import "./actions" for MoveAction
import "./stats" for StatGroup
import "./entity/creature" for Creature

class Dummy is Creature {
  construct new() {
    super()
    this["types"].add("enemy")
    this["loot"] = ["card:shield"]
    this["stats"].set("def", 1)
    this["stats"].set("speed", 1)
  }

  update() {
    return MoveAction.new(Vec.new(1, 0), true)
  }
}

