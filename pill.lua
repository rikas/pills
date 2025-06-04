local Sprite = require('engine/sprite')

---@class Pill:Sprite
local Pill = class(Sprite)

---@param posX number
---@param posY number
---@param color CellColor
function Pill:init(posX, posY, color)
   local texture = Textures.pills

   Sprite.init(self, {
      x = posX,
      y = posY,
      width = texture.quadWidth, -- Width of the pill in pixels
      height = texture.quadHeight, -- Height of the pill in pixels
      name = 'Pill',
      spriteSheet = texture.image, -- The sprite sheet image for the pill
      quad = love.graphics.newQuad(
         (color - 1) * texture.quadWidth + (color - 1), -- Adjust the x position based on color
         0,
         texture.quadWidth,
         texture.quadHeight,
         texture.image
      ),
   })
end

return Pill
