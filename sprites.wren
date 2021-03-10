import "graphics" for ImageData
import "./core/tilesheet" for Tilesheet

var Sheet = Tilesheet.new("res/img/camp-tiles.png", 8, 4)
var CharSheet = Tilesheet.new("res/img/charsheet.png", 16, 2)
var RoomSheet = Tilesheet.new("res/img/room.png", 16, 2)

var FireTiles = [ Sheet.getTile(10), Sheet.getTile(11) ]
var PlayerStandTiles = [ CharSheet.getTile(0), CharSheet.getTile(1) ]
var PlayerWalkTiles = [ CharSheet.getTile(2), CharSheet.getTile(3) ]
var GrassTile = Sheet.getTile(4)
var Card = RoomSheet.getTile(7)

var FloorTile = RoomSheet.getTile(21)
var WallTiles = (0...20).map {|i| RoomSheet.getTile(40 + i) }.toList

var SwordTiles = (8..9).map {|i| RoomSheet.getTile(i) }.toList
var CardBack = ImageData.loadFromFile("res/img/card-back-small.png")

var StandardSpriteSet = {
  "fire": FireTiles,
  "playerStand": PlayerStandTiles,
  "playerWalk": PlayerWalkTiles,
  "grass": [ GrassTile ],
  "floor": [ FloorTile ],
  "wall": WallTiles,
  "card": [ Card ],
  "sword": SwordTiles,
  "cardback": CardBack
}

