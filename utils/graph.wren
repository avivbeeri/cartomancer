import "./adt" for Queue

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
  construct new(width, height) {

  }

}

class BFS {
  static search(graph, start) {
    System.print("Reachable from %(start)")
    var frontier = Queue.new()
    frontier.enqueue(start)
    var reached = {}
    reached[start] = true

    while (!frontier.isEmpty) {
      var current = frontier.dequeue()
      System.print("  Visiting %(current)")
      for (next in graph.neighbours(current)) {
        if (!reached[next]) {
          frontier.enqueue(next)
          reached[next] = true
        }
      }
    }
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
