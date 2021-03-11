class Log {
  construct new() {
    _log = []
  }

  print(text) {
    System.print(text.toString)
    _log.add(text.toString)
  }

  log { _log }
}
