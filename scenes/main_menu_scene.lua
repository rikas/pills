require('../scene')
require('ui/button')

---@class MainMenuScene : Scene
MainMenuScene = class(Scene)

function MainMenuScene:init()
   self.buttons = {}
   self.title = 'Main Menu'
   self.background = love.graphics.newImage('assets/main_menu_background.png')
   self.background:setWrap('repeat', 'repeat')

   self.backgroundWidth = self.background:getWidth()
   self.backgroundHeight = self.background:getHeight()
   self.hovered_button_index = 1
   self.number_of_button_changes = 0

   self.get_hovered_button = function()
      return self.buttons[self.hovered_button_index]
   end

   self.button_pitch_table = {
      0.75,
      0.8,
      0.75,
      0.8,
      0.7,
      0.62,
      0.62,
      0.7,
      0.75,
      0.8,
      0.7,
      0.62,
      0.62,
   }

   self:create_buttons()
   self.colorShader = love.graphics.newShader([[
        uniform float time;
        uniform float strength;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 coords = texture_coords;
            // Create wave distortion
            coords.x += sin(coords.y * 10.0 + time * 2.0) * strength;
            return Texel(texture, coords) * color;
        }
    ]])
end

function MainMenuScene:create_buttons()
   local screen_width = love.graphics.getWidth()
   local screen_height = love.graphics.getHeight()

   -- Button dimmensions
   local button_width = 200
   local button_height = 50
   local button_spacing = 20

   -- Center buttons horizontally
   local start_x = (screen_width - button_width) / 2
   local start_y = screen_height / 2 - button_height

   -- Start button
   --@type Button
   local start_button = Button.new(
      start_x,
      start_y,
      button_width,
      button_height,
      'Start Game',
      function()
         print('Starting Game...')
      end
   )

   start_button:focus({ play_sound = false })

   -- Settings button
   local settings_button = Button.new(
      start_x,
      start_y + button_height + button_spacing,
      button_width,
      button_height,
      'Settings',
      function()
         print('Opening Settings...')
      end
   )

   local exit_button = Button.new(
      start_x,
      start_y + 2 * (button_height + button_spacing),
      button_width,
      button_height,
      'Exit',
      function()
         love.event.quit()
      end
   )

   Button:init(0, 0, 0, 0, 'Button Text', function() end)

   exit_button:set_colors({
      normal = Utils.color_from_rgb(170, 0, 0),
      hover = Utils.color_from_rgb(255, 0, 0),
      pressed = { 1, 0.6, 0.6 },
   })

   self.buttons = { start_button, settings_button, exit_button }
end

function MainMenuScene:keypressed(key)
   if key == 'up' then
      self:change_hovered_button(self.hovered_button_index - 1)
   end

   if key == 'down' then
      self:change_hovered_button(self.hovered_button_index + 1)
   end

   if key == 'return' then
      local hovered_button = self.get_hovered_button()
      hovered_button:on_click()
   end
end

function MainMenuScene:change_hovered_button(new_index)
   if new_index < 1 or new_index > #self.buttons then
      return
   end

   self.hovered_button_index = new_index

   -- Unset all buttons' hovered state
   for _, button in ipairs(self.buttons) do
      button:unfocus()
   end

   local hovered_button = self.get_hovered_button()
   local pitch_index = self.number_of_button_changes % #self.button_pitch_table + 1
   local pitch_adjust = self.button_pitch_table[pitch_index] or 0
   self.number_of_button_changes = self.number_of_button_changes + 1

   -- Trigger hover effect on the hovered button
   hovered_button:focus({
      play_sound = true,
      sound_pitch = pitch_adjust,
   })
end

function MainMenuScene:update(dt)
   self.colorShader:send('time', love.timer.getTime())
   self.colorShader:send('strength', 0.02)
end

function MainMenuScene:draw()
   love.graphics.setColor(1, 1, 1)
   love.graphics.setShader(self.colorShader)
   love.graphics.draw(
      self.background,
      0,
      0,
      0,
      love.graphics.getWidth() / self.backgroundWidth,
      love.graphics.getHeight() / self.backgroundHeight
   )
   love.graphics.setShader()

   -- Draw title
   love.graphics.setColor(1, 1, 1)
   local title_font = love.graphics.newFont(32)
   love.graphics.setFont(title_font)

   local screen_width = love.graphics.getWidth()
   local title_width = title_font:getWidth(self.title)
   local title_x = (screen_width - title_width) / 2

   love.graphics.print('HELLO WORLD', title_x, 100)

   -- Draw buttons
   for _, button in ipairs(self.buttons) do
      button:draw()
   end
end
