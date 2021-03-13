import "math" for Vec
import "./core/entity" for Entity
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent

import "./entity/behaviour" for SeekBehaviour

class Shield is Creature {
  construct new(config) {
    super(config)
    _behaviour = SeekBehaviour.new(this)
  }

  construct new() {
    super()
    this["types"].add("enemy")
    this["stats"].set("def", 1)
    this["stats"].set("speed", 1)
  }

  update() {
    return _behaviour.evaluate()
  }

  notify(ctx, event) {
    if (event is PickupEvent) {
      ctx.events.add(LogEvent.new("%(this) picked up [%(event.item)] forever."))
    }
    return event
  }
}

