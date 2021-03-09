import "graphics" for ImageData, Color, Canvas, Font
import "dome" for Window

class Display {
  static setup() {
    Canvas.resize(240, 160)
    Window.title = "Untitled Game"
    __fg = Color.white
    __bg = Color.hex("#262b44")
    init_()
  }

  static setup(config) {
    Canvas.resize(config["width"], config["height"])
    Window.title = config["title"]
    __fg = Color.hex(config["foreground"])
    __bg = Color.hex(config["background"])
    init_()
  }

  static printCentered(text, y, color, font) { printCentered(text, y, color, font, null) }
  static printCentered(text, y, color, font, maxWidth) {
    if (maxWidth == null) {
      var area = Font[font].getArea(text)
      Canvas.print(text, (Canvas.width - area.x)/2, y, color, font)
      return area
    } else {
      var words = text.split(" ")
      var area = Font[font].getArea(text)
      var startWidth = area.x
      var newLine = []
       while (area.x > maxWidth && words.count > 1) {
        newLine.add(words.removeAt(-1))
        text = words.join(" ")
        area = Font[font].getArea(text)
      }

      Canvas.print(text, (Canvas.width - area.x)/2, y, color, font)

      if (startWidth - area.x > maxWidth) {
        printCentered(newLine.join(" "), y + area.y, color, font, maxWidth)
      } else {
        printCentered(newLine.join(" "), y + area.y, color, font, null)
      }
    }
  }


  static init_() {
    var scale = 2
    // Window.lockstep = true
    Window.resize(Canvas.width * scale, Canvas.height * scale)
  }

  static fg { __fg }
  static fg=(v) { __fg = v }
  static bg { __bg }
  static bg=(v) { __bg = v }
}

