import "graphics" for ImageData
import "./core/tilesheet" for Tilesheet
var scale = 1

var CharSheet = Tilesheet.new("res/img/charsheet.png", 16, scale)
var RoomSheet = Tilesheet.new("res/img/room.png", 16, scale)
var AttackSheet = Tilesheet.new("res/img/attack-swipe.png", 16, scale)
var BasicAttack = (0...6).map {|i| AttackSheet.getTile(i) }.toList
var LightningAttack = (6...12).map {|i| AttackSheet.getTile(i) }.toList

var PlayerStandTiles = [ CharSheet.getTile(0), CharSheet.getTile(1) ]
var PlayerWalkTiles = [ CharSheet.getTile(2), CharSheet.getTile(3) ]
var Card = RoomSheet.getTile(7)

var FloorTile = RoomSheet.getTile(21)
var WallTiles = (0...20).map {|i| RoomSheet.getTile(40 + i) }.toList

var SwordTiles = (8..9).map {|i| RoomSheet.getTile(i) }.toList
var CardBack = ImageData.loadFromFile("res/img/card-back-small.png")

var StandardSpriteSet = {
  "playerStand": PlayerStandTiles,
  "playerWalk": PlayerWalkTiles,
  "floor": [ FloorTile ],
  "wall": WallTiles,
  "card": [ Card ],
  "sword": SwordTiles,
  "cardback": CardBack,
  "basicAttack": BasicAttack,
  "lightningAttack": LightningAttack
}

