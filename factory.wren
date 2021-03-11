import "./core/action" for Action
import "./actions" for ApplyModifierAction
import "./stats" for Modifier

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
      var modifier = Modifier.new(id, add, mult)
      return ApplyModifierAction.new(modifier, target)
    } else {
      Fiber.abort("Could not prepare unknown action %(card.action)")
    }
  }

}
