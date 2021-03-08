import "./core/action" for Action, ActionResult
import "math" for M, Vec
import "./events" for CollisionEvent, MoveEvent
import "./entity/collectible" for Collectible

class LogAction is Action {
  construct new() {
    super()
  }

  perform() {
    System.print("You make journal notes")
    return ActionResult.success
  }

}
class SleepAction is Action {
  cost { 2 }
  construct new() {
    super()
  }

  perform() {
    System.print("You sleep, and awaken refreshed.")
    return ActionResult.alternate(LogAction.new())
  }
}

class MoveAction is Action {
  construct new(dir, alwaysSucceed) {
    super()
    _dir = dir
    _succeed = alwaysSucceed
  }

  construct new(dir) {
    super()
    _dir = dir
    _succeed = false
  }

  getOccupying(pos) {
    return ctx.getEntitiesAtTile(pos.x, pos.y).where {|entity| entity != source }
  }

/*
  handleCollision(pos) {
    var occupying = getOccupying(pos)
    var solidEntity = false
    for (entity in occupying) {
      var event = entity.notify(ctx, CollisionEvent.new(this, entity, pos))
      if (!event.cancelled) {
        ctx.events.add(event)
        solidEntity = true
      }
    }
    return solidEntity
  }
  */

  perform() {
    System.print("moving")
    var old = source.pos * 1
    source.vel = _dir
    source.pos.x = source.pos.x + source.vel.x
    source.pos.y = source.pos.y + source.vel.y

    var result

    if (source.pos != old) {
      var solid = ctx.isSolidAt(source.pos)
      var target = false
      var collectible = false
      if (!solid) {
        var occupying = getOccupying(source.pos)
        if (occupying.count > 0) {
          solid = solid || occupying.any {|entity| entity.has("solid") }
          target = occupying.any {|entity| entity.has("health") }
          collectible = occupying.any {|entity| entity is Collectible}
        }
      }
      if (solid || target || collectible) {
        source.pos = old
      }
      if (target) {
        result = ActionResult.alternate(AttackAction.new(_dir))
      } else if (collectible) {
        System.print("Collectible found")
        result = ActionResult.alternate(PickupAction.new(_dir))
      }
    }

    if (!result) {
      if (source.pos != old) {
        ctx.events.add(MoveEvent.new(source))
        result = ActionResult.success
      } else if (_succeed) {
        result = ActionResult.alternate(Action.none)
      }
    }

    if (source.vel.length > 0) {
      source.vel = Vec.new()
    }
    return result
  }
}

class AttackAction is Action {
  construct new(dir) {
    super()
    _dir = dir
    _succeed = false
  }
  perform() {
    var target = source.pos + _dir
    var occupying = ctx.getEntitiesAtTile(target.x, target.y).where {|entity| entity != source }
    occupying.each {|entity| ctx.removeEntity(entity) }
    return ActionResult.success
  }

}

class PickupAction is Action {
  construct new(dir) {
    super()
    _dir = dir
    _succeed = false
  }
  perform() {
    var target = source.pos + _dir
    var occupying = ctx.getEntitiesAtTile(target.x, target.y).where {|entity| entity != source }
    occupying
    .where{|entity| entity is Collectible }
    .each {|entity| ctx.removeEntity(entity) }
    // TODO: Add entity to inventory
    // Fire event
    return ActionResult.success
  }

}
