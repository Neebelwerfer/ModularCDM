---@class Color
---@field r number
---@field g number
---@field b number
---@field a number

-- Normalized Color
---@param r number -- 0-1
---@param g number -- 0-1
---@param b number -- 0-1
---@param a? number -- 0-1
---@return Color
function Color(r, g, b, a)
    return {
        r = r,
        g = g,
        b = b,
        a = a or 1
    }
end

---@enum DataTypes
DataTypes = {
    Spell = 1,
    Item = 2,
    Aura = 3,
    Resource = 4
}

---@enum GroupGrowDirection
GroupGrowDirection = {
    Up = 1,
    Down = 2,
    Left = 3,
    Right = 4
}