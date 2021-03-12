import "math" for M, Vec
import "./core/action" for Action, ActionResult
import "./events" for CollisionEvent,
  CommuneEvent,
  MoveEvent,
  AttackEvent,
  LogEvent

import "./combat" for Attack

class LogAction is Action {
  construct new() {
    super()
  }

  perform() {
    System.print("You make journal notes")
    return ActionResult.success
  }
}

class CommuneAction is Action {
  construct new() {
    super()
  }

  perform() {
    if (source.has("stats") &&
        source["stats"].has("mana")) {

      if (source["stats"].get("mana") < source["stats"].get("manaMax")) {
        // TODO: Assert?!
        ctx.events.add(CommuneEvent.new(source, false))
        return ActionResult.failure
      }
      source["stats"].set("mana", -1)
    }

    var discard = source["discard"]
    var deck = source["deck"]
    deck.addToBottom(discard)
    deck.shuffle()
    source["discard"] = []

    source["hand"] = deck.drawCards(3)
    ctx.events.add(CommuneEvent.new(source, true))

    return ActionResult.success
  }
}

class SleepAction is Action {
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
        result = ActionResult.alternate(AttackAction.new(source.pos + _dir, Attack.melee(source)))
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
  construct new(location, attack) {
    super()
    _location = location
    _attack = attack
  }

  perform() {
    if (source.has("stats") &&
        source["stats"].has("mana")) {

      if (source["stats"].get("mana") <= 0) {
        // TODO: Assert?!
        return ActionResult.failure
      }
      source["stats"].decrease("mana", 1)
    }


    var location = _location
    var occupying = ctx.getEntitiesAtTile(location.x, location.y).where {|entity| entity.has("stats") }
    occupying.each {|target|
      var currentHP = target["stats"].base("hp")
      var defence = target["stats"].get("def")
      var damage = _attack.damage - defence

      target["stats"].decrease("hp", damage)
      ctx.events.add(AttackEvent.new(source, target, _attack.attackType))
      ctx.events.add(LogEvent.new("%(source) attacked %(target)"))
      ctx.events.add(LogEvent.new("%(source) did %(damage) damage."))
      if (currentHP - damage <= 0) {
        ctx.events.add(LogEvent.new("%(target) was defeated."))
        // ctx.removeEntity(target)
      }
    }
    return ActionResult.success
  }

}

class PickupAction is Action {
  construct new(dir) {
    super()
    _dir = dir
  }
  perform() {
    var target = source.pos + _dir
    var occupying = ctx.getEntitiesAtTile(target.x, target.y).where {|entity| entity != source }
    var collectibles = occupying
    .where{|entity| entity is Collectible }


    collectibles.each {|entity|
      var item = entity.item.split(":")
      var kind = item[0]
      var id = item[1]
      if (kind == "card") {
        source["hand"].add(Card[id])
      } else {
        source["inventory"].add(entity.item)
      }
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
    if (!source.has("hand") || source.has("stats") && source["stats"].get("mana") <= 0) {
      // TODO: Assert?!
      return ActionResult.failure
    }

    source["stats"].decrease("mana", 2)

    var hand = source["hand"]
    var selectedCard = hand.removeAt(_handIndex)
    var result = ActionResult.failure
    if (selectedCard) {
      ctx.events.add(LogEvent.new("%(source) played the '%(selectedCard.name)' card"))

      if (!_target) {
        // Auto-select target
        // based on card data
        if (selectedCard.target == "self") {
          _target = source
        }
      }

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
      if (_modifier.positive) {
        ctx.events.add(LogEvent.new("%(_target) gained %(_modifier.id)!"))
      } else {
        ctx.events.add(LogEvent.new("%(source) inflicted %(_modifier.id) on %(_target)"))
      }
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

// -------- UNTESTED PROTOTYPE ------
// Assumes that partial failures are acceptible.

class MultiAction is Action {
  construct new(actionList) {
    super()
    _actionList = actionList
  }

  perform() {
    var result = ActionResult.success
    var failed = false
    for (step in _actionList) {
      while (true) {
        step.bind(source)
        var stepResult = step.perform()
        if (!stepResult.succeeded) {
          result = ActionResult.failure
          failed = true
          break
        }
        if (!stepResult.alternate) {
          break
        }
        step = result.alternate
      }
      if (failed) {
        break
      }
    }
    return result
  }
}


import "./entity/collectible" for Collectible
import "./factory" for CardActionFactory
import "./deck" for Card
