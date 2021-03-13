import "math" for Vector
import "./core/elegant" for Elegant
import "./utils/adt" for Queue, Heap
import "./utils/dir" for Directions

class Location {}

class Graph {
  neighbours(id) { [] }
}

class SimpleGraph is Graph {
  construct new() {
    _edges = {}
  }

  construct new(edges) {
    _edges = edges
  }

  neighbours(id) { _edges[id] }
}

class SquareGrid is Graph {
  construct new(map) {
    _map = map
  }

  neighbours(location) {
    if (location is Num) {
      location = Elegant.unpair(location)
    }
    var result = []
    for (dir in Directions.values) {
      if (dir.x != 0 && dir.y != 0) {
        continue
      }

      var target = (location + dir)
      if (!_map[target]["solid"]) {
        result.add(Elegant.pair(target))
      }
    }
    return result
  }
}

class WeightedGrid is SquareGrid {
  construct new(map) {
    super(map)
  }
  cost(a, b) {
    return 1
  }
}

// Expects tuple [ priority, item ]
class PriorityQueue is Heap {
  construct new() {
    var comparator = Fn.new {|a, b| a[0] - b[0] }
    super(comparator)
  }

  get() {
    return del()[1]
  }

  put(item, priority) {
    return insert([priority, item])
  }
}


class AStar {}
class BFS {
  static search(graph, start) { search(graph, start, null) }
  static search(graph, start, goal) {
    System.print("Reachable from %(start)")
    var frontier = Queue.new()
    frontier.enqueue(start)
    var cameFrom = {}
    if (start is Vector) {
      start = Elegant.pair(start)
    }
    cameFrom[start] = null

    while (!frontier.isEmpty) {
      var current = frontier.dequeue()
      if (goal && current == goal) {
        break
      }
      System.print("  Visiting %(current)")
      for (next in graph.neighbours(current)) {
        if (!cameFrom[next]) {
          frontier.enqueue(next)
          cameFrom[next] = current
        }
      }
    }
    return cameFrom
  }
}

class DijkstraSearch {
  static search(graph, start, goal) {
    System.print("Reachable from %(start)")
    if (start is Vector) {
      start = Elegant.pair(start)
    }
    var frontier = PriorityQueue.new()
    frontier.put(start, 0)
    var cameFrom = {}
    var costSoFar = {}
    cameFrom[start] = null
    costSoFar[start] = 0

    while (!frontier.isEmpty) {
      var current = frontier.get()
      if (goal && current == goal) {
        break
      }
      for (next in graph.neighbours(current)) {
        System.print(current)
        var newCost = costSoFar[current] + graph.cost(current, next)
        if (!costSoFar[next] || newCost < costSoFar[next]) {
          costSoFar[next] = newCost
          frontier.put(next, newCost)
          cameFrom[next] = current
        }
      }
    }
    return [cameFrom, costSoFar]
  }

  static reconstruct(cameFrom, start, goal) {
    if (start is Vector) {
      start = Elegant.pair(start)
    }
    if (goal is Vector) {
      goal = Elegant.pair(goal)
    }
    var current = goal
    var path = []
    while (current != start) {
      path.insert(0, Elegant.unpair(current))
      System.print(cameFrom[current])
      current = cameFrom[current] // || start
      if (current == null) {
        // Path is unreachable
        return null
      }
    }
    path.insert(0, Elegant.unpair(start))
    return path
  }
}



var example = SimpleGraph.new({
  "A": [ "B" ],
  "B": [ "C" ],
  "C": [ "B", "D", "F" ],
  "D": [ "C", "E" ],
  "E": [ "F" ],
  "F": []
})
BFS.search(example, "A")
