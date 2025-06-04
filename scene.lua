require('engine/base_class')

---@class Scene
local Scene = class()

function Scene:load() end
function Scene:init() end
function Scene:update(dt) end
function Scene:draw() end
function Scene:keypressed(key) end

return Scene
