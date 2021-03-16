import "math" for Vec
import "./core/entity" for Entity
import "./stats" for StatGroup
import "./core/action" for Action
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent

import "./entity/behaviour" for SeekBehaviour, WaitBehaviour

class Shield is Creature {
  construct new(config) {
    super(config)
    _behaviour = SeekBehaviour.new(this)
    _behaviours = [
      WaitBehaviour.new(this),
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

