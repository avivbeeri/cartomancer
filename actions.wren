import "math" for M, Vec
import "./core/action" for Action, ActionResult
import "./events" for CollisionEvent, MoveEvent, AttackEvent, LogEvent

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

class RestAction is Action {
  construct new() {
    super()
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
          target = occupying.any {|entity| entity.has("stats") }
          collectible = occupying.any {|entity| entity is Collectible }
        }
      }
      if (solid || target || collectible) {
        source.pos = old
      }
      if (target) {
        result = ActionResult.alternate(AttackAction.new(_dir))
      } else if (collectible) {
        result = ActionResult.alternate(PickupAction.new(_dir))
      }
    }

    if (!result) {
      if (source.pos != old) {
        ctx.events.add(MoveEvent.new(source))
        result = ActionResult.success
      } else if (_succeed) {
        result = ActionResult.alternate(Action.none)
      } else {
        result = ActionResult.failure
      }
    }
    System.print(result)

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
    var location = source.pos + _dir
    var occupying = ctx.getEntitiesAtTile(location.x, location.y).where {|entity| entity != source && entity.has("stats") }
    occupying.each {|target|
      // TODO: incorporate attacker's statistics and combat calculations

      var currentHP = target["stats"].base("hp")
      var defence = target["stats"].get("def")
      var attack = source["stats"].get("atk")

      var damage = attack - defence
      target["stats"].decrease("hp", damage)
      ctx.events.add(AttackEvent.new(source, target))
      ctx.events.add(LogEvent.new("%(source) attacked %(target)"))
      ctx.events.add(LogEvent.new("%(source) did %(damage) damage."))
      if (currentHP - damage <= 0) {
        ctx.events.add(LogEvent.new("%(target) was defeated."))
        ctx.removeEntity(target)
      }
    }
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
    var collectibles = occupying
    .where{|entity| entity is Collectible }


    collectibles.each {|entity|
      source["inventory"].add(entity.item)
      ctx.removeEntity(entity)
    }

    // TODO: Fire event

    return ActionResult.success
  }

}

class PlayCardAction is Action {
  construct new(handIndex) {
    super()
    _handIndex = handIndex
    _target = null
  }

  construct new(handIndex, target) {
    super()
    _handIndex = handIndex
    _target = target
  }

  perform() {
    if (!source.has("hand")) {
      // TODO: Assert?!
      return ActionResult.failure
    }

    var hand = source["hand"]
    var selectedCard = hand.removeAt(_handIndex)
    var result = ActionResult.failure
    if (selectedCard) {
      result = ActionResult.alternate(CardActionFactory.prepare(selectedCard, _target))
      var discard = source["discard"]
      discard.add(selectedCard)

      // hand size should be a statistic
      if (hand.count < 3) {
        var deck = source["deck"]
        var card = deck.drawCard()
        if (card) {
          System.print("Drew: %(card.name)")
          hand.insert(0, card)
        }
      }
    }

    return result
  }
}

class ApplyModifierAction is Action {
  construct new(modifier) {
    super()
    _modifier = modifier
    _target = source
    _responsible = source
  }

  construct new(modifier, target, responsible) {
    super()
    _modifier = modifier
    _target = target
    _responsible = responsible
  }

  perform() {
    if (_target.has("stats")) {
      ctx.events.add(LogEvent.new("%(source) inflicted %(_modifier.id) on %(_target)"))
      _target["stats"].addModifier(_modifier)
      var host = _responsible ? source : _target
      host["activeEffects"].add([ _modifier, _target.id ])
      if (host == source) {
        _modifier.extend(1)
      }
      return ActionResult.success
    }
    return ActionResult.failure
  }
}

import "./entity/collectible" for Collectible
import "./factory" for CardActionFactory
