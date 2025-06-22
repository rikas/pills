local Sprite = require('engine/sprite')

---@class Virus:Sprite
local Virus = class(Sprite)

---@param posX number
---@param posY number
---@param color CellColor
function Virus:init(posX, posY, color)
   local texture = Textures.viruses

   -- The viruses have 2 frames of animation, so we need to adjust the quad width accordingly.
   -- Here's the arrangement: [B, B, R, R, Y, Y]
   Sprite.init(self, {
      x = posX,
      y = posY,
      width = texture.quadWidth, -- Width of the pill in pixels
      height = texture.quadHeight, -- Height of the pill in pixels
      name = 'Virus',
      spriteSheet = texture.image, -- The sprite sheet image for the pill
      quad = love.graphics.newQuad(
         (color * 2 - 1) * texture.quadWidth + (color * 2 - 1), -- Adjust the x position based on color
         0,
         texture.quadWidth,
         texture.quadHeight,
         texture.image
      ),
   })
end

return Virus
