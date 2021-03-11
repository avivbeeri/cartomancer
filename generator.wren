import "math" for Vec

import "./stats"
import "./core/world" for World, Zone
import "./core/map" for TileMap, Tile
import "./core/director" for
  RealTimeStrategy,
  TurnBasedStrategy,
  EnergyStrategy
import "./logic" for GameEndCheck
import "./deck" for Deck, Card
import "./core/config" for Config

class WorldGenerator {
  static generate() {
    // World generation code
    var world = World.new(EnergyStrategy.new())

    var zone = world.pushZone(Zone.new(TileMap.init()))
    zone.postUpdate.add(GameEndCheck)
    zone.map.default = { "solid": false, "floor": "void" }
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

    player["discard"] = []
    player["hand"] = [
      Card.new("Water"),
    ]
    player["deck"] = Deck.new(Config["cards"].map {|data| Card.new(data) }).shuffle()

    var dummy = zone.addEntity(Dummy.new())
    dummy.pos = Vec.new(2, 2)

    //dummy = zone.addEntity(Dummy.new())
    // dummy.pos = Vec.new(-1, 4)

    var card = zone.addEntity(Collectible.new("card"))
    card.pos = Vec.new(5, 5)
    return world
  }
}

import "./entity/all" for Player, Dummy, Collectible



