local Playfield = require('playfield')
local Scene = require('scene')
local Capsule = require('capsule')
local GameScene = class(Scene)

function GameScene:init() end
function GameScene:load()
   self.capsule = Capsule.new(100, 20, { CellColor.RED, CellColor.BLUE })
   self.playfield = Playfield.new()
end
function GameScene:update(dt)
   self.playfield:update(dt)
end
function GameScene:keypressed(key)
   if key == 'space' then
      self.capsule:rotate()
   end
end
function GameScene:draw()
   self.playfield:draw()
   self.capsule:draw()
end

return GameScene
