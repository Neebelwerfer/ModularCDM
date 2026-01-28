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

---@enum RuleOperators
RuleOperators = {
    equal = "=",
    greaterThan = ">",
    greaterThanOrEqual = ">=",
    lessThan = "<",
    lessThanOrEqual = "<="
}

---@class RuleBindingDescriptor
---@field binding string
---@field field string
---@field type any
---@field operator RuleOperators
---@field value any

---@class RuleComposite
---@field type string --"and" | "or"
---@field Rules (RuleBindingDescriptor | RuleComposite)[]

---@class ConditionDescriptor
---@field condition RuleBindingDescriptor | RuleComposite
---@field trueValue any | BindingValueDescriptor | ConditionDescriptor
---@field falseValue any | BindingValueDescriptor | ConditionDescriptor

---@class BindingValueDescriptor
---@field binding string
---@field field string

---@class PropDescriptor
---@field value any | BindingValueDescriptor | ConditionDescriptor -- Can be a value or a binding
---@field options? table<string, any>

---@class Transform
---@field point string
---@field relativePoint? string
---@field offsetX number
---@field offsetY number
---@field scale number

---@class FrameDescriptor
---@field type FrameTypes
---@field name string
---@field props table<string, PropDescriptor | PropDescriptor[]>
---@field visibility? RuleBindingDescriptor | RuleComposite

---@class BindingDescriptor
---@field type DataTypes
---@field alias string
---@field key string
---@field enabled boolean --TODO: Might not make sense

---@class Node
---@field guid string
---@field transform Transform
---@field parentGuid? string
---@field children Node[]
---@field frames FrameDescriptor[]
---@field bindings BindingDescriptor[]
---@field layout table
---@field options table
---@field visibility table
---@field isDirty boolean

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
            conditions = {} -- For the future
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

