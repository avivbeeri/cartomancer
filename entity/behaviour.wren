import "./core/action" for Action
import "./utils/graph" for WeightedZone, BFS, AStar, DijkstraMap
import "math" for Vec

import "./combat" for Attack, AttackType
import "./actions" for MoveAction, AttackAction

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
    if (player) {
      var search = player["dijkstra"]
      var path = DijkstraMap.reconstruct(search[0], player.pos, self.pos)
      if (path == null) {
        return Action.none
      }
      return MoveAction.new(path[1] - self.pos, true)
    }
    return Action.none
  }
}
class RangedBehaviour is Behaviour {
  construct new(self) {
    super(self)
    _seek = SeekBehaviour.new(self)
  }

  evaluate() {
    var map = ctx.map
    var player = ctx.getEntityByTag("player")
    if (player) {
      if (player.pos.x == self.pos.x || player.pos.y == self.pos.y) {
        // Same x or y coordinate
        var range = (player.pos - self.pos)
        if (range.manhattan < 3) {
          // In range
          // check LOS
          var solid = false
          var unit = range.unit
          for (step in 0..range.manhattan) {
            var tile = self.pos + unit * step
            if (ctx.isSolidAt(tile)) {
              solid = true
              break
            }
          }
          if (!solid) {
            // attack is good
            return AttackAction.new(player.pos, Attack.new(3, AttackType.lightning, false))
          }
        }
      }
      return _seek.evaluate()
    }
    return Action.none
  }
}
