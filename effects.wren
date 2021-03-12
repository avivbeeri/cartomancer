import "graphics" for Canvas, Color, Font
import "math" for Vec
import "input" for Mouse
import "./keys" for InputActions
import "./palette" for EDG32
import "./core/scene" for Ui
import "./core/display" for Display

import "./deck" for Card


class CameraLerp is Ui {
  construct new(ctx, goal) {
    super(ctx)
    _camera = ctx.camera
    _start = ctx.camera * 1
    _alpha = 0
    _goal = goal
    _dir = (_goal - _camera)
  }

  finished {
    var dist = (_goal - _camera).length
    return _alpha >= 1 || dist <= speed
  }

  speed { 1 / 30 }

  update() {
    _alpha = _alpha + speed

    var cam = _start + _dir * _alpha

    if (finished) {
      cam = _goal
    }

    // We need to modify the camera in place
    _camera.x = cam.x
    _camera.y = cam.y
  }
}


var Bg = EDG32[2]
var Red = EDG32[26]

class SuccessMessage is Ui {
  construct new(ctx) {
    super(ctx)
  }
  finished { false }

  update() {
    if (InputActions.confirm.justPressed) {
      ctx.game.push(WorldScene, [ WorldGenerator.generate() ])
    }
  }

  draw() {
    Canvas.rectfill(20, 20, Canvas.width - 40, Canvas.height - 40, Bg)
    var area = Display.printCentered("Congratulations!", 30, Color.black, "quiver64")
    Display.printCentered("You captured all the cards!", 30 + area.y + 40, Color.black, "m5x7")

    Display.printCentered("Press START to play again.", Canvas.height - 40, Color.black, "m5x7")
  }
}

class FailureMessage is Ui {
  construct new(ctx) {
    super(ctx)
  }
  finished { false }
  update() {
    if (InputActions.confirm.justPressed) {
      ctx.game.push(WorldScene, [ WorldGenerator.generate() ])
    }
  }

  draw() {
    Canvas.rectfill(20, 20, Canvas.width - 40, Canvas.height - 40, Color.black)
    Canvas.rect(20, 20, Canvas.width - 40, Canvas.height - 40, Red)
    var area = Display.printCentered("You were defeated", 30, Color.white, "quiver64", Canvas.width - 50)
    Display.printCentered("Press START to try again.", Canvas.height - 40, Color.white, "m5x7")
  }
}

class Pause is Ui {
  construct new(ctx, time) {
    super(ctx)
    _end = time
    _t = 0
  }

  finished { _t >= _end}
  update() {
    _t = _t + 1
  }
}

class Animation is Ui {
  construct new(ctx, location, sprites, frameTime) {
    super(ctx)
    _sprites = sprites
    _frameTime = frameTime
    _location = location
    _t = 0
    _end = frameTime * _sprites.count
    // spritesheet/list
  }

  finished { _t >= _end}
  update() {
    _t = _t + 1
  }
  drawDiagetic() {
    if (_t < _end) {
      var f = (_t / _frameTime).floor
      _sprites[f].draw(_location.x, _location.y)
    }
  }
}
class CardDialog is Ui {
  construct new(ctx, cardId) {
    super(ctx)
    _card = Card[cardId]
    _done = false
  }
  finished { _done }
  update() {
    _done = InputActions.cancel.justPressed
  }

  draw() {
    var y = 0

    var w = Canvas.width / 4
    var h = Canvas.height / 2
    h = Mouse.y
    Canvas.rectfill(0, y, w, h, EDG32[19])
    y = y + 8
    Canvas.print(_card.name, 8, y, EDG32[25])
    y = y + 8
    // Canvas.print(_card.description, 8, y, EDG32[25])
    Display.print(_card.description, {
      "position": Vec.new(0, y),
      "font": "m5x7",
      "align": "right",
      "size": Vec.new(w, h),
      "overflow": true
    })
  }
}

import "./generator" for WorldGenerator
import "./scene/game" for WorldScene
