require('globals')
require('pill')
local Utils = require('utils')
local Sprite = require('engine/sprite')

---This represents a capsule (two color pill) in the game.
---@class Capsule:Sprite
local Capsule = class(Sprite)

---@param posX number The x-coordinate of the capsule's position.
---@param posY number The y-coordinate of the capsule's position.
---@param colors [CellColor, CellColor] A table containing two colors for the capsule.
function Capsule:init(posX, posY, colors)
   local texture = Textures.capsules

   -- Find the index of the capsule based on the colors
   local spriteIndex = 0
   for i, capsule in ipairs(Game.CAPSULES) do
      if capsule[1] == colors[1] and capsule[2] == colors[2] then
         spriteIndex = i
         break
      end
   end

   Sprite.init(self, {
      x = posX,
      y = posY,
      width = texture.quadWidth,
      height = texture.quadHeight,
      name = 'Capsule',
      spriteSheet = Textures.capsules.image,
      quad = love.graphics.newQuad(
         (spriteIndex - 1) * texture.quadWidth + (spriteIndex - 1),
         0,
         texture.quadWidth,
         texture.quadHeight,
         texture.image
      ),
   })
end

---@param direction PillConnection
function Capsule:setOrientation(direction)
   -- Rotate the capsule based on the direction
   if direction == PillConnection.LEFT then
      self.rotation = -math.pi / 2 -- Rotate 90 degrees counter-clockwise
   elseif direction == PillConnection.RIGHT then
      self.rotation = math.pi / 2 -- Rotate 90 degrees clockwise
   elseif direction == PillConnection.TOP then
      self.rotation = math.pi -- Rotate 180 degrees
   else
      self.rotation = 0 -- No rotation for bottom
   end
end

return Capsule
