FrameFactory = {}

---@class ButtonAction
---@field type "spell" | "macro"
---@field value string

---@class IconProps
---@field Icon FlexiblePropDescriptor<string>
---@field ColorMask FlexiblePropDescriptor<Color>

---@class IconButtonProps : IconProps
---@field Action FlexiblePropDescriptor<ButtonAction>

---@class BarProps
---@field Texture FlexiblePropDescriptor<string>
---@field Color FlexiblePropDescriptor<Color>

---@class TextProps
---@field Text FlexiblePropDescriptor<string>
---@field Color FlexiblePropDescriptor<Color>

---@class CooldownProps
---@field Timer BoundPropDescriptor
---@field Swipe FlexiblePropDescriptor<boolean>
---@field Edge FlexiblePropDescriptor<boolean>
---@field Reverse FlexiblePropDescriptor<boolean>
---@field ColorMask FlexiblePropDescriptor<Color>

---@generic T
---@class StaticPropDescriptor<T>
---@field resolveType "static"
---@field valueType string
---@field value T

---@class BoundPropDescriptor
---@field resolveType "binding"
---@field valueType string
---@field value BindingValueDescriptor

---@generic T
---@class FlexiblePropDescriptor<T>
---@field resolveType "static" | "binding"
---@field valueType string
---@field value T | BindingValueDescriptor

---@class FrameDescriptor<TProps>
---@field type Frame.FrameTypes
---@field name string
---@field props TProps
---@field visibility? RuleBindingDescriptor | RuleComposite
---@field strata? "BACKGROUND" | "LOW" | "MEDIUM" | "HIGH" | "DIALOG" | "FULLSCREEN" | "FULLSCREEN_DIALOG" | "TOOLTIP"
---@field frameLevel? number

---@enum Frame.FrameTypes
FrameTypes = {
    Icon = 1,
    Bar = 2,
    Text = 3,
    Cooldown = 4,
    IconButton = 5,
    TextButton = 6
}

-- Helpers for creating props
local function FlexibleProp(valueType, defaultValue)
    return {
        resolveType = "static",
        valueType = valueType,
        value = defaultValue
    }
end

local function BoundProp(valueType, defaultValue)
    return {
        resolveType = "binding",
        valueType = valueType,
        value = defaultValue
    }
end

local function StaticProp(valueType, defaultValue)
    return {
        resolveType = "static",
        valueType = valueType,
        value = defaultValue
    }
end

---@return FrameDescriptor<IconProps>
function FrameFactory.CreateIconFrame()
    return {
        type = FrameTypes.Icon,
        name = "Icon",
        props = {
            Icon = FlexibleProp("string", "Interface\\Icons\\INV_Misc_QuestionMark"),
            ColorMask = FlexibleProp("Color", Color(1, 1, 1, 1))
        },
    }
end

---@return FrameDescriptor<BarProps>
function FrameFactory.CreateBarFrame()
    return {
        type = FrameTypes.Bar,
        name = "Bar",
        props = {
            Texture = FlexibleProp("string", "Interface\\TargetingFrame\\UI-StatusBar"),
            Color = FlexibleProp("Color", Color(1, 1, 1, 1))
        },
    }
end

---@return FrameDescriptor<TextProps>
function FrameFactory.CreateTextFrame()
    return {
        type = FrameTypes.Text,
        name = "Text",
        props = {
            Text = FlexibleProp("string", "Text"),
            Color = FlexibleProp("Color", Color(1, 1, 1, 1))
        }
    }
end

---@return FrameDescriptor<CooldownProps>
function FrameFactory.CreateCooldownFrame()
    return {
        type = FrameTypes.Cooldown,
        name = "Cooldown",
        props = {
            Timer = BoundProp("number", nil),
            Swipe = FlexibleProp("boolean", true),
            Edge = FlexibleProp("boolean", false),
            Reverse = FlexibleProp("boolean", false),
            ColorMask = FlexibleProp("Color", Color(1, 1, 1, 1))
        }
    }
end

local frameCreators = {
    [FrameTypes.Icon] = FrameFactory.CreateIconFrame,
    [FrameTypes.Bar] = FrameFactory.CreateBarFrame,
    [FrameTypes.Text] = FrameFactory.CreateTextFrame,
    [FrameTypes.Cooldown] = FrameFactory.CreateCooldownFrame
}

---@param type Frame.FrameTypes
---@return FrameDescriptor?
function FrameFactory.GetFrameOfType(type)
    if type then
        return frameCreators[type]()
    end
end