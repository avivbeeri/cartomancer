import "graphics" for Canvas, Color
import "random" for Random
import "input" for Keyboard, Mouse
import "math" for Vec

var RNG = Random.new(1)

var DEATH_LIMIT = 3
var BIRTH_LIMIT = 4

var WIDTH = 48
var HEIGHT = 48
var LIVE_CHANCE = 0.45

class WorldMap {
  construct new() {
    _data = List.filled(WIDTH * HEIGHT, false)
  }
  construct new(list) {
    _data = list.toList
  }

  [x, y] {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) {
      return false
    }
    return _data[y * WIDTH + x]

  }
  [x, y]=(v) { _data[y * WIDTH + x] = v }
  copy { WorldMap.new(_data) }
}

class Main {
  construct new() {}
  init() {
    Canvas.resize(WIDTH, HEIGHT)
    _map = WorldMap.new()
    for (y in 0...HEIGHT) {
      for (x in 0...WIDTH) {
        _map[x, y] = RNG.float() <= LIVE_CHANCE
      }
    }
  }

  checkNeighbours(map, x, y) {
    var count = 0
    for (j in -1..1) {
      for (i in -1..1) {
        var mx = x + i
        var my = y + j

        if (j == 0 && i == 0) {
          // don't count ourself.
          continue
        }

        if (mx < 0 || my < 0 || mx >= WIDTH || my >= HEIGHT) {
          count = count + 1
        } else if (map[mx, my]) {
          count = count + 1
        }
      }
    }
    return count
  }
  step() {
    var oldMap = _map.copy
    for (y in 0...HEIGHT) {
      for (x in 0...WIDTH) {
        var count = checkNeighbours(oldMap, x, y)
        if (_map[x, y]) {
          _map[x, y] = !(count < DEATH_LIMIT)
        } else {
          _map[x, y] = count > BIRTH_LIMIT
        }
      }
    }
  }

  fill(node) {
    var stack = Stack.new()
    stack.push(node)
    while (!stack.isEmpty) {
      var n = stack.pop()
      var x = n.x
      var y = n.y
      if (_map[x, y] == true) {
        _map[x, y] = 1
        stack.push(Vec.new(x + 1, y))
        stack.push(Vec.new(x - 1, y))
        stack.push(Vec.new(x, y + 1))
        stack.push(Vec.new(x, y - 1))
      }
    }
  }
  update() {
    if (Keyboard["space"].justPressed) {
      step()
    }
    if (Mouse["left"].justPressed) {
      fill(Mouse.pos)
    }

  }
  draw(alpha) {
    Canvas.cls()
    for (y in 0...HEIGHT) {
      for (x in 0...WIDTH) {
        var tile = _map[x, y]
        var color
        if (tile == false) {
          color = Color.black
        }
        if (tile == true) {
          color = Color.blue
        }

        if (tile == 1) {
          color = Color.red
        }
        Canvas.pset(x, y, color)
      }
    }
  }
}

class Stack {
  construct new() {
    _list = []
  }
  isEmpty { _list.isEmpty }

  push(v) {
    _list.add(v)
  }

  pop() {
    return _list.removeAt(-1)
  }
}


var Game = Main.new()
