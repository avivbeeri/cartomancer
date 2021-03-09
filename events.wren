import "./core/event" for Event

class GameEndEvent is Event {
  construct new(won) {
    super()
    _won = won
  }

  won { _won }
}

class MoveEvent is Event {
  construct new(target) {
    super()
    _target = target
  }

  target { _target }
}

class CollisionEvent is Event {

  construct new(source, target, position) {
    super()
    _target = target
    _source = source
    _pos = position
  }

  source { _source }
  target { _target }
  pos { _pos }
}
