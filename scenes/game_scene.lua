local Playfield = require('playfield')
local Scene = require('scene')
local GameScene = class(Scene)

function GameScene:init() end
function GameScene:load()
   self.playfield = Playfield.new()
end
function GameScene:update(dt)
   self.playfield:update(dt)
end
function GameScene:draw()
   self.playfield:draw()
end

return GameScene
