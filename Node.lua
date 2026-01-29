Node = {}
Node.__index = Node

---@return Transform
local function DefaultTransform()
    return {
        point = "CENTER",
        relativePoint = nil,
        offsetX = 0,
        offsetY = 0,
        scale = 1
    }
end


---@enum Node.NodeTypes
Node.NodeTypes = {
    Icon = 1,
    Bar = 2,
    Text = 3,
    IconButton = 4,
    TextButton = 5,
    Group = 254, -- Used for relative positioning
    DynamicGroup = 255 -- Used for dynamic positioning of children
}



---@class Transform
---@field point string
---@field relativePoint? string
---@field offsetX number
---@field offsetY number
---@field scale number

---@class StateDescriptor
---@field name string
---@field condition RuleBindingDescriptor | RuleComposite
---@field nodeOverrides? table<string, any>  -- Override node-level properties
---@field frameOverrides? table<string, table<string, any>>  -- frameOverrides[frameName][propName] = value

---@class Node
---@field guid string
---@field name string
---@field type Node.NodeTypes
---@field transform Transform
---@field parentGuid? string
---@field children string[] -- Node guids
---@field frames FrameDescriptor[]
---@field bindings BindingDescriptor[]
---@field states StateDescriptor[]  -- Evaluated in order, first match wins
---@field layout table
---@field options table
---@field visibility table
---@field isDirty boolean
---@field meta table

---@return Node
function Node:New(overrides)
    local node = {
        guid = GenerateGUID(),
        transform = DefaultTransform(),
        parentGuid = nil,
        children = {},

        -- Frames defines the frame this node generates
        -- The frame has a type: "Icon", "Bar", "Text", "Base"
        frames = {},
        -- Bindings are the values that are passed to the frames
        bindings = {},
        -- States are evaluated in order and the first match wins
        states = {},


        -- Layout
        layout = {        
            size = {
                width = 0,
                height = 0
            },
            padding = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            },

            dynamic = {
                enabled = false,
                direction = GroupGrowDirection.Left,
                spacing = 4,
                collapse = true,     -- skip invisible/disabled children
            }
        },


        options = {
        },

        visibility = {
            load = {
                spec = nil,
                class = nil,
                role = nil,
                never = false,
            },
            enabled = true,
        },
    }

    if overrides then
        for k, v in pairs(overrides) do
            node[k] = v
        end
    end
    setmetatable(node, self)
    return node
end

function Node:HasChildren()
    return #self.children > 0
end

--TODO: Make this work with load and generic conditions
--TODO: Consider how this works with parent visibility? In WAs parent visibility does not necessarily define child visibility
function Node:IsVisible()
    return self.visibility.enabled
end

---@param childNode Node
function Node:AttachChild(childNode)
    table.insert(self.children, childNode)
    childNode.parentGuid = self.guid
end

---@param childNode Node
function Node:DetachChild(childNode)
    for i, node in ipairs(self.children) do
        if node.guid == childNode.guid then
            table.remove(self.children, i)
            break
        end
    end
    childNode.parentGuid = nil
end

---Get all bindings referenced by this node
---@return table<string, boolean>
function Node:GetReferencedBindings()
    local referenced = {}
    
    -- Check frame props
    for _, frame in ipairs(self.frames) do
        for _, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding then
                referenced[prop.value.binding] = true
            end
        end
        if frame.visibility then
            self:CollectConditionBindings(frame.visibility, referenced)
        end
    end
    
    -- Check states
    for _, state in ipairs(self.states) do
        self:CollectConditionBindings(state.condition, referenced)
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
---@param condition RuleBindingDescriptor | RuleComposite
---@param referenced table<string, boolean>
function Node:CollectConditionBindings(condition, referenced)
    if condition.type == "and" or condition.type == "or" then
        for _, rule in ipairs(condition.rules) do
            self:CollectConditionBindings(rule, referenced)
        end
    else
        if condition.binding then
            referenced[condition.binding] = true
        end
    end
end


---Update all references to a binding when it's renamed
---@param oldAlias string
---@param newAlias string
function Node:RenameBinding(oldAlias, newAlias)
    -- 1. Update the binding itself
    for _, binding in ipairs(self.bindings) do
        if binding.alias == oldAlias then
            binding.alias = newAlias
            break
        end
    end
    
    -- 2. Update frame props
    for _, frame in ipairs(self.frames) do
        for propName, prop in pairs(frame.props) do
            if prop.resolveType == "binding" and prop.value and prop.value.binding == oldAlias then
                prop.value.binding = newAlias
            end
        end
        
        -- 3. Update frame visibility conditions
        if frame.visibility then
            self:UpdateConditionBindingReferences(frame.visibility, oldAlias, newAlias)
        end
    end
    
    -- 4. Update state conditions
    for _, state in ipairs(self.states) do
        self:UpdateConditionBindingReferences(state.condition, oldAlias, newAlias)
        
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
    if self.visibility.conditions then
        for _, condition in ipairs(self.visibility.conditions) do
            self:UpdateConditionBindingReferences(condition, oldAlias, newAlias)
        end
    end
    
    self.isDirty = true
end

---Helper to recursively update binding references in conditions
---@param condition RuleBindingDescriptor | RuleComposite
---@param oldAlias string
---@param newAlias string
function Node:UpdateConditionBindingReferences(condition, oldAlias, newAlias)
    if condition.type == "and" or condition.type == "or" then
        -- RuleComposite - recurse through rules
        for _, rule in ipairs(condition.rules) do
            self:UpdateConditionBindingReferences(rule, oldAlias, newAlias)
        end
    else
        -- RuleBindingDescriptor
        if condition.binding == oldAlias then
            condition.binding = newAlias
        end
    end
end

---Remove all references to a binding and delete it
---@param alias string
function Node:RemoveBinding(alias)
    -- 1. Remove the binding itself
    for i, binding in ipairs(self.bindings) do
        if binding.alias == alias then
            table.remove(self.bindings, i)
            break
        end
    end
    
    -- 2. Clear frame props that reference it
    for _, frame in ipairs(self.frames) do
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
            self:RemoveConditionBindingReferences(frame.visibility, alias)
        end
    end
    
    -- 4. Remove states that depend on this binding
    local i = 1
    while i <= #self.states do
        local state = self.states[i]
        
        -- Check if condition uses this binding
        if self:ConditionUsesBinding(state.condition, alias) then
            table.remove(self.states, i)
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
    if self.visibility.conditions then
        local j = 1
        while j <= #self.visibility.conditions do
            if self:ConditionUsesBinding(self.visibility.conditions[j], alias) then
                table.remove(self.visibility.conditions, j)
            else
                j = j + 1
            end
        end
    end
    
    self.isDirty = true
end

---Check if a condition uses a specific binding
---@param condition RuleBindingDescriptor | RuleComposite
---@param alias string
---@return boolean
function Node:ConditionUsesBinding(condition, alias)
    if condition.type == "and" or condition.type == "or" then
        -- RuleComposite - check all rules
        for _, rule in ipairs(condition.rules) do
            if self:ConditionUsesBinding(rule, alias) then
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
---@param condition RuleBindingDescriptor | RuleComposite
---@param alias string
function Node:RemoveConditionBindingReferences(condition, alias)
    -- This is tricky - you might want to mark the condition as invalid
    -- rather than trying to patch it
    if condition.type == "and" or condition.type == "or" then
        for _, rule in ipairs(condition.rules) do
            self:RemoveConditionBindingReferences(rule, alias)
        end
    else
        if condition.binding == alias then
            -- Mark as invalid or set to a placeholder
            condition.binding = nil  -- Or "__INVALID__"
        end
    end
end

---Rename a frame and update all references
---@param oldName string
---@param newName string
function Node:RenameFrame(oldName, newName)
    -- 1. Update the frame itself
    for _, frame in ipairs(self.frames) do
        if frame.name == oldName then
            frame.name = newName
            break
        end
    end
    
    -- 2. Update state frameOverrides
    for _, state in ipairs(self.states) do
        if state.frameOverrides and state.frameOverrides[oldName] then
            state.frameOverrides[newName] = state.frameOverrides[oldName]
            state.frameOverrides[oldName] = nil
        end
    end
    
    self.isDirty = true
end

---Remove a frame and clean up references
---@param frameName string
function Node:RemoveFrame(frameName)
    -- 1. Remove the frame itself
    for i, frame in ipairs(self.frames) do
        if frame.name == frameName then
            table.remove(self.frames, i)
            break
        end
    end
    
    -- 2. Remove from state frameOverrides
    for _, state in ipairs(self.states) do
        if state.frameOverrides and state.frameOverrides[frameName] then
            state.frameOverrides[frameName] = nil
        end
    end
    
    self.isDirty = true
end

---Get all unused bindings (can be safely removed)
---@return BindingDescriptor[]
function Node:GetUnusedBindings()
    local referenced = self:GetReferencedBindings()
    local unused = {}
    
    for _, binding in ipairs(self.bindings) do
        if not referenced[binding.alias] then
            table.insert(unused, binding)
        end
    end
    
    return unused
end

---Validate all references are valid
---@return boolean, string[]
function Node:ValidateReferences()
    local errors = {}
    local bindingAliases = {}
    
    -- Build lookup of valid bindings
    for _, binding in ipairs(self.bindings) do
        bindingAliases[binding.alias] = true
    end
    
    -- Build lookup of valid frames
    local frameNames = {}
    for _, frame in ipairs(self.frames) do
        frameNames[frame.name] = true
    end
    
    -- Check frame props
    for _, frame in ipairs(self.frames) do
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
    for _, state in ipairs(self.states) do
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