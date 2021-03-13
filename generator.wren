import "math" for Vec, M
import "core/elegant" for Elegant

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

import "./utils/graph" for WeightedGrid, BFS, AStar, DijkstraSearch

// TODO: This feels awful, handle this data better.
Config["cards"].each {|data|
  Card.put(Card.new(data))
}

var ROOM_COUNT = 2

class Room is Vec {
  construct new(x, y, w, h) {
    super(x, y, w, h)
    _neighbours = []
  }

  kind { _kind }
  kind=(v) { _kind = v }

  neighbours { _neighbours }
  toString { "Room [%(super.toString)]"}
}

class WorldGenerator {
  static generate() {
    // return TestGenerator.generate()
    return GrowthGenerator.init().generate()
  }

}

class GrowthGenerator {
  static generate() {
    return GrowthGenerator.init().generate()
  }

  construct init() {}
  generate() {

    // 1. Generate map
    // 2. Populate with enemies
    // 3. Select starting deck (based on steps 1 and 2)

    var world = World.new(EnergyStrategy.new())
    var zone = world.pushZone(Zone.new(TileMap.init()))
    zone.map.default = { "solid": true, "floor": "void" }

    // Order is important!!
    zone.postUpdate.add(RemoveDefeated)
    zone.postUpdate.add(GameEndCheck)
    // -------------------


    // Level dimensions in tiles
    // 1-2) General constraints
    var maxRoomSize = 12
    var minRoomSize = 5

    var doors = []

    // 3) A single room in the world (Library)
    var rooms = [ Room.new(0, 0, 7, 7) ]

    while(rooms.count < ROOM_COUNT) {

      // 4) Pass begins: Pick a base for this pass at random from existing rooms.
      var base = RNG.sample(rooms)
      // 5) Select a wall to grow from
      var dir = RNG.int(0, 4) // 0->4, left->up->right->down
      // 6)Make a new room
      var newRoom = Room.new(
        0, 0,
        RNG.int(minRoomSize, maxRoomSize),
        RNG.int(minRoomSize, maxRoomSize)
      )
      // 7) Place the room on the wall of the base
      if (dir == 0) {
        // left
        var offset = RNG.int(3 - newRoom.w, base.w - 3)
        newRoom.x = base.x - newRoom.z + 1
        newRoom.y = base.y + offset
        // 8-9) Check room for valid space compared to other rooms.
        var hit = false
        for (room in rooms) {
          if (room == base) {
            // Colliding with the base is intentional. ignore this hit.
            continue
          }
          if (overlap(newRoom, room)) {
            hit = true
            break
          }
        }
        if (hit) {
          continue
        }


        // 10) Place a door in the overlapping range
        var doorTop = M.max(newRoom.y, base.y)
        var doorBottom = M.min(newRoom.y + newRoom.w, base.y + base.w)
        var doorRange = RNG.int(doorTop + 1, doorBottom - 1)
        doors.add(Vec.new(base.x, doorRange))
      } else if (dir == 1) {
        // up
        var offset = RNG.int(3 - newRoom.z, base.z - 3)
        newRoom.x = base.x + offset
        newRoom.y = base.y - newRoom.w + 1
        // 8-9) Check room for valid space compared to other rooms.
        var hit = false
        for (room in rooms) {
          if (room == base) {
            // Colliding with the base is intentional. ignore this hit.
            continue
          }
          if (overlap(newRoom, room)) {
            hit = true
            break
          }
        }
        if (hit) {
          continue
        }

        // 10) Place a door in the overlapping range
        var doorLeft = M.max(newRoom.x, base.x)
        var doorRight = M.min(newRoom.x + newRoom.z, base.x + base.z)
        var doorRange = RNG.int(doorLeft + 1, doorRight - 1)
        doors.add(Vec.new(doorRange, base.y))
      } else if (dir == 2) {
        // right
        var offset = RNG.int(3 - newRoom.w, base.w - 3)
        newRoom.x = base.x + base.z - 1
        newRoom.y = base.y + offset
        // 8-9) Check room for valid space compared to other rooms.
        var hit = false
        for (room in rooms) {
          if (room == base) {
            // Colliding with the base is intentional. ignore this hit.
            continue
          }
          if (overlap(newRoom, room)) {
            hit = true
            break
          }
        }
        if (hit) {
          continue
        }

        // 10) Place a door in the overlapping range
        var doorTop = M.max(newRoom.y, base.y)
        var doorBottom = M.min(newRoom.y + newRoom.w, base.y + base.w)
        var doorRange = RNG.int(doorTop + 1, doorBottom - 1)
        doors.add(Vec.new(newRoom.x, doorRange))
      } else if (dir == 3){
        // up
        var offset = RNG.int(3 - newRoom.z, base.z - 3)
        newRoom.x = base.x + offset
        newRoom.y = base.y + base.w - 1
        // 8-9) Check room for valid space compared to other rooms.
        var hit = false
        for (room in rooms) {
          if (room == base) {
            // Colliding with the base is intentional. ignore this hit.
            continue
          }
          if (overlap(newRoom, room)) {
            hit = true
            break
          }
        }
        if (hit) {
          continue
        }

        // 10) Place a door in the overlapping range
        var doorLeft = M.max(newRoom.x, base.x)
        var doorRight = M.min(newRoom.x + newRoom.z, base.x + base.z)
        var doorRange = RNG.int(doorLeft + 1, doorRight - 1)
        doors.add(Vec.new(doorRange, newRoom.y))
      } else {
        // Safety assert
        Fiber.abort("Tried to grow from bad direction")
      }
      rooms.add(newRoom)
      base.neighbours.add(newRoom)
    }
    System.print(rooms)

    var start = rooms[0]
    var player = zone.addEntity("player", Player.new())
    player.pos = Vec.new(start.x + 1, start.y + 1)

    var energy = 0
    var enemyCount = 0
    for (room in rooms) {
      var wx = room.x
      var wy = room.y
      var width = wx + room.z
      var height = wy + room.w
      for (y in wy...height) {
        for (x in wx...width) {
          if (x == wx || x == width - 1 || y == wy || y == height - 1) {
            zone.map[x, y] = Tile.new({ "floor": "wall", "solid": true })
          } else {
            zone.map[x, y] = Tile.new({ "floor": "tile" })
          }
        }
      }


      for (i in 0...RNG.int(3)) {
        var dummy = zone.addEntity(Dummy.new(Config["entities"][0]))
        var spawn = Vec.new(RNG.int(wx + 1, width - 1), RNG.int(wy + 1, height - 1))
        while (spawn == player.pos || zone.getEntitiesAtTile(spawn).count >= 1) {
          spawn = Vec.new(RNG.int(wx + 1, width - 1), RNG.int(wy + 1, height - 1))
        }
        dummy.pos = spawn
        dummy.priority = energy % 12
        energy = energy + 1
        enemyCount = enemyCount + 1
      }
    }
    if (enemyCount == 0) {
      var wx = rooms[-1].x
      var wy = rooms[-1].y
      var width = wx + rooms[-1].x
      var height = wy + rooms[-1].y
      var dummy = zone.addEntity(Dummy.new(Config["entities"][0]))
      var spawn = Vec.new(RNG.int(wx + 1, width - 1), RNG.int(wy + 1, height - 1))
      while (spawn == player.pos || zone.getEntitiesAtTile(spawn).count >= 1) {
        spawn = Vec.new(RNG.int(wx + 1, width - 1), RNG.int(wy + 1, height - 1))
      }
    }
    for (door in doors) {
      zone.map[door.x, door.y] = Tile.new({ "floor": "tile" })
    }

    return world
  }

  overlap(r1, r2) {
    return r1.x < r2.x + r2.z &&
           r1.x + r1.z > r2.x &&
           r1.y < r2.y + r2.w &&
           r1.y + r1.w > r2.y
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
    var width = 7
    var height = 7
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
