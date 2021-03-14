import "./core/event" for Event

class GameEndEvent is Event {
  construct new(won) {
    super()
    _won = won
  }

  won { _won }

  // Force later
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

  construct new(source, target, attack) {
    super()
    _target = target
    _source = source
    _attack = attack
    _success = true
  }
  construct new(source, target, attack, success) {
    super()
    _target = target
    _source = source
    _attack = attack
    _success = success || true
  }

  source { _source }
  target { _target }
  attack { _attack }
  success { _success }

  fail() {
    _success = false
  }
}

class LogEvent is Event {
  construct new(text) {
    super()
    _text = text
  }
  text { _text }
}

class CommuneEvent is Event {
  construct new(source, success) {
    super()
    _source = source
    _success = success
  }
  source { _source }
  success { _success }
}

class PickupEvent is Event {
  construct new(source, item) {
    super()
    _source = source
    _item = item
  }
  source { _source }
  item { _item }
}
