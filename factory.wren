import "./core/action" for Action
import "./actions" for ApplyModifierAction, AttackAction
import "./stats" for Modifier

import "./entity/all" for Sword, Shield, Creature

import "./combat" for Attack, AttackType

class CardActionFactory {
  static prepare(card, target) {
    var actionClass
    if (!card.action) {
      return Action.none
    }

    System.print(card)
    if (card.action == "applyModifier") {
      var id = card.params["id"]
      var add = card.params["add"]
      var mult = card.params["mult"]
      var responsible = card.params["responsible"]
      var duration = card.params["duration"]
      var positive = card.params["positive"]
      var modifier = Modifier.new(id, add, mult, duration, positive)
      return ApplyModifierAction.new(modifier, target, !responsible || responsible == "source")
    } else if (card.action == "attack") {
      var kind = card.params["kind"] || AttackType.melee
      var base = card.params["base"] || 1
      var mana = card.params["needsMana"] || false
      return AttackAction.new(target.pos, Attack.new(base, kind, mana))
    } else {
      Fiber.abort("Could not prepare unknown action %(card.action)")
    }
  }

}

class EntityFactory {
  static prepare(config) {
    var classType = config["classType"]
    if (classType == "sword") {
      return Sword.new(config)
    }
    if (classType == "shield") {
      return Shield.new(config)
    }
    if (classType == "dummy") {
      return Creature.new(config)
    }
    Fiber.abort("Unknown entity type %(classType)")
  }

}
