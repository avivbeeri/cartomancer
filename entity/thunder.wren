import "math" for Vec
import "./core/entity" for Entity
import "./core/action" for Action
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent

import "./entity/behaviour" for RangedBehaviour, SeekBehaviour

class Thunder is Creature {
  construct new(config) {
    super(config)
    _behaviours = [
      RangedBehaviour.new(this),
      SeekBehaviour.new(this)
    ]
  }

  update() {
    var action
    for (behaviour in _behaviours) {
      action = behaviour.evaluate()
      if (action) {
        break
      }
    }
    return action || Action.none
  }
}

