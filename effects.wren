import "graphics" for Canvas, Color, Font
import "input" for Keyboard
import "./core/scene" for Ui
import "./core/display" for Display


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

var Bg = Color.hex("#ead4aa")
var Red = Color.hex("#ff0044")

class SuccessMessage is Ui {
  construct new(ctx) {
    super(ctx)
  }
  finished { false }

  update() {
    if (Keyboard["space"].justPressed) {
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
    if (Keyboard["space"].justPressed) {
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

import "./generator" for WorldGenerator
import "./scene/game" for WorldScene
