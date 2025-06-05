local GameObject = require('engine/game_object')

---@class Sprite:GameObject
---@field init fun(self: Sprite, params: SpriteParams)
---@field private spriteSheet love.Image The sprite sheet image.
---@field private quad love.Quad The quad representing the sprite's area in the sprite sheet.
local Sprite = class(GameObject)

---@class SpriteParams:ObjectParams
---@field spriteSheet love.Image The sprite sheet image.
---@field quad love.Quad The quad representing the sprite's area in the sprite sheet.

--- Initialize a new Sprite object.
---@param params SpriteParams
function Sprite:init(params)
   GameObject.init(self, params)

   self.spriteSheet = params.spriteSheet
   self.quad = params.quad
end

function Sprite:setQuad(quad)
   self.quad = quad
end

function Sprite:setSpriteSheet(spriteSheet)
   self.spriteSheet = spriteSheet
end

-- Draw the sprite quad on the screen.
---@return nil
function Sprite:draw()
   if not self.visible then
      return
   end

   local posX, posY = self:getPosition()

   love.graphics.draw(self.spriteSheet, self.quad, posX, posY)
end

return Sprite
