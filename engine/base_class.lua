-- Simple class system for lua.
-- Pass base class for inheritance.
---@generic T
---@param base? T
---@return T
function class(base)
   local klass = {}

   -- Inheritance logic
   if base then
      for k, v in pairs(base) do
         klass[k] = v -- copy base class methods and properties
      end
   end

   -- __index will tell where to look when a key is not found in a table
   klass.__index = klass

   -- Constructor function will create a new instance of the class and run the init method if
   --  it exists
   klass.new = function(...)
      local instance = setmetatable({}, klass)
      if instance.init then
         instance:init(...)
      end
      return instance
   end

   return klass
end
