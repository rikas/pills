local Utils = require('utils')
local GameObject = require('engine/game_object')
local Pill = require('pill')
local Capsule = require('capsule')

---@class Playfield:GameObject
---@field matrix MatrixCell[][] The matrix representing the playfield.
local Playfield = class(GameObject)

---@type MatrixCell
BASE_CELL = {
   color = CellColor.EMPTY,
   connection = PillConnection.NONE,
}

---@class MatrixCell
---@field color CellColor The color of the cell.
---@field connection PillConnection The connection type of the cell.

function Playfield:init()
   print('Playfield init')
   self.texture = Textures.playfield

   local screenW = love.graphics.getWidth() / Game.SCALE_FACTOR
   local screenH = love.graphics.getHeight() / Game.SCALE_FACTOR

   local width = self.texture.width
   local height = self.texture.height

   local posX = screenW / 2 - width / 2
   local posY = screenH / 2 - height / 2

   GameObject.init(self, {
      x = posX,
      y = posY,
      width = width, -- Width of the playfield in cells
      height = height, -- Height of the playfield in cells
      name = 'Playfield',
   })

   self.pillPool = {
      [CellColor.YELLOW] = Pill.new(0, 0, CellColor.YELLOW),
      [CellColor.RED] = Pill.new(0, 0, CellColor.RED),
      [CellColor.BLUE] = Pill.new(0, 0, CellColor.BLUE),
   }

   self.capsulePool = {}

   local colors = { CellColor.RED, CellColor.BLUE, CellColor.YELLOW }

   -- Generate all possible combinations
   for _, color1 in ipairs(colors) do
      for _, color2 in ipairs(colors) do
         local key = color1 .. '_' .. color2
         self.capsulePool[key] = Capsule.new(0, 0, { color1, color2 })
      end
   end

   self.matrix = Utils.generate_matrix(Game.BOTTLE_HEIGHT, Game.BOTTLE_WIDTH, BASE_CELL)

   self.matrix[1][1] = {
      color = CellColor.YELLOW,
      connection = PillConnection.NONE,
   }
   self.matrix[16][8] = {
      color = CellColor.RED,
      connection = PillConnection.NONE,
   }
   self.matrix[16][1] = {
      color = CellColor.BLUE,
      connection = PillConnection.RIGHT,
   }
   self.matrix[16][2] = {
      color = CellColor.RED,
      connection = PillConnection.LEFT,
   }
   self.fallTimer = 0
   self.fallSpeed = 0.1 -- Speed at which pills fall (shorter is faster)
   self.fallAnimationTime = 0.1 -- Time it takes for a pill to fall one cell
   self.fallingPills = {}
   print('Playfield loaded')
end

---@return string capsuleKey
function Playfield:getCapsuleKey(color1, color2)
   return color1 .. '_' .. color2
end

---@return boolean
function Playfield:shouldPillFall(row, col)
   local cell = self.matrix[row] and self.matrix[row][col]

   -- The current position has no pill
   if not cell then
      return false
   end

   -- Single pill, simple check - the cell below should be empty
   if cell.connection == PillConnection.NONE then
      if row < Game.BOTTLE_HEIGHT then
         local cellBellow = self.matrix[row + 1] and self.matrix[row + 1][col]
         return cellBellow.color == CellColor.EMPTY
      end
   end

   -- For connected pills both parts must be able to fall
   if cell.connection == PillConnection.LEFT or cell.connection == PillConnection.RIGHT then
      -- Horizontal connection - check both psitions below
      local partnerRow, partnerCol = self:getConnectedCell(row, col)
      local partner = self.matrix[partnerRow][partnerCol]

      if not partner then
         return false
      end

      local canFallThis = row < Game.BOTTLE_HEIGHT and self:isEmpty(row + 1, col)
      local canFallPartner = partnerRow < Game.BOTTLE_HEIGHT
         and self:isEmpty(partnerRow + 1, partnerCol)

      return canFallThis and canFallPartner
   elseif cell.connection == PillConnection.TOP then
      local bottomRow, bottomCol = self:getConnectedCell(row, col)
      return bottomRow < Game.BOTTLE_HEIGHT and self:isEmpty(bottomRow + 1, bottomCol)
   end

   return false
end

function Playfield:isEmpty(row, col)
   local cell = self.matrix[row] and self.matrix[row][col]

   return cell and cell.color == CellColor.EMPTY
end

function Playfield:isConnected(row, col)
   local cell = self.matrix[row] and self.matrix[row][col]

   return cell.connection ~= PillConnection.NONE
end

-- Find pills that should fall and start their animation
function Playfield:startGravityCheck()
   for row = #self.matrix, 1, -1 do
      for col = #self.matrix[row], 1, -1 do
         local cell = self.matrix[row][col]

         if cell.color ~= CellColor.EMPTY and self:shouldPillFall(row, col) then
            -- Start falling animation
            table.insert(self.fallingPills, {
               fromRow = row,
               fromCol = col,
               toRow = row + 1,
               toCol = col,
               timer = 0,
               cell = cell,
               visualY = row,
               color = cell.color,
            })

            self.matrix[row][col] = BASE_CELL
         end
      end
   end
end

function Playfield:updateFallingAnimations(dt)
   for i = #self.fallingPills, 1, -1 do
      local pill = self.fallingPills[i]
      pill.timer = pill.timer + dt

      local progress = math.min(pill.timer / self.fallAnimationTime, 1)

      -- Hard fall
      pill.visualY = pill.fromRow + 1

      -- Smooth fall
      -- pill.visualY = pill.fromRow + progress * (pill.toRow - pill.fromRow)

      if progress >= 1 then
         self:completePillFall(pill)
         table.remove(self.fallingPills, i)
      end
   end
end

function Playfield:completePillFall(pill)
   -- Place the pill in its final position
   self.matrix[pill.toRow][pill.toCol] = pill.cell

   -- Handle connected pills
   -- if fallingPill.partnerPill then
   --    self.grid[fallingPill.partnerPill.toRow][fallingPill.partnerPill.toCol] =
   --       fallingPill.partnerPill.cell
   -- end
end

function Playfield:update(dt)
   self:updateFallingAnimations(dt)

   self.fallTimer = self.fallTimer + dt

   -- Check for new falls
   if self.fallTimer >= self.fallSpeed then
      self:startGravityCheck()
      self.fallTimer = 0
   end
end

---@return number row
---@return number col
function Playfield:getConnectedCell(row, col)
   local cell = self.matrix[row][col]

   if not cell then
      return 0, 0
   end

   if cell.connection == PillConnection.LEFT then
      return row, col - 1
   elseif cell.connection == PillConnection.RIGHT then
      return row, col + 1
   elseif cell.connection == PillConnection.TOP then
      return row - 1, col
   elseif cell.connection == PillConnection.BOTTOM then
      return row + 1, col
   end

   return 0, 0
end

function Playfield:breakConnection(row, col)
   local cell = self.matrix[row][col]

   if not cell or cell.connection == PillConnection.NONE then
      return
   end

   local partnerRow, partnerCol = self:getConnectedCell(row, col)
   local partner = self.matrix[partnerRow][partnerCol]

   if partner then
      partner.connection = PillConnection.NONE
      cell.connection = PillConnection.NONE
   end
end

---@return number posX X posistion on the screen for given row
---@return number posY Y position on the screen for given column
function Playfield:getRelativePosition(row, col)
   local fieldX, fieldY = self:getPosition()
   local posX = fieldX + ((col - 1) * 7) + col
   local posY = fieldY + ((row - 1) * 7) + row

   return posX, posY
end

function Playfield:drawSinglePill(row, col, color)
   local relativeX, relativeY = self:getRelativePosition(row, col)

   local pill = self.pillPool[color]
   pill:setPosition(relativeX, relativeY)
   pill:draw()
end

function Playfield:drawCapsule(row, col, cell)
   local relativeX, relativeY = self:getRelativePosition(row, col)

   local partnerRow, partnerCol = self:getConnectedCell(row, col)
   local partner = self.matrix[partnerRow][partnerCol]

   -- Find the right capsule sprite in the capsulePool collection
   local capsuleKey = self:getCapsuleKey(cell.color, partner.color)

   -- Determine orientation
   local capsule = self.capsulePool[capsuleKey]
   capsule:setPosition(relativeX, relativeY)
   capsule:setOrientation(cell.connection)
   capsule:draw()
end

function Playfield:draw()
   local fieldX, fieldY = self:getPosition()
   love.graphics.draw(self.texture.image, fieldX, fieldY)

   -- Keep track of which cells we've already drawn as part of capsules so we don't draw then again
   -- Also avoids drawing capsules in the wrong order (BLUE->RED instead of RED->BLUE)
   local drawnCells = {}

   -- Draw static pills in the grid
   for row = 1, #self.matrix do
      for col = 1, #self.matrix[row] do
         local cell = self.matrix[row][col]

         if not drawnCells[row .. ',' .. col] then
            if cell.color ~= CellColor.EMPTY then
               if cell.connection == PillConnection.NONE then
                  self:drawSinglePill(row, col, cell.color)
                  drawnCells[row .. ',' .. col] = true
               else
                  self:drawCapsule(row, col, cell)
                  -- Mark both cells as drawn
                  drawnCells[row .. ',' .. col] = true
                  local partnerRow, partnerCol = self:getConnectedCell(row, col)
                  drawnCells[partnerRow .. ',' .. partnerCol] = true
               end
            end
         end
      end
   end

   -- Draw falling animated pills
   for _, fallingPill in ipairs(self.fallingPills) do
      -- Draw main pill at animated position

      self:drawSinglePill(fallingPill.visualY, fallingPill.fromCol, fallingPill.color)

      -- Draw partner pill if it exists
      -- if fallingPill.partnerPill then
      --    self:drawPillAt(
      --       fallingPill.partnerPill.visualY,
      --       fallingPill.partnerPill.fromCol,
      --       fallingPill.partnerPill.cell.color,
      --       fallingPill.partnerPill.cell.connection
      --    )
      -- end
   end
end

return Playfield
