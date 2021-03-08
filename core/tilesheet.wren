import "graphics" for ImageData, Color
import "./core/display" for Display

class Tilesheet {
  construct new(path) {
    setup(path, 8, 1)
  }

  construct new(path, tileSize) {
    setup(path, tileSize, 1)
  }

  construct new(path, tileSize, scale) {
    setup(path, tileSize, scale)
  }

  setup(path, tileSize, scale) {
    _image = ImageData.loadFromFile(path)
    _tSize = tileSize
    if (_image.width % _tSize != 0) {
      Fiber.abort("Image is not an integer number of tiles wide")
    }
    _width = _image.width / _tSize
    _scale = scale
  }

  draw(s, x, y) { draw(s, x, y, Display.fg, Color.none) }
  draw(s, x, y, fg, bg) { getTile(s, fg, bg).draw(x, y) }

  getTile(s) { getTile(s, Display.fg, Color.none) }
  getTile(s, fg, bg) {
    var sy = (s / _width).floor * _tSize
    var sx = (s % _width).floor * _tSize

    return _image.transform({
      "srcX": sx, "srcY": sy,
      "srcW": _tSize, "srcH": _tSize,
      "mode": "MONO",
      "scaleX": _scale,
      "scaleY": _scale,
      "foreground": fg,
      "background": bg
    })
  }
}
