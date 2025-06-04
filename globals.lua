---@class Game
---@field SCALE_FACTOR number Scale factor for the game canvas
Game = {}

Game.RELEASE_MODE = false
Game.SCALE_FACTOR = 4 -- Scale factor for the game canvas
Game.MATRIX_ROWS = 16
Game.MATRIX_COLUMNS = 8

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

-- All possible capsule color combination (based on the spritesheet layout)
Game.CAPSULES = {
   { CellColor.YELLOW, CellColor.RED },
   { CellColor.BLUE, CellColor.YELLOW },
   { CellColor.RED, CellColor.YELLOW },
   { CellColor.YELLOW, CellColor.YELLOW },
   { CellColor.RED, CellColor.BLUE },
   { CellColor.YELLOW, CellColor.BLUE },
   { CellColor.BLUE, CellColor.BLUE },
   { CellColor.BLUE, CellColor.RED },
   { CellColor.RED, CellColor.RED },
}
