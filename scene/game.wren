import "graphics" for ImageData, Canvas, Color
import "input" for Keyboard, Mouse
import "math" for Vec, M

import "./palette" for EDG32

import "./core/display" for Display
import "./core/scene" for Scene
import "./core/event" for EntityRemovedEvent, EntityAddedEvent

import "./keys" for InputGroup, InputActions
import "./menu" for Menu
import "./events" for CollisionEvent, MoveEvent, GameEndEvent, AttackEvent
import "./actions" for MoveAction, SleepAction, RestAction, PlayCardAction
import "./entity/all" for Player, Dummy, Collectible

import "./sprites" for StandardSpriteSet

// Timer variables
var T = 0
var F = 0

// Is the view static?
var STATIC = false

var SCALE = 4
var TILE_SIZE = 8 * SCALE

class WorldScene is Scene {
  construct new(args) {
    // Args are currently unused.

    _camera = Vec.new()
    _moving = false
    _tried = false
    _ui = []
    _diageticUi = []

    _world = args[0]
    var player = _world.active.getEntityByTag("player")

    _camera.x = player.pos.x * TILE_SIZE
    _camera.y = player.pos.y * TILE_SIZE
    _lastPosition = player.pos
  }

  updateAllUi() {
    var uiList
    if (!_diageticUi.isEmpty) {
      uiList = _diageticUi
    } else if (!_ui.isEmpty) {
      uiList = _ui
    }
    if (uiList) {
      uiList[0].update()
      if (uiList[0].finished) {
        uiList.removeAt(0)
      }
      return true
    }
    return false
  }

  update() {
    _zone = _world.active
    T = T + (1/60)
    F = (T * 2).floor % 2

    var player = _zone.getEntityByTag("player")

    if (updateAllUi()) {
      return
    }

    _moving = false
    var pressed = false

    if (player) {
      // Overzone interaction
      if (InputActions.interact.justPressed) {
        _ui.add(Menu.new(_zone, [
          "Cook", null,
          "Sleep", SleepAction.new(),
          "Cancel", "cancel"
        ]))
        return
      }

      // -------- DEBUG  BEGIN --------
      var deck = player["deck"]
      var hand = player["hand"]
      var mouse = Mouse.pos
      var y = Canvas.height - (hand.count + 2 + deck.count) * 8
      Canvas.print("Hand:", 0, y - 8, Color.white)
      var index = 0
      for (card in hand) {
        var text = "%(card.name)"
        if ((index+1) <= InputActions.options.count) {
          text = "%(index+1): %(card.name)"
        }
        if (((index+1) < InputActions.options.count && InputActions.options[index+1].justPressed) || (Mouse["left"].justPressed && mouse.y >= y && mouse.y < y + 8 && mouse.x < text.count * 8)) {
          player.action = PlayCardAction.new(index)
        }
        y = y + 8
        index = index + 1
      }
      // ------ DEBUG --------

      if (!player.action && !_tried) {
        if (InputActions.rest.firing) {
          player.action = RestAction.new()
        } else {
          var move = Vec.new()
          if (InputActions.left.firing) {
            move.x = -1
          } else if (InputActions.right.firing) {
            move.x = 1
          } else if (InputActions.up.firing) {
            move.y = -1
          } else if (InputActions.down.firing) {
            move.y = 1
          }
          if (move.length > 0) {
            player.action = MoveAction.new(move)
          }
        }
      }
    }
    pressed = InputActions.directions.any {|key| key.down }

    _world.update()
    // TODO: remove this
    if (InputActions.inventory.justPressed) {
      var dummy = _zone.addEntity(Dummy.new())
      dummy.pos = Vec.new(0, 0)
    }
    for (event in _zone.events) {
      if (event is EntityAddedEvent) {
        System.print("Entity %(event.id) was added")
      } else if (event is EntityRemovedEvent) {
        System.print("Entity %(event.id) was removed")
      } else if (event is GameEndEvent) {
        var result = event.won ? "won" : "lost"
        System.print("The game has ended. You have %(result).")
        if (event.won) {
          _ui.add(SuccessMessage.new(this))
        } else {
          // TOOD: Add more context about cause of failure
          _ui.add(FailureMessage.new(this))
        }
      } else if (event is MoveEvent) {
        if (event.target is Player) {
          _moving = true
          _ui.add(CameraLerp.new(this, event.target.pos * TILE_SIZE))
        }
      } else if (event is AttackEvent) {
        if (event.source is Player) {
          _tried = true
          _moving = false
        }
      } else if (event is CollisionEvent) {
        if (event.source is Player) {
          _tried = true
          _moving = false
        }
      }
    }
    if (!pressed) {
      _tried = false
    }
  }

  draw() {
    _zone = _world.active
    var player = _zone.getEntityByTag("player")
    var X_OFFSET = 4
    var sprites = StandardSpriteSet
    Canvas.cls(Display.bg)

    var CARD_UI_TOP = 224

    var cx = (Canvas.width - X_OFFSET - 20) / 2
    var cy = (Canvas.height - CARD_UI_TOP) / 2 + TILE_SIZE * 2
    if (!STATIC) {
      Canvas.offset((cx-_camera.x -X_OFFSET).floor, (cy-_camera.y).floor)
    }
    var x = Canvas.width - 20

    var xRange = 14
    var yRange = 10

    for (dy in -yRange...yRange) {
      for (dx in -xRange...xRange) {
        var x = _lastPosition.x + dx
        var y = _lastPosition.y + dy
        var sx = x * TILE_SIZE + X_OFFSET
        var sy = y * TILE_SIZE
        var tile = _zone.map[x, y]
        if (tile["floor"] == "blank" || tile["floor"] == "void") {
          // Intentionally do nothing
        } else if (tile["floor"] == "solid") {
          Canvas.rectfill(sx, sy, TILE_SIZE, TILE_SIZE, Display.fg)
        } else if (tile["floor"] == "door") {
          var list = sprites[tile["floor"]]
          list[0].draw(sx, sy)
        } else if (_zone["floor"] == "void") {
          var list = sprites["void"]
          list[0].draw(sx, sy)
        } else {
          // figure out neighbours
          var index = 0
          // Up
          var testTile

          testTile = _zone.map[x, y - 1]["floor"]
          if (testTile == "wall" || testTile == "void") {
            index = index + 1
          }
          // Right
          testTile = _zone.map[x+1, y]["floor"]
          if (testTile == "wall" || testTile == "void") {
            index = index + 2
          }
          //Down
          testTile = _zone.map[x, y+1]["floor"]
          if (testTile == "wall" || testTile == "void") {
            index = index + 4
          }
          // Left
          testTile = _zone.map[x - 1, y]["floor"]
          if (testTile == "wall" || testTile == "void") {
            index = index + 8
          }

          if (index == 15) {
            testTile = _zone.map[x - 1, y - 1]["floor"]
            if (testTile == "tile") {
              index = 15
            }
            testTile = _zone.map[x + 1, y - 1]["floor"]
            if (testTile == "tile") {
              index = 16
            }
            testTile = _zone.map[x + 1, y + 1]["floor"]
            if (testTile == "tile") {
              index = 17
            }
            testTile = _zone.map[x - 1, y + 1]["floor"]
            if (testTile == "tile") {
              index = 18
            }
          }


          Canvas.print(index, sx, sy, Color.green)

          var list = sprites["wall"]
          list[index].draw(sx, sy)
        }
      }
    }

    for (entity in _zone.entities) {
      var sx = entity.pos.x * TILE_SIZE + X_OFFSET
      var sy = entity.pos.y * TILE_SIZE
      if (entity is Player) {
        if (!STATIC) {
          continue
        }
        // We draw this
        if (_moving) {
          var s = (T * 5).floor % 2
          sprites["playerWalk"][s].draw(sx, sy)
        } else {
          sprites["playerStand"][s].draw(sx, sy)
        }

      } else if (entity is Dummy) {
        sprites["sword"][F].draw(sx, sy)
      } else if (entity is Collectible) {
        sprites["card"][0].draw(sx, sy - F * 2)
      } else {
        Canvas.print(entity.type.name[0], sx, sy, Color.red)
      }
    }

    for (ui in _diageticUi) {
      var block = ui.draw()
      if (block) {
        break
      }
    }

    Canvas.offset()

    // Put a background on the player for readability
    if (player && !STATIC) {
      var tile = _zone.map[player.pos]
      // 1-bit clarity system
      /*
      if (tile["floor"] || _zone["floor"]) {
        Canvas.rectfill(cx, cy, TILE_SIZE, TILE_SIZE, Display.bg)
      }
      */
      // Draw player in screen center
      if (_moving) {
        sprites["playerWalk"][F].draw(cx, cy)
      } else {
        sprites["playerStand"][F].draw(cx, cy)
      }
    }

    if (player) {
      var inv = player["inventory"]
      for (i in 0...inv.count) {
        Canvas.print(inv[i], 0, i * 8, Color.white)
      }

      Canvas.rectfill(0, CARD_UI_TOP, Canvas.width, Canvas.height - CARD_UI_TOP, EDG32[28])
      Canvas.line(0, CARD_UI_TOP, Canvas.width, CARD_UI_TOP, EDG32[29], 2)

      var deck = player["deck"]
      Canvas.rect(5, CARD_UI_TOP + 4, 59, 89, EDG32[27])
      if (!deck.isEmpty) {
        var total = M.min(4, (deck.count / 3).ceil)
        System.print("%(deck.count) - %(total)")
        for (offset in 1..total) {
          if (offset < total) {
          sprites["cardback"]
          .transform({ "mode": "MONO", "foreground": EDG32[3 + total - offset], "background": Color.none })
          .draw(12 - offset, CARD_UI_TOP + 10 - offset)
          } else {
            sprites["cardback"].draw(12 - offset, CARD_UI_TOP + 10 - offset)
          }
        }
      }

      /*

      Canvas.print("Deck:", 0, y - 8, Color.white)
      for (card in deck) {
        Canvas.print(card.name, 0, y, Color.white)
        y = y + 8
      }
      */

      var hand = player["hand"]
      var mouse = Mouse.pos
      var y = Canvas.height - (hand.count + 2 + deck.count) * 8
      Canvas.print("Hand:", 0, y - 8, Color.white)
      var i = 1
      for (card in hand) {
        var text = "%(card.name)"
        if (i < InputActions.options.count) {
          text = "%(i): %(card.name)"
        }
        if (mouse.y >= y && mouse.y < y + 8 && mouse.x < (text.count) * 8) {
          Canvas.print(text, 0, y, Color.darkgreen)
        } else {
          Canvas.print(text, 0, y, Color.white)
        }
        y = y + 8
        i = i + 1
      }
    }

    for (ui in _ui) {
      var block = ui.draw()
      if (block) {
        break
      }
    }
  }

  world { _world }
  camera { _camera }
  camera=(v) { _camera = v }
}

// These need to be down here for safety
import "./effects" for CameraLerp, SuccessMessage, FailureMessage
