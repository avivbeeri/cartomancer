import "core/inputGroup" for InputGroup

import "input" for Keyboard, Mouse

var UP_KEY = InputGroup.new([
  Keyboard["up"], Keyboard["w"]
])
var DOWN_KEY = InputGroup.new([
  Keyboard["down"], Keyboard["s"]
])
var LEFT_KEY = InputGroup.new([
  Keyboard["left"], Keyboard["a"]
])
var RIGHT_KEY = InputGroup.new([
  Keyboard["right"], Keyboard["d"]
])

var CANCEL_KEY = InputGroup.new([
  Keyboard["backspace"], Keyboard["escape"]
])

var CONFIRM_KEY = InputGroup.new([
  Keyboard["z"], Keyboard["x"], Keyboard["e"], Keyboard["return"], Keyboard["space"]
])

var INTERACT_KEY = InputGroup.new([
  Keyboard["e"], Keyboard["space"]
])

var INVENTORY_KEY = InputGroup.new([
  Keyboard["i"]
])
var REST_KEY = InputGroup.new([
  Keyboard["r"]
])

var OPTION_KEYS = (0..9).map {|i| Keyboard[i.toString]}.toList
var DIR_KEYS = [ UP_KEY, DOWN_KEY, LEFT_KEY, RIGHT_KEY ]
// Set frequency for smoother tile movement
DIR_KEYS.each {|key| key.frequency = 1 }

class InputActions {
  // Grouped keys
  static directions { DIR_KEYS }
  static options { OPTION_KEYS }

  // Singular actions
  static up { UP_KEY }
  static down { DOWN_KEY }
  static left { LEFT_KEY }
  static right { RIGHT_KEY }
  static rest { REST_KEY }
  static inventory { INVENTORY_KEY }
  static interact { INTERACT_KEY }
  static confirm { CONFIRM_KEY }
  static cancel { CANCEL_KEY }
}
