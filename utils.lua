local Utils = {}

-- For generating unique IDs
Utils.current_id = 1

function Utils.generate_id()
   local id = Utils.current_id
   Utils.current_id = Utils.current_id + 1

   return id
end

---@param r number
---@param g number
---@param b number
---@param a? number
---@return Color
function Utils.color_from_rgb(r, g, b, a)
   if type(r) ~= 'number' or type(g) ~= 'number' or type(b) ~= 'number' then
      error('RGB values must be numbers')
   end

   if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
      error('RGB values must be between 0 and 255')
   end

   a = a or 1 -- Default alpha to 1 if not provided

   if a < 0 or a > 1 then
      error('Alpha value must be between 0 and 1')
   end

   return { r / 255, g / 255, b / 255, a }
end

function Utils.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         if type(k) ~= 'number' then
            k = '"' .. k .. '"'
         end
         s = s .. '[' .. k .. '] = ' .. Utils.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

--- Initializes a matrix with n rows and m columns and fills it with the initial value.
---@param columns number How many columns (width)
---@param rows number How many rows (height)
---@param initial_value any The value to fill the matrix with
---@return table
function Utils.generate_matrix(columns, rows, initial_value)
   local matrix = {}
   for i = 1, rows do
      matrix[i] = {}
      for j = 1, columns do
         matrix[i][j] = initial_value -- Initialize with zero or any default value
      end
   end

   return matrix
end

return Utils
