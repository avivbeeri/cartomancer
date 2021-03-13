import "json" for Json
import "math" for Vec
import "input" for Keyboard

var DIRS = {
  "w": Vec.new(-1, 0),
  "nw": Vec.new(-1, -1),
  "n": Vec.new(0, -1),
  "ne": Vec.new(1, -1),
  "e": Vec.new(1, 0),
  "se": Vec.new(1, 1),
  "s": Vec.new(0, 1),
  "sw": Vec.new(-1, 1)
}

var RuleFile = Json.load("tileRules.json")

class AutoTile {
  static pick(map, x, y) {
    if (Keyboard["f4"].justPressed) {
      RuleFile = Json.load("tileRules.json")
    }

    var pos = Vec.new(x, y)


    var tile = map[pos]
    var config = RuleFile[tile["floor"]]
    if (!config) {
      return -1
    }

    var neighbours = {}
    for (dir in DIRS.keys) {
      neighbours[dir] = map[pos + DIRS[dir]]["floor"]
    }


    var result = config["defaultTileIndex"]
    for (rule in config["rules"]) {
      var index = rule["tileIndex"]
      var ruleMap = rule["map"]
      var match = true
      for (dir in ruleMap.keys) {
        var expected = ruleMap[dir]
        var negate = expected.startsWith("!")
        expected = expected.replace("!", "")

        if ((!negate && neighbours[dir] != expected) ||
             (negate && neighbours[dir] == expected)) {
          match = false
          break
        }
      }
      if (match) {
        result = index
        break
      }
    }

    return result
  }

}
