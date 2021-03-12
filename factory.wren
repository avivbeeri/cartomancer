import "./core/action" for Action
import "./actions" for ApplyModifierAction, AttackAction
import "./stats" for Modifier

import "./combat" for Attack, AttackType

class CardActionFactory {
  static prepare(card, target) {
    var actionClass
    if (!card.action) {
      return Action.none
    }

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
      return AttackAction.new(target.pos, Attack.new(base, kind))
    } else {
      Fiber.abort("Could not prepare unknown action %(card.action)")
    }
  }

}
