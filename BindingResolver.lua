---@class BindingResolver
BindingResolver = {}

---Get a value from the data context
---@param bindingAlias string
---@param field string
---@param node Node
---@return any
function BindingResolver.GetValue(bindingAlias, field, node)
    -- Find the binding in the node
    local binding = nil
    for _, b in ipairs(node.bindings) do
        if b.alias == bindingAlias then
            binding = b
            break
        end
    end
    
    if not binding then
        return nil
    end
    
    -- Resolve from DataContext
    local data = nil
    if binding.type == DataTypes.Spell then
        data = DataManager.context.spells[binding.key]
    elseif binding.type == DataTypes.Aura then
        data = DataManager.context.auras[binding.key]
    elseif binding.type == DataTypes.Item then
        data = DataManager.context.items[binding.key]
    elseif binding.type == DataTypes.Resource then
        data = DataManager.context.resources[binding.key]
    end
    
    if not data then
        return nil
    end
    
    -- Navigate the field path (e.g., "cooldown.remaining")
    return BindingResolver.NavigateField(data, field)
end

---Navigate a dot-notation field path
---@param data table
---@param field string
---@return any
function BindingResolver.NavigateField(data, field)
    local current = data
    for part in field:gmatch("[^.]+") do
        if type(current) == "table" then
            current = current[part]
        else
            return nil
        end
    end
    return current
end