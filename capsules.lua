local Utils = require('utils')

---@class Capsules
local Capsules = {
   quads = {},

   -- All possible capsule color combination (based on the spritesheet layout)
   colors = {
      { CellColor.YELLOW, CellColor.RED },
      { CellColor.BLUE, CellColor.YELLOW },
      { CellColor.RED, CellColor.YELLOW },
      { CellColor.YELLOW, CellColor.YELLOW },
      { CellColor.RED, CellColor.BLUE },
      { CellColor.YELLOW, CellColor.BLUE },
      { CellColor.BLUE, CellColor.BLUE },
      { CellColor.BLUE, CellColor.RED },
      { CellColor.RED, CellColor.RED },
   },
}

-- Get the key for the capsule based on orientation and colors
function Capsules.getKey(orientation, colors)
   return orientation .. '_' .. colors[1] .. '_' .. colors[2]
end

--- Get the quad for a given orientation and colors
---@param orientation CapsuleOrientation
---@param colors [CellColor, CellColor]
---@return love.Quad quad
function Capsules.getCapsuleQuad(orientation, colors)
   local key = Capsules.getKey(orientation, colors)
   local quad = Capsules.quads[key]

   if not quad then
      error('Quad for ' .. key .. ' not found.')
   end

   return quad
end

-- Builds all the quads (sprites) for capsules in different combinations and orientations
function Capsules.load()
   local orientationTextures = {
      horizontal = Textures.capsules.horizontal,
      vertical = Textures.capsules.vertical,
   }

   -- Iterate orientationTextures and buils quads for each orientation
   for orientation, texture in pairs(orientationTextures) do
      -- Ensure the texture is loaded
      if not texture.image then
         error('Texture for ' .. orientation .. ' capsules is not loaded.')
      end

      for index, capsule in ipairs(Capsules.colors) do
         local key = Capsules.getKey(orientation, capsule)

         Capsules.quads[key] = love.graphics.newQuad(
            (index - 1) * texture.quadWidth + (index - 1),
            0,
            texture.quadWidth,
            texture.quadHeight,
            texture.image:getDimensions()
         )
      end
   end

   print(Utils.dump(Capsules.quads))
end

return Capsules
