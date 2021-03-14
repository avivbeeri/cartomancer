import "math" for Vec
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent

import "./entity/behaviour" for SeekBehaviour

class Sword is Creature {
  construct new(config) {
    super(config)
    _behaviour = SeekBehaviour.new(this)
  }

  update() {
    return _behaviour.evaluate()
  }
}

