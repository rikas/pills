---@class Textures
---@field capsules SpriteTextureTable
---@field pills SpriteTextureTable
Textures = {}

---@class TextureTable
---@field image love.Image
---@field height number
---@field width number

---@class SpriteTextureTable:TextureTable
---@field spacing number
---@field quadWidth number
---@field quadHeight number

function Textures.load()
   local capsulesText = love.graphics.newImage('assets/textures/vertical_pills.png')
   local pillsText = love.graphics.newImage('assets/textures/round_pill.png')
   local playfieldText = love.graphics.newImage('assets/textures/playfield.png')

   ---@type SpriteTextureTable
   Textures.capsules = {
      image = capsulesText,
      height = capsulesText:getHeight(),
      width = capsulesText:getWidth(),
      spacing = 1,
      quadWidth = 7,
      quadHeight = 15,
   }

   ---@type SpriteTextureTable
   Textures.pills = {
      image = pillsText,
      height = pillsText:getHeight(),
      width = pillsText:getWidth(),
      spacing = 1,
      quadWidth = 7,
      quadHeight = 7,
   }

   ---@type TextureTable
   Textures.playfield = {
      image = playfieldText,
      height = playfieldText:getHeight(),
      width = playfieldText:getWidth(),
   }
end
