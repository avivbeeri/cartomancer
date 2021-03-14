import "math" for Vec
import "./core/entity" for Entity
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent

import "./entity/behaviour" for RangedBehaviour

class Thunder is Creature {
  construct new(config) {
    super(config)
    _behaviour = RangedBehaviour.new(this)
  }

  update() {
    return _behaviour.evaluate()
  }
}

