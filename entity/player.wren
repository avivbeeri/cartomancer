import "core/entity" for Entity
import "core/dataobject" for DataObject
import "./stats" for StatGroup
import "./deck" for Deck, Card
import "./entity/creature" for Creature
import "./rng" for RNG

class Player is Creature {
  construct new() {
    super()
    _action = null
    this["stats"].set("mana", 0)
    this["stats"].set("manaMax", 5)

    this["discard"] = []
    this["deck"] = Deck.new(RNG.sample(Card.all, 3)).shuffle()
    this["hand"] = this["deck"].drawCards(3)
  }

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
    super.endTurn()
    this["stats"].increase("mana", 1, "manaMax")
  }
}

import "./events" for LogEvent
