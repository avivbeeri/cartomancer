import "core/entity" for Entity
import "core/dataobject" for DataObject
import "./stats" for StatGroup

class Player is Entity {
  construct new() {
    super()
    _action = null
    this["activeEffects"] = []
    this["types"] = [ "creature" ]
    this["stats"] = StatGroup.new({
      "atk": 1,
      "def": 0,
      "hp": 1,
      "hp-max": 1,
      "mana": 0,
      "mana-max": 0,
      "speed": 6
    })
    this["inventory"] = []
  }

  speed { this["stats"].get("speed") }

  action { _action }
  action=(v) {
    _action = v
  }

  update() {
    var action = _action
    _action = null
    return action
  }

  endTurn() {
    // this["stats"].tick()
    for (effect in this["activeEffects"]) {
      var modifier = effect[0]
      var targetId = effect[1]
      var target = ctx.getEntityById(targetId)
      if (target) {
        modifier.tick()
        if (modifier.duration == 0) {
          target["stats"].removeModifier(modifier.id)
          ctx.events.add(LogEvent.new("%(target) is no longer affected by %(modifier.id)"))
        }
      }
    }
  }
}
import "./events" for LogEvent
