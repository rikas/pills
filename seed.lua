---@class Seed
---@field generateViruses fun(self: Seed, level: number): table<number, VirusPosition>
---@field nextCapsule fun(self: Seed)
local Seed = class()

---@param level number Game level
---@return table<number, VirusPosition> viruses  An array of objects representing the viruses in the bottle.
function Seed:generateViruses(level) end
function Seed:nextCapsule() end

return Seed
