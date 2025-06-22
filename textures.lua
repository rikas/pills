---@class Textures
---@field capsules CapsuleTextures
---@field pills SpriteTextureTable
Textures = {}

---@class CapsuleTextures
---@field vertical SpriteTextureTable
---@field horizontal SpriteTextureTable

---@class TextureTable
---@field image love.Image
---@field height number
---@field width number

---@class SpriteTextureTable:TextureTable
---@field spacing number
---@field quadWidth number
---@field quadHeight number

function Textures.load()
   local capsulesVText = love.graphics.newImage('assets/textures/pills_vertical.png')
   local capsulesHText = love.graphics.newImage('assets/textures/pills_horizontal.png')
   local pillsText = love.graphics.newImage('assets/textures/round_pill.png')
   local playfieldText = love.graphics.newImage('assets/textures/playfield.png')
   local virusText = love.graphics.newImage('assets/textures/virus.png')

   Textures.capsules = {
      vertical = {
         image = capsulesVText,
         height = capsulesVText:getHeight(),
         width = capsulesVText:getWidth(),
         spacing = 1,
         quadWidth = 7,
         quadHeight = 15,
      },
      horizontal = {
         image = capsulesHText,
         height = capsulesHText:getHeight(),
         width = capsulesHText:getWidth(),
         spacing = 1,
         quadWidth = 15,
         quadHeight = 7,
      },
   }

   ---@type SpriteTextureTable
   Textures.viruses = {
      image = virusText,
      height = virusText:getHeight(),
      width = virusText:getWidth(),
      spacing = 1,
      quadWidth = 7,
      quadHeight = 7,
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
