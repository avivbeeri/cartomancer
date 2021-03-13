import "graphics" for ImageData, Canvas, Color, Font
import "input" for Keyboard, Mouse
import "math" for Vec, M

import "./palette" for EDG32, EDG32A

import "./core/display" for Display
import "./core/scene" for Scene
import "./core/event" for EntityRemovedEvent, EntityAddedEvent

import "./keys" for InputGroup, InputActions
import "./menu" for Menu, CardTargetSelector
import "./events" for CollisionEvent, MoveEvent, GameEndEvent, AttackEvent, LogEvent, CommuneEvent
import "./actions" for MoveAction, SleepAction, RestAction, PlayCardAction, CommuneAction
import "./entity/all" for Player, Dummy, Collectible

import "./sprites" for StandardSpriteSet as Sprites
import "./log" for Log

import "./widgets" for Button
import "./scene/autotile" for AutoTile

// Timer variables
var T = 0
var F = 0

// Is the view static?
var STATIC = false

var SCALE = 1
var TILE_SIZE = 16 * SCALE
var CARD_UI_TOP = 224
var X_OFFSET = 0

class WorldScene is Scene {
  construct new(args) {
    // Args are currently unused.
    _log = Log.new()

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
    _selected = null

    _reshuffleButton = Button.new("Commune", Vec.new(416, CARD_UI_TOP + 4), Vec.new(7 * 8 + 4, 12))
    _allowInput = true
  }


  world { _world }
  camera { _camera }
  camera=(v) { _camera = v }
  update() {
    _zone = _world.active
    T = T + (1/60)
    F = (T * 2).floor % 2

    var player = _zone.getEntityByTag("player")
    if (player) {
      _lastPosition = player.pos
      _allowInput = (_world.strategy.currentActor is Player) && _world.strategy.currentActor.priority >= 12
      _selected = _allowInput ? _selected : null
    }

    if (updateAllUi()) {
      return
    }

    _moving = false

    var pressed = false

    if (player && _allowInput) {
      // Overzone menu / interaction
      if (InputActions.interact.justPressed) {
        _ui.add(Menu.new(_zone, [
          "Cook", null,
          "Sleep", SleepAction.new(),
          "Cancel", "cancel"
        ]))
        return
      }
      if (_reshuffleButton.update().clicked) {
        player.action = CommuneAction.new()
      }

      // Play a card
      var hand = player["hand"]
      var mouse = Mouse.pos
      var handLeft = 5 + 59
      var maxHandWidth = 416 - (handLeft)
      var slots = getHandSlots(hand, handLeft, CARD_UI_TOP + 12, maxHandWidth)
      var index = 0
      var hover = null
      for (slot in slots) {
        var card = slot[0]
        var pos = slot[1]
        if (mouse.y >= pos.y && mouse.x >= pos.x && mouse.x < pos.z) {
          hover = slot
          var shift = InputActions.shift.down

          if (Mouse["left"].justPressed && !shift) {
            playCard(slots, index)
          } else if (Mouse["right"].justPressed || (Mouse["left"].justPressed && shift)) {
            displayCardDescription(card.id)
          }
        }

        if ((index+1) < InputActions.options.count && InputActions.options[index+1].justPressed) {
          if (InputActions.shift.down) {
            displayCardDescription(card.id)
          } else {
            hover = playCard(slots, index)
          }
        }
        index = index + 1
      }
      _selected = hover

      // Allow movement
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
      } else if (event is CommuneEvent) {
        if (event.success) {
          System.print("You communed with the cards and their magic is restored.")
        } else {
          System.print("You cannot commune right now.")
        }
      } else if (event is MoveEvent) {
        if (event.target is Player) {
          _moving = true
          _lastPosition = player.pos
          _ui.add(CameraLerp.new(this, event.target.pos * TILE_SIZE))
        }
      } else if (event is AttackEvent) {
        var animation = "%(event.kind)Attack"
        _diageticUi.add(Animation.new(this, event.target.pos * TILE_SIZE, Sprites[animation] || Sprites["basicAttack"], 5))
        if (event.source is Player) {
          _tried = true
          _moving = false
        }
        if (event.target is Player) {
          _diageticUi.add(Pause.new(this, 30))
        }
      } else if (event is LogEvent) {
        _log.print(event.text)
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


  draw() {
    _zone = _world.active
    var player = _zone.getEntityByTag("player")
    Canvas.cls(Display.bg)


    var cx = center.x
    var cy = center.y


    if (!STATIC) {
      Canvas.offset((cx-_camera.x -X_OFFSET).floor, (cy-_camera.y).floor)
    }

    var xRange = M.max((cx / TILE_SIZE), (Canvas.width - cx) / TILE_SIZE).ceil + 1
    var yRange = M.max((cy / TILE_SIZE), (Canvas.height - cy) / TILE_SIZE).ceil + 1
    for (dy in -yRange..yRange) {
      for (dx in -xRange..xRange) {
        var x = _lastPosition.x + dx
        var y = _lastPosition.y + dy
        var sx = x * TILE_SIZE + X_OFFSET
        var sy = y * TILE_SIZE
        var tile = _zone.map[x, y]

        var index = AutoTile.pick(_zone.map, x, y)
        if (index >= 0) {

          var list = Sprites["wall"]
          list[index].draw(sx, sy)

          if (Keyboard["left ctrl"].down) {
            // TODO: disable before release
            if (tile["solid"]) {
              Canvas.rectfill(sx, sy, TILE_SIZE, TILE_SIZE, EDG32A[25])
            } else {
              Canvas.rectfill(sx, sy, TILE_SIZE, TILE_SIZE, EDG32A[12])
            }
            Canvas.print(index, sx, sy, EDG32[24])
          }
        }
      }
    }

    for (entity in _zone.entities) {
      var sx = entity.pos.x * TILE_SIZE + X_OFFSET
      var sy = entity.pos.y * TILE_SIZE
      var screenPos = worldToScreen(entity.pos)
      if (Keyboard["left ctrl"].down) {
        var r = TILE_SIZE / 2
        Canvas.circlefill(sx + r, sy +r, r, EDG32A[10])
      }
      if (screenPos.x < 0 || screenPos.x >= Canvas.width || screenPos.y < 0 || screenPos.y >= Canvas.height) {
        continue
      }
      if (entity is Player) {
        if (!STATIC) {
          continue
        }
        // We draw this
        if (_moving) {
          var s = (T * 5).floor % 2
          Sprites["playerWalk"][s].draw(sx, sy)
        } else {
          Sprites["playerStand"][s].draw(sx, sy)
        }

      } else if (entity is Dummy) {
        Sprites["sword"][F].draw(sx, sy)
      } else if (entity is Collectible) {
        Sprites["card"][0].draw(sx, sy - F * 2)
      } else {
        Canvas.print(entity.type.name[0], sx, sy, Color.red)
      }
    }


    if (player && !STATIC) {
      // The player is diagetic, but we get the best draw results in
      // absolute space for the moment
      Canvas.offset()
      var tile = _zone.map[player.pos]
      // Draw player in screen center
      if (_moving) {
        Sprites["playerWalk"][F].draw(cx, cy)
      } else {
        Sprites["playerStand"][F].draw(cx, cy)
      }
      // Reset the camera
      Canvas.offset((cx-_camera.x -X_OFFSET).floor, (cy-_camera.y).floor)
    }

    for (ui in _diageticUi) {
      var block = ui.drawDiagetic()
      if (block) {
        break
      }
    }

    Canvas.offset()

    if (player) {
      // Draw the top bar (player stats, menu button, tabs?)
      Canvas.rectfill(0, 0, Canvas.width, 20, EDG32[28])
      var hp = player["stats"].get("hp")
      var hpMax = player["stats"].get("hpMax")
      var mana = player["stats"].get("mana")
      var manaMax = player["stats"].get("manaMax")
      Canvas.print("HP: %(hp)/%(hpMax)", 2, 2, EDG32[19], "m5x7")
      var hpArea = Font["m5x7"].getArea("HP: %(hp)/%(hpMax)")
      Canvas.print("Mana: %(mana)/%(manaMax)", 2 + hpArea.x + 8, 2, EDG32[19], "m5x7")
      Canvas.line(0, 20, Canvas.width, 20, EDG32[29], 2)

      // Draw the card shelf
      Canvas.rectfill(0, CARD_UI_TOP, Canvas.width, Canvas.height - CARD_UI_TOP, EDG32[28])
      Canvas.line(0, CARD_UI_TOP, Canvas.width, CARD_UI_TOP, EDG32[29], 2)

      var deck = player["deck"]
      var left = 5
      var top = CARD_UI_TOP + 4
      drawPile(deck, 5, top, false)
      drawPile(player["discard"], 416, top, true)

      var hand = player["hand"]
      var handLeft = 5 + 59
      var maxHandWidth = 416 - (handLeft)
      var slots = getHandSlots(hand, handLeft, top + 8, maxHandWidth)
      var mouse = Mouse.pos
      for (slot in slots) {
        var card = slot[0]
        var pos = slot[1]
        if (_selected && _selected[0] == card) {
        } else {
         card.draw(pos.x, pos.y)
        }
      }

      if (deck.isEmpty && hand.isEmpty) {
        _reshuffleButton.draw()
      }

      if (_selected) {
        var card = _selected[0]
        var pos =  _selected[1]
        card.draw(pos.x, pos.y - 32)
      }
      if (!_allowInput) {
        Canvas.rectfill(0, CARD_UI_TOP, Canvas.width, Canvas.height - CARD_UI_TOP, EDG32A[27])
      }
    }

    for (ui in _diageticUi) {
      var block = ui.draw()
      if (block) {
        break
      }
    }

    if (_diageticUi.isEmpty) {
      for (ui in _ui) {
        var block = ui.draw()
        if (block) {
          break
        }
      }
    }
  }

  drawPile(pile, left, top, shade) {
    var mouse = Mouse.pos
    var width = 59
    var height = 89
    var border = 3
    Canvas.rect(left, top, width, height, EDG32[27])
    if (!pile.isEmpty) {
      var total = M.min(4, (pile.count / 3).ceil)
      for (offset in 1..total) {
        if (offset < total) {
        Sprites["cardback"]
        .transform({ "mode": "MONO", "foreground": EDG32[3 + total - offset], "background": Color.none })
        .draw(left + 7 - offset, top + 6 - offset)
        } else {
          Sprites["cardback"].draw(left + 7 - offset, top + 6 - offset)
        }
      }
    }
    if (shade) {
      Canvas.rectfill(left+1, top+1, width-2, height-2, EDG32A[27])
    }
    if (mouse.x >= left && mouse.x < left + width && mouse.y >= top && mouse.y < top + height) {
      var font = Font["m5x7"]
      var area = font.getArea(pile.count.toString)

      var textLeft = left + ((width - area.x) / 2)
      var textTop = top + ((height - area.y) / 2)
      Canvas.rectfill(textLeft - border, textTop - border, area.x + border * 2, area.y + border * 2, EDG32[21])
      font.print(pile.count.toString, textLeft + 1, textTop - 2, EDG32[23])
    }
  }

  getHandSlots(hand, handLeft, top, maxHandWidth) {
      var cardWidth = 96
      var spacingCount = M.max(0, hand.count - 1)
      var spacing = 6
      var handWidth = (hand.count * cardWidth) + spacingCount * spacing
      var handStep
      var adjust
      if (handWidth < maxHandWidth) {
        handStep = (handWidth / hand.count).floor
        adjust = (maxHandWidth - handWidth) / 2
      } else {
        maxHandWidth = maxHandWidth - cardWidth
        handStep = ((maxHandWidth) / (hand.count)).ceil
        spacing = 0
        adjust = handStep / 2
      }

      return (0...hand.count).map {|i|
        var x = handLeft + adjust + handStep * i + spacing / 2
        return [ hand[i], Vec.new(x, top, i < hand.count - 1 ? x + handStep : x + cardWidth, 160) ]
      }
  }


  displayCardDescription(cardId) {
    _ui.add(CardDialog.new(this, cardId))
  }

  playCard(slots, index) {
    var player = _world.active.getEntityByTag("player")
    slots = slots.toList
    var card = slots[index][0]
    if (!card.requiresInput) {
      player.action = PlayCardAction.new(index)
    } else {
      // get inputs
      _diageticUi.add(CardTargetSelector.new(_zone, this, card, index))
      return slots[index]
    }
  }

  center {
    var cx = (Canvas.width - X_OFFSET - 20) / 2
    var cy = (Canvas.height - CARD_UI_TOP) / 2 + TILE_SIZE * 4
    return Vec.new(cx, cy)

  }

  screenToWorld(pos) {
    var tile =  (pos - (center - _camera)) / TILE_SIZE
    tile.x = tile.x.floor
    tile.y = tile.y.floor
    return tile
  }

  worldToScreen(pos) {
    return (pos * TILE_SIZE) + (center - _camera)
  }
}

// These need to be down here for safety
// from circular dependancies
import "./effects" for
  CameraLerp,
  SuccessMessage,
  FailureMessage,
  Animation,
  CardDialog,
  Pause
