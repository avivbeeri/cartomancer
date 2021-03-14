import "math" for Vec
import "./core/entity" for Entity
import "./core/action" for Action
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent, AttackEvent
import "./entity/behaviour" for SpawnBehaviour, SeekBehaviour

class Wizard is Creature {
  construct new(config) {
    super(config)
    _behaviours = [
      SpawnBehaviour.new(this, 10, "fireball"),
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

import "./combat" for AttackType
