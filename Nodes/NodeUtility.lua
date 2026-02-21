local _, ns = ...

ns.Nodes.NodeUtility = {}
local NodeUtility = ns.Nodes.NodeUtility


---@param node Node
---@return string
function NodeUtility.GetNodeName(node)
    return node.Name
end

---@param node Node
---@return boolean
function NodeUtility.HasChildren(node)
    return #node.children > 0
end

--TODO: Make this work with load and generic conditions
--TODO: Consider how this works with parent visibility? In WAs parent visibility does not necessarily define child visibility
---@param node Node
---@return boolean
function NodeUtility.IsVisible(node)
    return node.visibility.enabled
end

---@param node Node
---@param childNode Node
function NodeUtility.AttachChild(node, childNode)
    table.insert(node.children, childNode)
    childNode.parentGuid = node.guid
end

---@param node Node
---@param childNode Node
function NodeUtility.DetachChild(node, childNode)
    for i, node in ipairs(node.children) do
        if node.guid == childNode.guid then
            table.remove(node.children, i)
            break
        end
    end
    childNode.parentGuid = nil
end

---Get all bindings referenced by this node
---@param node Node
---@return string[]
function NodeUtility.GetReferencedBindings(node)
    local referenced = {}
    
    -- Check frame props
    for _, frame in ipairs(node.frames) do
        for _, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding then
                referenced[prop.value.binding] = true
            end
        end
        if frame.visibility then
            NodeUtility.CollectConditionBindings(node, frame.visibility, referenced)
        end
    end
    
    -- Check states
    for _, state in ipairs(node.states) do
        NodeUtility.CollectConditionBindings(node, state.condition, referenced)
        if state.frameOverrides then
            for _, overrides in pairs(state.frameOverrides) do
                for _, value in pairs(overrides) do
                    if type(value) == "table" and value.binding then
                        referenced[value.binding] = true
                    end
                end
            end
        end
    end
    
    return referenced
end

---Helper to collect bindings from conditions
---@param node Node
---@param condition RuleBindingDescriptor | RuleComposite
---@param referenced table<string, boolean>
function NodeUtility.CollectConditionBindings(node, condition, referenced)
    if condition.type == "and" or condition.type == "or" then
        for _, rule in ipairs(condition.rules) do
            NodeUtility.CollectConditionBindings(node, rule, referenced)
        end
    else
        if condition.binding then
            referenced[condition.binding] = true
        end
    end
end


---Update all references to a binding when it's renamed
---@param node Node
---@param oldAlias string
---@param newAlias string
function NodeUtility.RenameBinding(node, oldAlias, newAlias)
    -- 1. Update the binding itself
    for _, binding in ipairs(node.bindings) do
        if binding.alias == oldAlias then
            binding.alias = newAlias
            break
        end
    end
    
    -- 2. Update frame props
    for _, frame in ipairs(node.frames) do
        for propName, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding == oldAlias then
                prop.value.binding = newAlias
            end
        end
        
        -- 3. Update frame visibility conditions
        if frame.visibility then
            NodeUtility.UpdateConditionBindingReferences(node, frame.visibility, oldAlias, newAlias)
        end
    end
    
    -- 4. Update state conditions
    for _, state in ipairs(node.states) do
        NodeUtility.UpdateConditionBindingReferences(node, state.condition, oldAlias, newAlias)
        
        -- 5. Update state overrides
        if state.frameOverrides then
            for frameName, overrides in pairs(state.frameOverrides) do
                for propName, value in pairs(overrides) do
                    if type(value) == "table" and value.binding == oldAlias then
                        value.binding = newAlias
                    end
                end
            end
        end
    end
    
    -- 6. Update node visibility conditions
    if node.visibility.conditions then
        for _, condition in ipairs(node.visibility.conditions) do
            NodeUtility.UpdateConditionBindingReferences(node, condition, oldAlias, newAlias)
        end
    end
    
    node.isDirty = true
end

---Helper to recursively update binding references in conditions
---@param node Node
---@param condition RuleBindingDescriptor | RuleComposite
---@param oldAlias string
---@param newAlias string
function NodeUtility.UpdateConditionBindingReferences(node, condition, oldAlias, newAlias)
    if condition.type == "and" or condition.type == "or" then
        -- RuleComposite - recurse through rules
        for _, rule in ipairs(condition.rules) do
            NodeUtility.UpdateConditionBindingReferences(node, rule, oldAlias, newAlias)
        end
    else
        -- RuleBindingDescriptor
        if condition.binding == oldAlias then
            condition.binding = newAlias
        end
    end
end

---Remove all references to a binding and delete it
---@param node Node
---@param alias string
function NodeUtility.RemoveBinding(node, alias)
    -- 1. Remove the binding itself
    for i, binding in ipairs(node.bindings) do
        if binding.alias == alias then
            table.remove(node.bindings, i)
            break
        end
    end
    
    -- 2. Clear frame props that reference it
    for _, frame in ipairs(node.frames) do
        for propName, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding == alias then
                -- Reset to static default or nil
                prop.value = nil
                -- Optionally switch to static type with a default value
                -- prop.resolveType = "static"
                -- prop.value = GetDefaultValueForType(prop.valueType)
            end
        end
        
        -- 3. Remove from frame visibility (or disable the condition)
        if frame.visibility then
            NodeUtility.RemoveConditionBindingReferences(node, frame.visibility, alias)
        end
    end
    
    -- 4. Remove states that depend on this binding
    local i = 1
    while i <= #node.states do
        local state = node.states[i]
        
        -- Check if condition uses this binding
        if NodeUtility.ConditionUsesBinding(node, state.condition, alias) then
            table.remove(node.states, i)
            -- Don't increment i, check same index again
        else
            -- Check if overrides use this binding
            if state.frameOverrides then
                for frameName, overrides in pairs(state.frameOverrides) do
                    for propName, value in pairs(overrides) do
                        if type(value) == "table" and value.binding == alias then
                            overrides[propName] = nil
                        end
                    end
                end
            end
            i = i + 1
        end
    end
    
    -- 5. Update node visibility conditions
    if node.visibility.conditions then
        local j = 1
        while j <= #node.visibility.conditions do
            if NodeUtility.ConditionUsesBinding(node, node.visibility.conditions[j], alias) then
                table.remove(node.visibility.conditions, j)
            else
                j = j + 1
            end
        end
    end
    
    node.isDirty = true
end

---Check if a condition uses a specific binding
---@param node Node
---@param condition RuleBindingDescriptor | RuleComposite
---@param alias string
---@return boolean
function NodeUtility.ConditionUsesBinding(node, condition, alias)
    if condition.type == "and" or condition.type == "or" then
        -- RuleComposite - check all rules
        for _, rule in ipairs(condition.rules) do
            if NodeUtility.ConditionUsesBinding(node, rule, alias) then
                return true
            end
        end
        return false
    else
        -- RuleBindingDescriptor
        return condition.binding == alias
    end
end

---Helper to remove binding references from a condition (sets to invalid state)
---@param node Node
---@param condition RuleBindingDescriptor | RuleComposite
---@param alias string
function NodeUtility.RemoveConditionBindingReferences(node, condition, alias)
    -- This is tricky - you might want to mark the condition as invalid
    -- rather than trying to patch it
    if condition.type == "and" or condition.type == "or" then
        for _, rule in ipairs(condition.rules) do
            NodeUtility.RemoveConditionBindingReferences(node, rule, alias)
        end
    else
        if condition.binding == alias then
            -- Mark as invalid or set to a placeholder
            condition.binding = nil  -- Or "__INVALID__"
        end
    end
end

---Rename a frame and update all references
---@param node Node
---@param oldName string
---@param newName string
function NodeUtility.RenameFrame(node, oldName, newName)
    -- 1. Update the frame itself
    for _, frame in ipairs(node.frames) do
        if frame.name == oldName then
            frame.name = newName
            break
        end
    end
    
    -- 2. Update state frameOverrides
    for _, state in ipairs(node.states) do
        if state.frameOverrides and state.frameOverrides[oldName] then
            state.frameOverrides[newName] = state.frameOverrides[oldName]
            state.frameOverrides[oldName] = nil
        end
    end
    
    node.isDirty = true
end

---Remove a frame and clean up references
---@param node Node
---@param frameName string
function NodeUtility.RemoveFrame(node, frameName)
    -- 1. Remove the frame itself
    for i, frame in ipairs(node.frames) do
        if frame.name == frameName then
            table.remove(node.frames, i)
            break
        end
    end
    
    -- 2. Remove from state frameOverrides
    for _, state in ipairs(node.states) do
        if state.frameOverrides and state.frameOverrides[frameName] then
            state.frameOverrides[frameName] = nil
        end
    end
    
    node.isDirty = true
end

---Get all unused bindings (can be safely removed)
---@param node Node
---@return BindingDescriptor[]
function NodeUtility.GetUnusedBindings(node)
    local referenced = NodeUtility.GetReferencedBindings(node)
    local unused = {}
    
    for _, binding in ipairs(node.bindings) do
        if not referenced[binding.alias] then
            table.insert(unused, binding)
        end
    end
    
    return unused
end

---Validate all references are valid
---@param node Node
---@return boolean, string[]
function NodeUtility.ValidateReferences(node)
    local errors = {}
    local bindingAliases = {}
    
    -- Build lookup of valid bindings
    for _, binding in ipairs(node.bindings) do
        bindingAliases[binding.alias] = true
    end
    
    -- Build lookup of valid frames
    local frameNames = {}
    for _, frame in ipairs(node.frames) do
        frameNames[frame.name] = true
    end
    
    -- Check frame props
    for _, frame in ipairs(node.frames) do
        for propName, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding then
                if not bindingAliases[prop.value.binding] then
                    table.insert(errors, string.format(
                        "Frame '%s' prop '%s' references unknown binding '%s'",
                        frame.name, propName, prop.value.binding
                    ))
                end
            end
        end
    end
    
    -- Check state frameOverrides
    for _, state in ipairs(node.states) do
        if state.frameOverrides then
            for frameName, _ in pairs(state.frameOverrides) do
                if not frameNames[frameName] then
                    table.insert(errors, string.format(
                        "State '%s' references unknown frame '%s'",
                        state.name, frameName
                    ))
                end
            end
        end
    end
    
    return #errors == 0, errors
end