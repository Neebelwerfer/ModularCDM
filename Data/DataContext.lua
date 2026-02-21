local _, ns = ...
local DataTypes = ns.Core.DataTypes
local Data = ns.Data

---@class DataContext
---@field spells table<number, SpellContext>
---@field auras table<number, AuraContext>
---@field items table<number, ItemContext>
---@field resources table<string, ResourceContext>


ns.Data.DataContext = {}
local DataContext = ns.Data.DataContext
local dirty = {
    spells = {},
    auras = {},
    items = {},
    resources = {}
}
local bindings = {}
local updateInterval = 0.5
local lastUpdate = 0
local managers = {
    [DataTypes.Spell] = Data.SpellContextManager,
    [DataTypes.Aura] = Data.AuraContextManager
}

function DataContext.Initialize()
    Data.AuraContextManager.Initialize()
end

---Register a binding from a node
---@param sourceGuid string
---@param binding BindingDescriptor
function DataContext.RegisterBinding(sourceGuid, binding)
    managers[binding.type].Register(sourceGuid, binding.key)
end


---Unregister a binding from a node
---@param sourceGuid string
---@param binding BindingDescriptor
function DataContext.UnregisterBinding(sourceGuid, binding)
    managers[binding.type].Unregister(sourceGuid, binding.key)
end

---comment
---@param type DataTypes
---@param key? string | number
---@param field string
---@return any?
function DataContext.ResolveBinding(type, key, field)
    return DataContext.HandleNestedFields(managers[type].GetContext(key), field)
end

function DataContext.HandleNestedFields(context, field)
    local parts = { strsplit(".", field) }

    local value = context
    for _, part in ipairs(parts) do
        value = value[part]
        if not value then return nil end

        if type(value) == "function" then
            value = value()
        end
    end
    return value
end

function DataContext.UpdateContext()
    Data.SpellContextManager.Update()
end