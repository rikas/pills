local Seed = require('seed')

-- Official Dr. Mario Seed Generation System for Love2D
-- Based on the official algorithm from granivore3.js
-- (https://tools.drmar.io/granivore/)
---@class DrMarioSeed:Seed
local DrMarioSeed = class(Seed)

local ITEM_COLORS = {
   YELLOW = 0,
   RED = 1,
   BLUE = 2,
}

-- Official virus color table from the game
local VIRUS_COLOR_TABLE = {
   ITEM_COLORS.YELLOW, -- 1
   ITEM_COLORS.RED, -- 2
   ITEM_COLORS.BLUE, -- 3
   ITEM_COLORS.BLUE, -- 4
   ITEM_COLORS.RED, -- 5
   ITEM_COLORS.YELLOW, -- 6
   ITEM_COLORS.YELLOW, -- 7
   ITEM_COLORS.RED, -- 8
   ITEM_COLORS.BLUE, -- 9
   ITEM_COLORS.BLUE, -- 10
   ITEM_COLORS.RED, -- 11
   ITEM_COLORS.YELLOW, -- 12
   ITEM_COLORS.YELLOW, -- 13
   ITEM_COLORS.RED, -- 14
   ITEM_COLORS.BLUE, -- 15
   ITEM_COLORS.RED, -- 16
}

local VIRUS_COLOR_BIT_MASKS = {
   [ITEM_COLORS.YELLOW] = 1,
   [ITEM_COLORS.RED] = 2,
   [ITEM_COLORS.BLUE] = 4,
}

---@param hexString string The seed in hexadecimal format (4 characters, e.g. '1A2B')
function DrMarioSeed:init(hexString)
   self.viruses = {}

   -- Generate a random seed between '0000' and 'FFFF'
   local randomHexString = string.format('%04X', math.random(0, 0XFFFF))
   local randomSeed = self:parseSeed(hexString or randomHexString)

   self.originalSeedString = hexString
   self.seed = randomSeed
   -- The original Dr. Mario alforithm generates 128 capsules first, based on the seed and then picks
   -- them in order until it loops back to the first one.
   self.capsules = {}
   self:generateCapsules()
end

-- Rotate bytes function (core of the RNG)
function DrMarioSeed:rotateSeedBytes()
   local carry0 = 0
   local carry1 = 0
   local seed = self.seed

   if not seed then
      return
   end

   -- XOR operation to determine carry
   if bit.bxor(bit.band(seed[1], 2), bit.band(seed[2], 2)) ~= 0 then
      carry0 = 1
      carry1 = 1
   end

   -- Rotate each byte
   for x = 1, 2 do
      carry0 = bit.band(seed[x], 1)
      seed[x] = bit.bor(bit.lshift(carry1, 7), bit.rshift(seed[x], 1))
      carry1 = carry0
   end
end

-- Get maximum row based on level (official formula)
function DrMarioSeed:getMaxRow(level)
   return 9 + math.max(0, math.floor((level - 13) / 2))
end

-- Generate capsules (pills) using official algorithm
function DrMarioSeed:generateCapsules()
   local capsulesRemaining = 128
   local lastCapsule = 0

   while capsulesRemaining > 0 do
      self:rotateSeedBytes()
      local capsule = ((self.seed[1] % 16) + lastCapsule) % 9
      lastCapsule = capsule
      self.capsules[capsulesRemaining] = capsule -- Store in reverse order like original
      capsulesRemaining = capsulesRemaining - 1
   end

   -- For some reason the first capsule should be at the end of the list
   local first = table.remove(self.capsules, 1)
   table.insert(self.capsules, first)
end

-- Helper function to convert 1-based array index to (x, y) coordinates
---@return number row
---@return number col
function DrMarioSeed:indexToCoordinates(index)
   local row = math.floor((index - 1) / Game.BOTTLE_WIDTH) + 1 -- 1-based y coordinate
   local col = ((index - 1) % Game.BOTTLE_WIDTH) + 1 -- 1-based x coordinate
   return row, col
end

-- Generates the viruses. This needs to be called after the generateCapsules()!
---@param level number The game level (1-based, where 1 is the first level)
function DrMarioSeed:generateViruses(level)
   -- Adjust level to be 0-based for calculations since that's how the game works in the original code
   level = level - 1 or 20
   local cappedLevel = math.min(20, level)
   local virusesRemaining = (cappedLevel + 1) * 4
   local maxRow = self:getMaxRow(cappedLevel)

   -- Initialize viruses array
   for i = 1, Game.BOTTLE_WIDTH * Game.BOTTLE_HEIGHT do
      self.viruses[i] = nil
   end

   ::outerloop::
   while virusesRemaining > 0 do
      -- Generate initial position using the same logic as JavaScript
      local row
      repeat
         self:rotateSeedBytes()
         row = self.seed[1] % Game.BOTTLE_HEIGHT
      until row <= maxRow

      local y = Game.BOTTLE_HEIGHT - 1 - row
      local x = self.seed[2] % Game.BOTTLE_WIDTH
      local position = y * Game.BOTTLE_WIDTH + x + 1 -- +1 for 1-based indexing
      local color = virusesRemaining % 4

      print('INITIAL COLOR: ' .. color .. ' position: ' .. position)

      if color == 3 then
         self:rotateSeedBytes()
         local colorIndex = self.seed[2] % 16
         color = VIRUS_COLOR_TABLE[colorIndex + 1]
      end

      ::adjustment::
      while true do
         -- Find empty position starting from calculated position
         while true do
            if self.viruses[position] == nil then
               break
            end
            position = position + 1
            if position > Game.BOTTLE_WIDTH * Game.BOTTLE_HEIGHT then
               -- Start over with new random position if we reach the end
               goto outerloop
            end
         end

         local surroundingViruses = 0

         -- Check virus above (position - 16)
         if position - 16 >= 1 and self.viruses[position - 16] ~= nil then
            surroundingViruses =
               bit.bor(surroundingViruses, VIRUS_COLOR_BIT_MASKS[self.viruses[position - 16]])
         end

         -- Check virus below (position + 16)
         if
            position + 16 <= Game.BOTTLE_WIDTH * Game.BOTTLE_HEIGHT
            and self.viruses[position + 16] ~= nil
         then
            surroundingViruses =
               bit.bor(surroundingViruses, VIRUS_COLOR_BIT_MASKS[self.viruses[position + 16]])
         end

         -- Check virus to the left (position - 2)
         if (position - 1) % Game.BOTTLE_WIDTH >= 2 and self.viruses[position - 2] ~= nil then
            surroundingViruses =
               bit.bor(surroundingViruses, VIRUS_COLOR_BIT_MASKS[self.viruses[position - 2]])
         end

         -- Check virus to the right (position + 2)
         if (position - 1) % Game.BOTTLE_WIDTH < 6 and self.viruses[position + 2] ~= nil then
            surroundingViruses =
               bit.bor(surroundingViruses, VIRUS_COLOR_BIT_MASKS[self.viruses[position + 2]])
         end

         -- Color selection loop
         while true do
            if surroundingViruses == 7 then
               position = position + 1
               goto adjustment
            end

            if bit.band(surroundingViruses, VIRUS_COLOR_BIT_MASKS[color]) == 0 then
               break
            end

            -- Cycle through colors
            if color == ITEM_COLORS.YELLOW then
               color = ITEM_COLORS.BLUE
            elseif color == ITEM_COLORS.RED then
               color = ITEM_COLORS.YELLOW
            elseif color == ITEM_COLORS.BLUE then
               color = ITEM_COLORS.RED
            end
         end

         print('Added position ' .. position .. ' with color ' .. color)
         self.viruses[position] = color
         virusesRemaining = virusesRemaining - 1
         break
      end
   end

   -- Returns the viruses translated to a format that the Bottle object can use
   return self:translatedViruses()
end

function DrMarioSeed:translatedViruses()
   local translated = {}

   local ColorTranslations = {
      [ITEM_COLORS.YELLOW] = CellColor.YELLOW,
      [ITEM_COLORS.RED] = CellColor.RED,
      [ITEM_COLORS.BLUE] = CellColor.BLUE,
   }

   for position, color in pairs(self.viruses) do
      local row, col = self:indexToCoordinates(position)

      table.insert(translated, {
         row = row,
         col = col,
         color = ColorTranslations[color],
      })
   end

   return translated
end

function DrMarioSeed:parseSeed(hexString)
   if #hexString ~= 4 then
      return nil
   end

   local byte1 = tonumber(hexString:sub(1, 2), 16)
   local byte2 = tonumber(hexString:sub(3, 4), 16)

   if not byte1 or not byte2 then
      return nil
   end

   return { byte1, byte2 }
end

function DrMarioSeed:getLeftHalfColor(capsule)
   return math.floor(capsule / 3)
end

function DrMarioSeed:getRightHalfColor(capsule)
   return capsule % 3
end

return DrMarioSeed
