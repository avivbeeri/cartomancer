import "random" for Random
import "graphics" for ImageData, Canvas, Font
import "./core/action" for Action
import "./palette" for EDG32

var Frame = ImageData.loadFromFile("res/img/card-frame.png")

// TODO: unfix the seed
var RNG = Random.new(0)


class Card {
  construct new(name) {
    _name = name
    _action = Action.none
  }
  construct new(name, action) {
    _name = name
    _action = action || Action.none
  }

  construct new(name, action, imagePath) {
    _name = name
    _action = action || Action.none
    _image = ImageData.loadFromFile(imagePath)
  }

  name { _name }
  action { _action }
  image { _image }
  image=(v) { _image = v }

  draw(x, y) {
    Frame.draw(x, y)
    Canvas.rectfill(x + 8, y + 8, 80, 19, EDG32[14])
    Canvas.line(x + 8, y + 27, x + 87, y + 27, EDG32[15])
    var width = Font["quiver16"].getArea(name).x
    var textLeft = x + 8 + (80 - width) / 2
    Canvas.print(name, textLeft + 1, y + 10, EDG32[24], "quiver16")
    Canvas.print(name, textLeft, y + 9, EDG32[19], "quiver16")
    if (_image) {
      _image.draw(x, y)
    }
  }
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
