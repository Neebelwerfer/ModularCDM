---@class DataContext
---@field spells table<number, SpellContext>
---@field auras table<number, AuraContext>
---@field items table<number, ItemContext>
---@field resources table<string, ResourceContext>

---@class DirtyContext
---@field spells table<number, boolean>
---@field auras table<number, boolean>
---@field items table<number, boolean>
---@field resources table<string, boolean>

---@class SpellContext
---@field id number
---@field name string
---@field icon string
---@field cooldown? { start: number, duration: number, remaining: number }
---@field charges? { current: number, max: number, cooldown: number }
---@field inRange boolean
---@field usable boolean
---@field noMana boolean

---@class AuraContext
---@field id number
---@field name string
---@field icon string
---@field isActive boolean
---@field stacks number
---@field duration { start: number, duration: number, remaining: number }
---@field source string -- "player", "target", etc.

---@class ItemContext
---@field id number
---@field name string
---@field icon string
---@field count number
---@field cooldown? { start: number, duration: number, remaining: number }

---@class ResourceContext
---@field current number
---@field max number
---@field percent number
---@field type string -- "MANA", "ENERGY", etc.