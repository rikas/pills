require('globals')
local Playfield = require('playfield')
local Scene = require('scene')
local Capsule = require('capsule')
local SimpleSeed = require('simple_seed')
local DrMarioSeed = require('dr_mario_seed')

---@class GameScene:Scene
local GameScene = class(Scene)

INITIAL_CAPSULE_POS = { 1, 1 } -- Initial position of the capsule in the playfield

---@class KeyRepeatKeys
---@field heldTime number The time the key has been held down.
---@field hasTriggered boolean Whether the key has triggered an action.
---@field lastTriggerTime number The last time the key triggered an action.

---@class KeyRepeat
---@field initialDelay number The initial delay before the first repeat.
---@field repeatDelay number The delay between repeats.
---@field [string] KeyRepeatKeys The keys being tracked for repeat actions.
local keyRepeat = {
   initialDelay = 0.3, -- Initial delay before the first repeats
   repeatDelay = 0.05, -- Delay between repeats
   keys = {},
}

function GameScene:init() end
function GameScene:load()
   self.level = 1
   -- local seed = SimpleSeed.new()
   local seed = DrMarioSeed.new('C3C2')
   self.playfield = Playfield.new(seed, self.level)

   -- State tracking
   keyRepeat.keys = {}

   self.currentCapsule = Capsule.new(
      0,
      0,
      INITIAL_CAPSULE_POS[1],
      INITIAL_CAPSULE_POS[2],
      { CellColor.RED, CellColor.BLUE }
   )
end

function GameScene:currentCapsulePositionInField()
   return self.playfield:getRelativePosition(
      self.currentCapsule:getRow() or INITIAL_CAPSULE_POS[1],
      self.currentCapsule:getCol() or INITIAL_CAPSULE_POS[2]
   )
end

function GameScene:update(dt)
   -- Update all tracked keys
   for key, data in pairs(keyRepeat.keys) do
      if love.keyboard.isDown(key) then
         data.heldTime = data.heldTime + dt

         -- Check if we should trigger an action
         local shouldTrigger = false

         if not data.hasTriggered then
            -- First trigger - immediate
            shouldTrigger = true
            data.hasTriggered = true
            data.lastTriggerTime = 0
         elseif data.heldTime >= keyRepeat.initialDelay then
            -- Check for repeat triggers
            local timeSinceLastTrigger = data.heldTime - data.lastTriggerTime
            local delay = (data.lastTriggerTime == 0) and keyRepeat.initialDelay
               or keyRepeat.repeatDelay

            if timeSinceLastTrigger >= delay then
               shouldTrigger = true
               data.lastTriggerTime = data.heldTime
            end
         end

         if shouldTrigger then
            self:handleKeyAction(key)
         end
      else
         -- Key released!
         keyRepeat.keys[key] = nil
      end
   end

   local relX, relY = self:currentCapsulePositionInField()
   self.currentCapsule:setPosition(relX, relY)

   self.playfield:update(dt)
end

function GameScene:keypressed(key)
   if key == 'x' then
      self.playfield:generate()
   end

   -- If the key is not already being tracked, start tracking it
   if not keyRepeat.keys[key] then
      keyRepeat.keys[key] = {
         heldTime = 0,
         hasTriggered = false,
         lastTriggerTime = 0,
      }
   end
end

function GameScene:handleKeyAction(key)
   local playfield = self.playfield
   local capsule = self.currentCapsule

   if key == 'a' then
      self.level = self.level + 1
      local seed = DrMarioSeed.new('C3C2')
      self.playfield = Playfield.new(seed, self.level)
   end

   if key == 'z' then
      self.level = self.level - 1
      local seed = DrMarioSeed.new('C3C2')
      self.playfield = Playfield.new(seed, self.level)
   end

   if key == 'space' or key == 'up' then
      if playfield:canRotate(capsule) then
         capsule:rotate()
      elseif playfield:canPerformWallKick(capsule) then
         capsule:wallKick()
      end
   end

   if self.currentCapsule:getOrientation() == 'horizontal' then
      maxCol = BOTTLE_WIDTH - 1
   end

   if key == 'left' and playfield:canMoveLeft(capsule) then
      capsule:setCol(capsule:getCol() - 1)
   elseif key == 'right' and playfield:canMoveRight(capsule) then
      capsule:setCol(capsule:getCol() + 1)
   elseif key == 'down' then
      self.currentCapsule:moveDown()
   end
end

function GameScene:draw()
   local font = love.graphics.newFont('assets/fonts/m6x11plus.ttf', 8)
   font:setFilter('nearest', 'nearest') -- Ensure text is crisp
   love.graphics.setColor(0.3, 0.2, 0.2)
   love.graphics.setFont(font)
   love.graphics.print('Seed: C3C2', 10, 5)
   love.graphics.print('Level: ' .. self.level, 10, 16)
   love.graphics.setColor(1, 1, 1)
   self.playfield:draw()
   -- self.currentCapsule:draw()
end

return GameScene
