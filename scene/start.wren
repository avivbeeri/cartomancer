import "input" for Keyboard
import "graphics" for Canvas, Color, Font
import "math" for Vec
import "logic" for GameEndCheck

import "./core/world" for World, Zone
import "./core/map" for TileMap, Tile
import "./core/scene" for Scene
import "./core/display" for Display
import "./core/director" for
  RealTimeStrategy,
  TurnBasedStrategy,
  EnergyStrategy

import "./entity/all" for Player, Dummy, Collectible
import "./scene/game" for WorldScene

class WorldGenerator {
  static generate() {
    // World generation code
    var world = World.new(EnergyStrategy.new())

    var zone = world.pushZone(Zone.new(TileMap.init()))
    zone.postUpdate.add(GameEndCheck)
    zone.map.default = { "solid": false, "floor": "void" }
    // zone.map[0, 0] = Tile.new({ "floor": "grass" })
    // zone.map[0, 1] = Tile.new({ "floor": "solid", "solid": true })
    // zone.map[10, 0] = Tile.new({ "floor": "solid", "solid": true })
    for (y in 0...9) {
      for (x in 0...9) {
        if (x == 0 || x == 8 || y == 0 || y == 8) {
          zone.map[x, y] = Tile.new({ "floor": "wall", "solid": true })
        } else {
          zone.map[x, y] = Tile.new({ "floor": "tile" })
        }
      }
    }

    System.print(zone.map[-3, -3].data)

    var player = zone.addEntity("player", Player.new())
    player.pos = Vec.new(4, 4)

    var dummy = zone.addEntity(Dummy.new())
    dummy.pos = Vec.new(2, 2)

    //dummy = zone.addEntity(Dummy.new())
    // dummy.pos = Vec.new(-1, 4)

    var card = zone.addEntity(Collectible.new())
    card.pos = Vec.new(5, 5)
    return world
  }
}



class StartScene is Scene {
  construct new(args) {
    Font.load("quiver64", "res/font/Quiver.ttf", 64)
    var size = Font["quiver64"].getArea("Cartomancer")
    _x = (Canvas.width - size.x) / 2
    _y = 32
    Font.load("m5x7", "res/font/m5x7.ttf", 16)
    size = Font["m5x7"].getArea("Press SPACE to begin")
    _helpX = (Canvas.width - size.x) / 2
    _gold = Color.hex("#feae34")
    _purple = Color.hex("#68386c")
  }

  update() {
    if (Keyboard["space"].justPressed) {
      game.push(WorldScene, [ WorldGenerator.generate() ])
      return
    }
  }

  draw() {
    Canvas.cls(Display.bg)
    var s = 4
    for (y in -s..s) {
      for (x in -s..s) {
        Canvas.print("Cartomancer", _x + x, _y + y, _purple, "quiver64")
      }
    }
    Canvas.print("Cartomancer", _x, _y, _gold, "quiver64")
    Canvas.print("Press SPACE to begin", _helpX, Canvas.height - 32, Color.white, "m5x7")
  }
}
