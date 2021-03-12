import "math" for M, Vec
import "graphics" for Canvas
import "input" for Mouse
import "./core/display" for Display
import "./core/scene" for Ui
import "./core/action" for Action
import "./keys" for InputActions
import "./actions" for PlayCardAction
import "./palette" for EDG32, EDG32A

var scale = 1
var TILE_SIZE = 16 * scale

class CardTargetSelector is Ui {
  construct new(ctx, view, card, handIndex) {
    super(ctx)
    _done = false
    _index = handIndex
    _player = ctx.getEntityByTag("player")
    _pos = _player.pos
    _view = view
    _range = card.params["range"]
    _targets = ctx.entities.where {|entity|
      return entity.has("types") &&
        entity["types"].contains(card.target) &&
        (entity.pos - _player.pos).manhattan <= _range
    }.toList
    _current = (_targets.count > 1 && _targets[0].id == _player.id) ? 1 : 0
    if (_targets.count > 0) {
      _current = _current % _targets.count
    }
    _mouseTile = null
  }

  finished { _done }

  update() {
    var mouse = Mouse.pos
    if ((Mouse["left"].justPressed && mouse.x >= 460 && mouse.x < 470 && mouse.y >= 22 && mouse.y < 33) ||
      (InputActions.cancel.justPressed)) {
      _done = true
      return
    }
    if (InputActions.nextTarget.justPressed) {
      _current = _current + 1
    }

    var center = _view.center
    var xRange = (center.x / TILE_SIZE).ceil + 1
    var yRange = (center.y / TILE_SIZE).ceil + 1

    _mouseTile = _view.screenToWorld(mouse)

    var hover = false
    if (ctx.map[_mouseTile]["floor"] != "void" && (_mouseTile.x - _player.pos.x).abs < xRange && (_mouseTile.y - _player.pos.y).abs < yRange) {
      for (i in 0..._targets.count) {
        var target = _targets[i]
        if (target.pos == _mouseTile) {
          _current = i
          hover = true
          break
        }
      }
    } else {
      _mouseTile = null
    }

    if (InputActions.confirm.justPressed || (Mouse["left"].justPressed && hover)) {
      _done = true
      _player.action = PlayCardAction.new(_index, _targets[_current])
      return
    }

    _current = _current % _targets.count
  }

  drawDiagetic() {
    var loc = Vec.new()
    for (y in -_range.._range) {
      for (x in -_range.._range) {
        loc.x = x
        loc.y = y
        if (loc.manhattan <= _range) {
          var tile = loc + _player.pos
          Canvas.rectfill(tile.x * TILE_SIZE, tile.y * TILE_SIZE, TILE_SIZE, TILE_SIZE, EDG32A[29])
        }
      }
    }
    // Draw targeting recticle
    if (_targets.count > 0) {
      var target = _targets[_current]
      var left = (target.pos.x) * TILE_SIZE - 5
      var top = (target.pos.y) * TILE_SIZE - 5
      var right = (target.pos.x + target.size.x) * TILE_SIZE + 4
      var bottom = (target.pos.y + target.size.y) * TILE_SIZE + 4
      var vThird = ((bottom - top) / 3).round
      var hThird = ((bottom - top) / 3).round
      // top left
      Canvas.line(left, top, left + hThird, top, EDG32[7], 3)
      Canvas.line(left, top, left, top + vThird, EDG32[7], 3)


      // bottom left
      Canvas.line(left, bottom, left + hThird, bottom, EDG32[7], 3)
      Canvas.line(left, bottom, left, bottom - vThird, EDG32[7], 3)

      // top right
      Canvas.line(right, top, right - hThird, top, EDG32[7], 3)
      Canvas.line(right, top, right, top + vThird, EDG32[7], 3)

      // bottom right
      Canvas.line(right, bottom, right - hThird, bottom, EDG32[7], 3)
      Canvas.line(right, bottom, right, bottom - vThird, EDG32[7], 3)

      if (_mouseTile) {
        // Mouse selector
        Canvas.rectfill(_mouseTile.x * TILE_SIZE, _mouseTile.y * TILE_SIZE, TILE_SIZE, TILE_SIZE, EDG32A[17])
      }
    }
  }

  draw() {
    var mouse = Mouse.pos
    var c = EDG32[20]
    if (mouse.x >= 460 && mouse.x < 470 && mouse.y >= 22 && mouse.y < 33) {
      c = EDG32[21]
    }
    Canvas.rectfill(460, 22, 10, 11, c)
    Canvas.print("X", 461, 24, EDG32[19])
  }

}

class Menu is Ui {
  construct new(ctx, actions) {
    super(ctx)
    if (actions.count % 2 != 0) {
      Fiber.abort("Items list must be multiples of 2")
    }
    _done = false
    _actions = actions
    _size = _actions.count / 2
    _cursor = 0
    _width = 0
    for (i in 0..._size) {
      _width = M.max(_width, Canvas.getPrintArea(_actions[i * 2]).x)
    }
  }

  update() {
    if (InputActions.cancel.justPressed) {
      _done = true
      return
    }
    if (InputActions.confirm.justPressed) {
      var action = _actions[_cursor * 2 + 1]
      if (!action || action == "cancel") {
        _done = true
      } else if (action is Action) {
        var player = ctx.getEntityByTag("player")
        player.action = action
        _done = true
      }
    } else if (InputActions.up.justPressed) {
      _cursor = _cursor - 1
    } else if (InputActions.down.justPressed) {
      _cursor = _cursor + 1
    }
    _cursor = M.mid(0, _cursor, _size - 1)
  }

  draw() {
    Canvas.rectfill(0, 0, 10 + _width, _size * 8 + 6, Display.bg)
    var y = 4
    var i = 0
    for (i in 0..._size) {
      if (i == _cursor) {
        Canvas.print(">", 3, y, Display.fg)
      }
      Canvas.print(_actions[i * 2], 10, y, Display.fg)
      y = y + 8
    }
    Canvas.rect(1, 1, 10 + _width, _size * 8 + 6, Display.fg)
  }

  finished { _done }
}
