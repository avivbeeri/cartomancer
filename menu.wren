import "math" for M, Vec
import "graphics" for Canvas
import "./core/display" for Display
import "./core/scene" for Ui
import "./core/action" for Action
import "./keys" for InputActions
import "./actions" for PlayCardAction
import "./palette" for EDG32, EDG32A

class CardTargetSelector is Ui {
  construct new(ctx, card, handIndex) {
    super(ctx)
    _done = false
    _index = handIndex
    _player = ctx.getEntityByTag("player")
    _pos = _player.pos
    _range = 3
    _targets = ctx.entities.where {|entity| (entity.pos - _player.pos).manhattan <= _range }.toList
    _current = (_targets[0].id == _player.id) ? 1 : 0
  }

  finished { _done }

  update() {
    if (InputActions.cancel.justPressed) {
      _done = true
      return
    }
    if (InputActions.confirm.justPressed) {
      _done = true
      _player.action = PlayCardAction.new(_index, _targets[_current])
      return
    }
    if (InputActions.nextTarget.justPressed) {
      _current = _current + 1
    }
    _current = _current % _targets.count
  }

  draw() {
    var target = _targets[_current]
    var loc = Vec.new()
    for (y in -_range.._range) {
      for (x in -_range.._range) {
        loc.x = x
        loc.y = y
        if (loc.manhattan <= _range) {
          var tile = loc + _player.pos
          Canvas.rectfill(tile.x * 32, tile.y * 32, 32, 32, EDG32A[29])
        }
      }
    }
    // Draw targeting recticle
    var left = (target.pos.x) * 32 - 4
    var top = (target.pos.y) * 32 - 4
    var right = (target.pos.x + target.size.x) * 32 + 4
    var bottom = (target.pos.y + target.size.y) * 32 + 4
    // top left
    Canvas.line(left, top, left + (right - left) / 3, top, EDG32[7], 3)
    Canvas.line(left, top, left, top + (bottom - top) / 3, EDG32[7], 3)


    // bottom left
    Canvas.line(left, bottom, left + (right - left) / 3, bottom, EDG32[7], 3)
    Canvas.line(left, bottom, left, bottom - (bottom - top) / 3, EDG32[7], 3)

    // top right
    Canvas.line(right, top, right - (right - left) / 3, top, EDG32[7], 3)
    Canvas.line(right, top, right, top + (bottom - top) / 3, EDG32[7], 3)

    // bottom right
    Canvas.line(right, bottom, right - (right - left) / 3, bottom, EDG32[7], 3)
    Canvas.line(right, bottom, right, bottom - (bottom - top) / 3, EDG32[7], 3)
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
