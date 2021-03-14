import "math" for Vec
import "./core/entity" for Entity
import "./core/action" for Action
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent, AttackEvent
import "./entity/behaviour" for RangedBehaviour, SeekBehaviour
import "./actions" for ApplyModifierAction

class Shadow is Creature {
  construct new(config) {
    super(config)
    _behaviours = [
      RangedBehaviour.new(this, 5) {|target|

        var id = config["effect"]["id"]
        var add = config["effect"]["add"]
        var mult = config["effect"]["mult"]
        var responsible = config["effect"]["responsible"]
        var duration = config["effect"]["duration"]
        var positive = config["effect"]["positive"]
        var modifier = Modifier.new(id, add, mult, duration, positive)
        return ApplyModifierAction.new(modifier, target, !config["effect"]["responsible"] || false)
      },
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
import "./stats" for Modifier
