--- Global unique ID generator. It generates unique IDs starting from 1 and increments by 1 for
--- each call.
---@class IdGenerator
local IDGenerator = {}

IDGenerator.current_id = 1

function IDGenerator.generate()
   local id = IDGenerator.current_id
   IDGenerator.current_id = IDGenerator.current_id + 1
   return id
end

return IDGenerator
