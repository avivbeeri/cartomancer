import "math" for Vec

import "./core/world" for World, Zone
import "./core/map" for TileMap, Tile
import "./core/director" for
  RealTimeStrategy,
  TurnBasedStrategy,
  EnergyStrategy
import "./logic" for GameEndCheck, RemoveDefeated
import "./deck" for Card
import "./core/config" for Config
import "./rng" for RNG

// TODO: This feels awful, handle this data better.
Config["cards"].each {|data|
  Card.put(Card.new(data))
}

class BSPGenerator {
  static generate() {
    return BSPGenerator.init().generate()
  }

  construct init() {}
  generate() {

    // 1. Generate map
    // 2. Populate with enemies
    // 3. Select starting deck (based on steps 1 and 2)

    var world = World.new(EnergyStrategy.new())
    var zone = world.pushZone(Zone.new(TileMap.init()))
    zone.map.default = { "solid": false, "floor": "void" }

    // Order is important!!
    zone.postUpdate.add(RemoveDefeated)
    // zone.postUpdate.add(GameEndCheck)
    // -------------------


    // Level dimensions in tiles

    // var mapWidth = 40
    // var mapHeight = 27
    var mapWidth = 30
    var mapHeight = 30
    var minSize = 4


    // How are we dividing the space?
    // "h" - rooms are left-right
    // "v" - rooms are up-down
    var rooms = [ Vec.new(0, 0, mapWidth, mapHeight) ]
    var splitPos
    var doors = []
    for (i in 0...3) {
      var newRooms = []
      while (!rooms.isEmpty) {
        var room = rooms.removeAt(0)
        var width = room.z
        var height = room.w
        var split = RNG.float() < 0.5 ? "v" : "h"
        if (width > height && width / height >= 1.25) {
            split = "h"
        } else if (height > width && height / width >= 1.25) {
            split = "v"
        }
        if ((split == "h" ? width : height) <= minSize) {
          newRooms.add(room)
          continue
        }
        if (split == "h") {
          splitPos = RNG.int(minSize, (width * 0.65).floor)
          newRooms.add(Vec.new(room.x, room.y, splitPos, height))
          newRooms.add(Vec.new(room.x + splitPos, room.y, width - splitPos, height))
          doors.add(Vec.new(room.x + splitPos, RNG.int(room.y + 1, height - 1)))
        } else {
          splitPos = RNG.int(minSize, (height * 0.65).floor)
          newRooms.add(Vec.new(room.x, room.y, width, splitPos))
          newRooms.add(Vec.new(room.x, room.y + splitPos, width, height - splitPos))
          doors.add(Vec.new(RNG.int(room.x + 1, width - 1), room.y + splitPos))
        }
      }
      rooms = newRooms
      System.print(doors)
    }
    for (room in rooms) {
      var wx = room.x
      var wy = room.y
      var width = wx + room.z
      var height = wy + room.w
      for (y in wy..height) {
        for (x in wx..width) {
          if (x == wx || x == width || y == wy || y == height) {
            zone.map[x, y] = Tile.new({ "floor": "solid", "solid": true })
          } else {
            zone.map[x, y] = Tile.new({ "floor": "void" })
          }
        }
      }
    }
    for (door in doors) {
      zone.map[door.x, door.y] = Tile.new({ "floor": "void" })
    }
    var pos = null
    var start = RNG.sample(rooms)

    var player = zone.addEntity("player", Player.new())
    player.pos = Vec.new(start.x + 1, start.y + 1)

    return world
  }
}


class TestGenerator {
  static generate() {
    // World generation code

    var world = World.new(EnergyStrategy.new())
    var zone = world.pushZone(Zone.new(TileMap.init()))
    // Order is important!!
    zone.postUpdate.add(RemoveDefeated)
    zone.postUpdate.add(GameEndCheck)
    // -------------------

    zone.map.default = { "solid": false, "floor": "void" }
    var width = 18
    var height = 18
    for (y in 0..height) {
      for (x in 0..width) {
        if (x == 0 || x == width || y == 0 || y == width) {
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

    var card = zone.addEntity(Collectible.new("card:thunder"))
    card.pos = Vec.new(5, 5)

    return world
  }
}

import "./entity/all" for Player, Dummy, Collectible



