import "./core/event" for Event

class GameEndEvent is Event {
  construct new(won) {
    super()
    _won = won
  }

  won { _won }
  priority { 3 }
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

class AttackEvent is Event {

  construct new(source, target) {
    super()
    _target = target
    _source = source
  }

  source { _source }
  target { _target }
}

class LogEvent is Event {
  construct new(text) {
    super()
    _text = text
  }
  text { _text }
}
