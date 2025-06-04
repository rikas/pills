require('utils')

---@class Button
---@field x number The x posistion of the button
---@field y number The y posistion of the button
---@field width number The width of the button
---@field height number The height of the button
---@field text string The text displayed on the button
---@field on_click function The function to call when the button is clicked
---@field colors StateColors Whether the button is hovered
---@field text_size number The size of the button text
---@field private is_hovered boolean Whether the button is hovered
---@field private is_pressed boolean Whether the button is pressed
---@field new fun(x: number, y: number, width: number, height: number, text: string, on_click?: function, colors?: StateColors): Button
Button = class()

---@alias Color [number, number, number, number?]

---@class StateColorsWithoutText
---@field normal Color
---@field hover Color
---@field pressed Color

---@class StateColorsWithText
---@field text Color

---@alias StateColors StateColorsWithText | StateColorsWithoutText

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param on_click? function
---@param colors? StateColors
function Button:init(x, y, width, height, text, on_click, colors)
   self.text_size = 1
   self.x = x or 0
   self.y = y or 0
   self.width = width
   self.height = height
   self.text = text
   self.on_click = function()
      if on_click and type(on_click) == 'function' then
         on_click()
      end

      self:press()
   end

   -- Visual states
   self.is_hovered = false
   self.is_pressed = false

   -- Set the default colors or the ones passed as argument
   ---@type StateColors
   self.colors = {
      normal = Utils.color_from_rgb(0, 85, 85),
      hover = Utils.color_from_rgb(0, 170, 0),
      pressed = Utils.color_from_rgb(0, 170, 0),
      text = { 1, 1, 1, 0.9 },
   }

   for state, color in pairs(colors or {}) do
      self.colors[state] = color
   end

   -- Sounds
   self.hover_sfx = love.audio.newSource('assets/sfx/button_select.mp3', 'static')
   self.click_sfx = love.audio.newSource('assets/sfx/button_click.wav', 'static')

   -- Font https://managore.itch.io/m6x11
   -- Use font size 18, 36, 54, etc
   self.font = love.graphics.newFont('assets/fonts/m6x11plus.ttf', 18 * self.text_size)
   self.font:setFilter('nearest', 'nearest') -- Ensure text is crisp
end

---@param colors StateColorsWithoutText | StateColorsWithText
function Button:set_colors(colors)
   for state, color in pairs(colors) do
      if self.colors[state] then
         self.colors[state] = color
      end
   end
end

---@param state 'normal' | 'hover' | 'pressed' | 'text'
---@param color Color
function Button:set_color(state, color)
   if self.colors[state] then
      self.colors[state] = color
   end
end

function Button:getCurrentBgColor()
   if self.is_pressed then
      return self.colors.pressed
   elseif self.is_hovered then
      return self.colors.hover
   else
      return self.colors.normal
   end
end

---@param options? {play_sound?: boolean, sound_pitch?: number}
function Button:focus(options)
   options = options or {}
   -- Set default options if not provided
   setmetatable(options, { __index = { play_sound = true, sound_pitch = 1 } })

   self.is_hovered = true

   if options.play_sound then
      -- Adjust sound pitch if specified
      if options.sound_pitch ~= 1 then
         self.hover_sfx:setPitch(options.sound_pitch)
      end
      love.audio.play(self.hover_sfx)
   end
end

function Button:unfocus()
   self.is_hovered = false
   self.is_pressed = false
end

function Button:press()
   self.is_pressed = true
   love.audio.play(self.click_sfx)
end

function Button:draw()
   -- Choose color based on state
   local bg_color = self:getCurrentBgColor()
   local button_shadow_offset_y = 5

   -- The button offset when pressed (it covers the shadow)
   local offset_y = self.is_pressed and button_shadow_offset_y or 0

   -- Translate the button position if pressed
   local shadow_y = self.is_pressed and self.y or self.y + button_shadow_offset_y

   -- Draw button shadow
   love.graphics.setColor(0, 0, 0, 0.3)
   love.graphics.rectangle('fill', self.x, shadow_y, self.width, self.height, 10, 10)

   -- Draw button background
   love.graphics.setColor(bg_color)
   love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10, 10)

   -- Draw button text
   love.graphics.setColor(self.colors.text)
   love.graphics.setFont(self.font)

   local text_width = self.font:getWidth(self.text)
   local text_height = self.font:getHeight()

   local text_x = self.x + (self.width - text_width) / 2
   local text_y = self.y + (self.height - text_height) / 2

   -- Main text
   love.graphics.print(self.text, text_x, text_y)

   -- Reset color
   love.graphics.setColor(1, 1, 1)
end
