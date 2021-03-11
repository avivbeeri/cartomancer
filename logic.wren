class GameEndCheck {
  static update(ctx) {
    if (ctx.parent.gameover) {
      return
    }
    if (!ctx.getEntityByTag("player")) {
      // Game Over
      ctx.events.add(GameEndEvent.new(false))
      ctx.parent.gameover = true
    } else if (!ctx.entities.any {|entity| entity is Collectible }) {
      ctx.events.add(GameEndEvent.new(true))
      ctx.parent.gameover = true
    }
  }
}

class RemoveDefeated {
  static update(ctx) {
    ctx.entities
    .where {|entity| entity.has("stats") && entity["stats"].get("hp") <= 0 }
    .each {|entity| ctx.removeEntity(entity) }
  }

}

import "./events" for GameEndEvent
import "./entity/collectible" for Collectible
