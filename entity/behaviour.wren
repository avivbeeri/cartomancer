import "./core/action" for Action
import "./utils/graph" for WeightedZone, BFS, AStar, DijkstraMap
import "math" for Vec

import "./actions" for MoveAction

class Behaviour {
  construct new(self) {
    _self = self
  }
  self { _self }
  ctx { _self.ctx }

  notify(event) {}
  evaluate() {}
}

class SeekBehaviour is Behaviour {
  construct new(self) {
    super(self)
  }

  evaluate() {
    var map = ctx.map
    var player = ctx.getEntityByTag("player")
    var search = player["dijkstra"]
    var path = DijkstraMap.reconstruct(search[0], player.pos, self.pos)
    if (path == null) {
      return Action.none
    }
    return MoveAction.new(path[1] - self.pos, true)
  }
}
