import "random" for Random
import "./core/action" for Action

// TODO: unfix the seed
var RNG = Random.new(0)


class Card {
  construct new(name) {
    _name = name
    _action = Action.none
  }
  name { _name }
  action { _action }
}

class Deck {
  construct new(cardList) {
    _cards = cardList.toList || []
    // index 0 is the top
    // index count - 1 is the bottom
  }

  isEmpty { _cards.isEmpty }
  count { _cards.count }

  iterate(iter) { _cards.iterate(iter) }
  iteratorValue(iter) { _cards.iteratorValue(iter) }

  shuffle() {
    RNG.shuffle(_cards)
    return this
  }

  drawCard() {
    if (isEmpty) {
      return null
    }
    return _cards.removeAt(0)
  }

  drawCards(n) {
    var drawn = peek(n)
    _cards = _cards.skip(n).toList
    return drawn
  }

  peek(n) {
    return _cards.take(n).toList
  }

  addToBottom(card) {
    _cards.add(card)
  }
  addToTop(card) {
    _cards.insert(0, card)
  }
}
