import "math" for Vec
import "./core/entity" for Entity
import "./core/action" for Action
import "./stats" for StatGroup
import "./events" for LogEvent, PickupEvent, AttackEvent
import "./entity/creature" for Creature
import "./entity/behaviour" for ProjectileBehaviour

class Fireball is Creature {
  construct new(config) {
    super(config)
    _behaviours = [
      ProjectileBehaviour.new(this),
    ]
    _new = true
  }

  update() {
    if (_new) {
      // one-time setup
      var source = this["source"]
      var dir = this["direction"] = (pos - this["source"]).unit
      System.print("direction: %(source)")
      System.print("direction: %(dir)")
      _new = false
    }


    var action
    for (behaviour in _behaviours) {
      action = behaviour.evaluate()
      if (action) {
        break
      }
    }
    return action || Action.none
  }

  notify(event) {
    event = super.notify(event)
    if (event is AttackEvent) {
      event.cancel()
    }
    return event
  }
}

import "./combat" for AttackType
