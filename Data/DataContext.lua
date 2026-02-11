---@class DataContext
---@field spells table<number, SpellContext>
---@field auras table<number, AuraContext>
---@field items table<number, ItemContext>
---@field resources table<string, ResourceContext>


DataContext = {
    dirty = { -- Tracks which parts of the context have changed
        spells = {},
        auras = {},
        items = {},
        resources = {}
    },

    bindings = {}, -- Tracks subscribers of each binding

    updateInterval = 0.5,
    lastUpdate = 0,

    managers = {
        [DataTypes.Spell] = SpellContextManager,
        [DataTypes.Aura] = AuraContextManager
    }
}

function DataContext.Initialize()
    AuraContextManager.Initialize()
end

---Register a binding from a node
---@param sourceGuid string
---@param binding BindingDescriptor
function DataContext.RegisterBinding(sourceGuid, binding)
    DataContext.managers[binding.type].Register(sourceGuid, binding.key)
end


---Unregister a binding from a node
---@param sourceGuid string
---@param binding BindingDescriptor
function DataContext.UnregisterBinding(sourceGuid, binding)
    DataContext.managers[binding.type].Unregister(sourceGuid, binding.key)
end

---comment
---@param type DataTypes
---@param key? string | number
---@param field string
---@return any?
function DataContext.ResolveBinding(type, key, field)
    return DataContext.HandleNestedFields(DataContext.managers[type].contexts[key], field)
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
    SpellContextManager.Update()
end