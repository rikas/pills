_RELEASE_MODE = false -- Set to true when building for release

function love.conf(t)
   t.window.title = 'Hospital Madness'
   t.window.width = 800
   t.window.height = 600
   t.window.resizable = false
   t.window.vsync = 1
   t.window.highdpi = true -- Enable high-dpi mode for the window on a Retina display (boolean)

   t.console = not _RELEASE_MODE -- Enable console for debugging on Windows

   t.modules.audio = true
   t.modules.data = true
   t.modules.event = true
   t.modules.font = true
   t.modules.graphics = true
   t.modules.image = true
   t.modules.joystick = true
   t.modules.keyboard = true
   t.modules.math = true
   t.modules.mouse = false
   t.modules.physics = true
   t.modules.sound = true
   t.modules.system = true
   t.modules.thread = true
   t.modules.timer = true
   t.modules.touch = true
   t.modules.video = false
   t.modules.window = true
end
