import "./core/action" for Action
import "./utils/graph" for WeightedZone, BFS, AStar, DijkstraSearch

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
    var graph = WeightedZone.new(ctx)
    var search = DijkstraSearch.search(graph, self.pos, player.pos)
    var path = DijkstraSearch.reconstruct(search[0], self.pos, player.pos)
    if (path == null) {
      return Action.none
    }
    return MoveAction.new(path[1] - self.pos, true)

  }

}
