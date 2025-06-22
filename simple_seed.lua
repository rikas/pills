local Seed = require('seed')

---@class Simpleseed:Seed
local SimpleSeed = class(Seed)

---@class VirusPosition
---@field row number The row of the virus in the bottle.
---@field col number The column of the virus in the bottle.
---@field color CellColor The color of the virus.

-- Returns an array of objects with row, col, color, type
---@param level number Game level
---@return table<number, VirusPosition> viruses  An array of objects representing the viruses in the bottle.
function SimpleSeed:generateViruses(level)
   local remainingViruses = level * 4
   local maxVirusRow = 10

   ---@type table<number, VirusPosition>
   local viruses = {}

   if level >= 19 then
      maxVirusRow = 13
   elseif level >= 17 then
      maxVirusRow = 12
   elseif level >= 15 then
      maxVirusRow = 11
   end

   -- While we have remainingViruses loop and take one
   for index = 1, remainingViruses, 1 do
      local virus = self:generateVirus(BOTTLE_HEIGHT - maxVirusRow, index)
      table.insert(viruses, virus)
   end

   return viruses
end

---@return VirusPosition
function SimpleSeed:generateVirus(maxRow, remainingViruses)
   local virusColors = { CellColor.BLUE, CellColor.RED, CellColor.YELLOW }
   local position = { col = love.math.random(1, BOTTLE_WIDTH), row = 1 }
   local colorIndex = (remainingViruses % 4) + 1

   repeat
      position.row = love.math.random(1, BOTTLE_HEIGHT)
   until position.row > maxRow

   -- Handle special case when index would be 4 to spice things up. We select a random color
   -- with forward indexes (1,2,3) or reverse (3,2,1).
   if colorIndex == 4 then
      if love.math.random() < 0.5 then
         colorIndex = love.math.random(1, 3)
      else
         local temp = love.math.random(1, 3)
         colorIndex = 4 - temp
      end
   end

   return {
      row = position.row,
      col = position.col,
      color = virusColors[colorIndex],
   }
end

-- Completely random pill generation
---@return [CellColor, CellColor] colors A table containing two colors for the capsule.
function SimpleSeed:nextCapsule()
   local capsuleColors = { CellColor.BLUE, CellColor.RED, CellColor.YELLOW }

   local color1 = capsuleColors[love.math.random(1, #capsuleColors)]
   local color2 = capsuleColors[love.math.random(1, #capsuleColors)]

   return { color1, color2 }
end

return SimpleSeed
