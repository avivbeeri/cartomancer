
import "./events" for GameEndEvent
class GameEndCheck {
  static update(ctx) {
    if (!ctx.getEntityByTag("player") && !__done) {
      // Game Over
      ctx.events.add(GameEndEvent.new(false))
      __done = true
    }
  }
}
