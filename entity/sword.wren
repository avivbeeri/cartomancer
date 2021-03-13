import "math" for Vec
import "./core/action" for Action
import "./core/entity" for Entity
import "./actions" for MoveAction
import "./stats" for StatGroup
import "./entity/creature" for Creature
import "./events" for LogEvent, PickupEvent


import "./utils/graph" for WeightedGrid, BFS, AStar, DijkstraSearch

class Sword is Creature {
  construct new(config) {
    super(config)
  }

  construct new() {
    super()
    this["types"].add("enemy")
    this["stats"].set("def", 1)
    this["stats"].set("speed", 1)
  }

  update() {
    var map = ctx.map
    var player = ctx.getEntityByTag("player")
    var graph = WeightedGrid.new(map)
    var search = DijkstraSearch.search(graph, pos, player.pos)
    var path = DijkstraSearch.reconstruct(search[0], pos, player.pos)
    System.print(path)
    if (path == null) {
      return Action.none
    }
    return MoveAction.new(path[1] - pos, true)
  }

  notify(ctx, event) {
    if (event is PickupEvent) {
      ctx.events.add(LogEvent.new("%(this) picked up [%(event.item)] forever."))
    }
    return event
  }
}

