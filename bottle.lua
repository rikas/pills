require('engine/base_class')
require('globals')
local Utils = require('utils')
local GameObject = require('engine/game_object')

BOTTLE_HEIGHT = Game.BOTTLE_HEIGHT -- Number of cell rows in the bottle
BOTTLE_WIDTH = Game.BOTTLE_WIDTH -- Number of cell columns in the bottle

---@class BottleCell
---@field type CellType If the cell is empty, a pill or a virus.
---@field color CellColor The color of the cell.
---@field connection PillConnection The connection of the pill if it is a pill cell.

---@type BottleCell
BASE_BOTTLE_CELL = {
   type = CellType.EMPTY,
   color = CellColor.EMPTY,
   connection = PillConnection.NONE,
}

---@class Bottle:GameObject
---@field level number The game level
---@field matrix table A 2D matrix representing the bottle's cells.
---@field new fun(level:number, seed: Seed):Bottle
local Bottle = class(GameObject)

---@param level number The game level
---@param seed Seed The seed used to generate the bottle's contents.
function Bottle:init(level, seed)
   self.matrix = Utils.generate_matrix(BOTTLE_WIDTH, BOTTLE_HEIGHT, BASE_BOTTLE_CELL)
   self.level = level
   self.seed = seed

   -- Generated viruses to populate the bottle
   local viruses = seed:generateViruses(level)

   print('Bottle: Adding ' .. #viruses .. ' viruses to the bottle.')

   for _, virus in pairs(viruses) do
      self.matrix[virus.row][virus.col] = {
         type = CellType.VIRUS,
         color = virus.color,
         connection = PillConnection.NONE,
      }
   end
end

function Bottle:debugPrint()
   for row = 1, BOTTLE_HEIGHT do
      for col = 1, BOTTLE_WIDTH do
         io.write(self.matrix[row][col].color)
      end
      print('(' .. row .. ')')
   end
end

function Bottle:getCell(row, col)
   if row < 1 or row > BOTTLE_HEIGHT or col < 1 or col > BOTTLE_WIDTH then
      return nil
   end

   return self.matrix[row][col]
end

function Bottle:resetCell(row, col)
   self.matrix[row][col] = BASE_BOTTLE_CELL
end

return Bottle
