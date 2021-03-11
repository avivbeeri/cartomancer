import "random" for Random
import "graphics" for ImageData, Canvas, Font, Color
import "./core/action" for Action
import "./palette" for EDG32, EDG32A

var Frame = ImageData.loadFromFile("res/img/card-frame.png")

// TODO: unfix the seed
var RNG = Random.new(0)
var DefaultTint = EDG32A[24]

class Card {
  copy {
    return Card.new({
      "id": _id,
      "name": _name,
      "action": _action,
      "image": _imagePath,
      "tint": _tintIndex,
      "target": _target
    })
  }
  construct new(data) {
    if (data is Map) {
      _id = data["id"]
      _name = data["name"]
      _action = action || Action.none
      _imagePath = data["image"]
      if (_imagePath) {
        _image = ImageData.loadFromFile(_imagePath)
      }
      _tintIndex = data["tint"] || 19
      _tint = EDG32A[_tintIndex]
      _target = data["target"]
    } else {
      _name = data
      _action = Action.none
      _tint = DefaultTint
    }
  }

  name { _name }
  action { _action }
  image { _image }
  image=(v) { _image = v }
  requiresInput {
    return _target && _target != "self"
  }

  draw(x, y) {
    x = x.round
    y = y.round
    Frame.draw(x, y)
    Canvas.rectfill(x + 8, y + 8, 80, 144, _tint)
    Canvas.rectfill(x + 8, y + 8, 80, 19, EDG32[14])
    Canvas.line(x + 8, y + 27, x + 87, y + 27, EDG32[15])
    var width = Font["quiver16"].getArea(name).x
    var textLeft = x + 8 + (80 - width) / 2
    Canvas.print(name, textLeft + 2, y + 10, EDG32[24], "quiver16")
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
