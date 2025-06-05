require('globals')
require('pill')
local Capsules = require('capsules')
local Utils = require('utils')
local Sprite = require('engine/sprite')

---This represents a capsule (two color pill) in the game.
---@class Capsule:Sprite
---@field orientation CapsuleOrientation The orientation of the capsule ('horizontal' or 'vertical')
local Capsule = class(Sprite)

---@param posX number The x-coordinate of the capsule's position.
---@param posY number The y-coordinate of the capsule's position.
---@param colors [CellColor, CellColor] A table containing two colors for the capsule.
function Capsule:init(posX, posY, colors)
   ---@type CapsuleOrientation
   self.orientation = 'horizontal'
   self.colors = colors

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

-- Get the sprite sheet based on the orientation
function Capsule:getSpriteSheet()
   if self.orientation == 'horizontal' then
      return Textures.capsules.horizontal.image
   else
      return Textures.capsules.vertical.image
   end
end

function Capsule:rotate()
   if self.orientation == 'horizontal' then
      self:setOrientation('vertical')
      self:setSpriteSheet(Textures.capsules.vertical.image)
   else
      self:setOrientation('horizontal')
      self:setSpriteSheet(Textures.capsules.horizontal.image)
   end

   self:setQuad(Capsules.getCapsuleQuad(self.orientation, self.colors))
end

---@param orientation CapsuleOrientation
function Capsule:setOrientation(orientation)
   self.orientation = orientation
end

return Capsule
