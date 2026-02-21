local _, ns = ...

---@class BindingValueDescriptor
---@field binding string
---@field field string

---@class BindingDescriptor
---@field type DataTypes -- What kind of game data (Spell, Item, Aura, Resource) 
---@field alias string -- User-friendly display name in editor
---@field key number | string Game ID (spellID: 12345, itemID: 67890, etc)
ns.Data.BindingDescriptor = {}
local BindingDescriptor = ns.Data.BindingDescriptor




function BindingDescriptor.CreateValueDescriptor(binding, field)
    return {
        binding = binding,
        field = field
    }
end

function BindingDescriptor.CreateBindingDescriptor(type, alias, key)
    return {
        type = type,
        alias = alias,
        key = key
    }
end