import "core/entity" for Entity
import "core/dataobject" for DataObject
import "./stats" for StatGroup

class Creature is Entity {
  construct new() {
    super()
    this["activeEffects"] = []
    this["types"] = [ "creature" ]
    this["stats"] = StatGroup.new({
      "atk": 1,
      "def": 0,
      "hp": 1,
      "hpMax": 1,
      "speed": 6
    })
    this["inventory"] = []
  }

  speed { this["stats"].get("speed") }
  endTurn() {
    var activeEffects = this["activeEffects"]
    for (effect in activeEffects) {
      var modifier = effect[0]
      var targetId = effect[1]
      var target = ctx.getEntityById(targetId)

      modifier.tick()
      if (modifier.done && target) {
        target["stats"].removeModifier(modifier.id)
        ctx.events.add(LogEvent.new("%(target) is no longer affected by %(modifier.id)"))
      }

      if (!target || modifier.done) {
        var n = activeEffects.indexOf(effect)
        activeEffects.removeAt(n)
      }
    }
    this["stats"].tick()
  }
}
import "./events" for LogEvent
