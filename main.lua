require('textures')

local Utils = require('utils')
local MainMenuScene = require('scenes/main_menu_scene')
local GameScene = require('scenes/game_scene')
local Pill = require('pill')

PlayField = {
   WIDTH = 8,
   HEIGHT = 16,
   matrix = {},
}

SCALE_FACTOR = 4 -- Scale factor for the game canvas
gameCanvas = nil

function love.load()
   print('Starting load')
   math.randomseed(os.time()) -- Seed the random number generator

   local windowWidth = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()

   love.graphics.setBackgroundColor(1, 1, 1)
   love.graphics.setDefaultFilter('nearest', 'nearest')
   gameCanvas = love.graphics.newCanvas(windowWidth, windowHeight)

   -- This needs to be called before using any textures
   Textures.load()

   game_scene = GameScene.new()
   game_scene:load()
   print('Finish load')
end

-- function loadPills()
--    pillHeight = 15
--    pillWidth = 7
--    sheetSpacing = 1 -- space in px between pills in the sprite sheet
--
--    verticalPillsQuads = {}
--
--    for y = 0, verticalPillsSheet:getHeight() - pillHeight, pillHeight + sheetSpacing do
--       for x = 0, verticalPillsSheet:getWidth() - pillWidth, pillWidth + sheetSpacing do
--          table.insert(
--             verticalPillsQuads,
--             love.graphics.newQuad(x, y, pillWidth, pillHeight, verticalPillsSheet:getDimensions())
--          )
--       end
--    end
--
--    return verticalPillsQuads
-- end

function love.update(dt)
   game_scene:update(dt)
   -- main_menu_scene:update(dt)

   -- for i = 1, #pills.vertical do
   --    pills.vertical[i]:update(dt)
   -- end
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end

   -- main_menu_scene:keypressed(key)
   -- game_scene:keypressed(key)
end

function love.draw()
   love.graphics.setCanvas(gameCanvas)
   love.graphics.clear()

   -- All game drawing will be in original size
   game_scene:draw()

   love.graphics.setCanvas()
   love.graphics.draw(gameCanvas, 0, 0, 0, SCALE_FACTOR, SCALE_FACTOR)
end
