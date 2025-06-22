require('globals')
require('pill')
local Capsules = require('capsules')
local Utils = require('utils')
local Sprite = require('engine/sprite')

---This represents a capsule (two color pill) in the game.
---@class Capsule:Sprite
---@field orientation CapsuleOrientation The orientation of the capsule ('horizontal' or 'vertical')
---@field colors [CellColor, CellColor] The colors of the capsule.
---@field private row number The row index of the capsule in the playfield.
---@field private col number The column index of the capsule in the playfield.
---@field new fun(posX: number, posY: number, row: number, col: number, colors: [CellColor, CellColor]): Capsule
local Capsule = class(Sprite)

---@param posX number The x-coordinate of the capsule's position.
---@param posY number The y-coordinate of the capsule's position.
---@param row number The row index of the capsule in the playfield.
---@param col number The column index of the capsule in the playfield.
---@param colors [CellColor, CellColor] A table containing two colors for the capsule.
function Capsule:init(posX, posY, row, col, colors)
   ---@type CapsuleOrientation
   self.orientation = 'horizontal'
   self.colors = colors
   self.row = row
   self.col = col

   -- Find the index of the capsule quad based on the colors
   local spriteQuad = Capsules.getCapsuleQuad(self.orientation, colors)
   local _, _, w, h = spriteQuad:getViewport()

   Sprite.init(self, {
      x = posX,
      y = posY,
      width = w,
      height = h,
      name = 'Capsule',
      spriteSheet = self:getSpriteSheet(),
      quad = spriteQuad,
   })
end

---@return number row
---@return number col
function Capsule:getRowCol()
   return self.row, self.col
end

---@return number row
function Capsule:getRow()
   return self.row
end

function Capsule:setRow(newRow)
   self.row = newRow
end

---@return number col
function Capsule:getCol()
   return self.col
end

function Capsule:setCol(newCol)
   self.col = newCol
end

---@return CapsuleOrientation orientation
function Capsule:getOrientation()
   return self.orientation
end

-- Get the sprite sheet based on the orientation
function Capsule:getSpriteSheet()
   if self.orientation == 'horizontal' then
      return Textures.capsules.horizontal.image
   else
      return Textures.capsules.vertical.image
   end
end

function Capsule:wallKick()
   self:setOrientation('horizontal')
   self:setSpriteSheet(Textures.capsules.horizontal.image)
   self.y = self.y + self.height + 1 -- Adjust position to keep the capsule centered
   -- self.x = self.x - self.width + 1
   self.col = self.col - 1
end

function Capsule:rotate()
   if self.orientation == 'horizontal' then
      self:setOrientation('vertical')
      self:setSpriteSheet(Textures.capsules.vertical.image)
      self.y = self.y - self.height - 1 -- Adjust position to keep the capsule centered
   else
      self:setOrientation('horizontal')
      self:setSpriteSheet(Textures.capsules.horizontal.image)
      self.y = self.y + self.height + 1 -- Adjust position to keep the capsule centered
   end

   self:setQuad(Capsules.getCapsuleQuad(self.orientation, self.colors))
end

---@param orientation CapsuleOrientation
function Capsule:setOrientation(orientation)
   self.orientation = orientation
end

return Capsule
