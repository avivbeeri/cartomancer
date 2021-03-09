import "math" for Vec

import "./core/world" for World, Zone
import "./core/map" for TileMap, Tile
import "./core/director" for
  RealTimeStrategy,
  TurnBasedStrategy,
  EnergyStrategy
import "./logic" for GameEndCheck
import "./deck" for Deck, Card

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

    player["discard"] = []
    player["hand"] = [
      Card.new("Sword"),
      Card.new("Sword"),
      Card.new("Shield"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind"),
      Card.new("Wind")

    ]
    player["deck"] = Deck.new([
      Card.new("Sword"),
      Card.new("Shield"),
      Card.new("Wind")
    ]) // .shuffle()

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



