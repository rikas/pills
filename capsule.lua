require('pill')
local Utils = require('utils')
local Sprite = require('engine/sprite')

---This represents a capsule (two color pill) in the game.
---@class Capsule:Sprite
local Capsule = class(Sprite)

---@class CapsuleParams
---@field colors [CellColor, CellColor] A table containing two colors for the capsule.

---@param params CapsuleParams
function Capsule:init(params)
   self.background = love.graphics.newImage('assets/textures/playfield.png')

   -- Sprite.init(self, {
   --    x = posX or 0,
   --    y = posY or 0,
   --    width = self.background:getWidth(), -- Width of the playfield in cells
   --    height = self.background:getHeight(), -- Height of the playfield in cells
   --    name = 'Capsule',
   --    rotation = 0, -- Default rotation
   -- })
   --
   -- local dim = self:getDimensions()
end

function Capsule:draw() end

return Capsule
