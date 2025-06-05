---@class Game
---@field SCALE_FACTOR number Scale factor for the game canvas
Game = {}

Game.RELEASE_MODE = false
Game.SCALE_FACTOR = 4 -- Scale factor for the game canvas
Game.BOTTLE_HEIGHT = 16 -- Number of cell rows in the bottle
Game.BOTTLE_WIDTH = 8 -- Number of cell columns in the bottle

---@enum CellColor
CellColor = {
   EMPTY = 0,
   YELLOW = 1,
   RED = 2,
   BLUE = 3,
}

---@enum PillConnection
PillConnection = {
   NONE = 0,
   LEFT = 1,
   RIGHT = 2,
   TOP = 3,
   BOTTOM = 4,
}
