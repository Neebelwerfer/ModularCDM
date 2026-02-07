PropertyFactory = {}
---@class CooldownDescriptor
---@field cooldown BoundPropDescriptor
---@field hideCountdown FlexiblePropDescriptor<boolean>
---@field swipe {enabled: FlexiblePropDescriptor<boolean>, color: FlexiblePropDescriptor<Color>}
---@field edge {enabled: FlexiblePropDescriptor<boolean>, color: FlexiblePropDescriptor<Color>, scale: FlexiblePropDescriptor<number>}
---@field bling {enabled: FlexiblePropDescriptor<boolean>, color: FlexiblePropDescriptor<Color>}
---@field reverse FlexiblePropDescriptor<boolean>

---@class IconProps
---@field icon FlexiblePropDescriptor<string>
---@field colorMask FlexiblePropDescriptor<Color>
---@field cooldowns? CooldownDescriptor[]

---@class IconButtonProps : IconProps
---@field action FlexiblePropDescriptor<ButtonAction>

---@class BarProps
---@field texture FlexiblePropDescriptor<string>
---@field color FlexiblePropDescriptor<Color>

---@class TextProps
---@field text FlexiblePropDescriptor<string>
---@field color FlexiblePropDescriptor<Color>
---@field fontSize FlexiblePropDescriptor<number>

---@generic T
---@class StaticPropDescriptor<T>
---@field allowedResolveTypes ["static"]
---@field resolveType "static"
---@field valueType string
---@field value T

---@class BoundPropDescriptor
---@field allowedResolveTypes ["binding"]
---@field resolveType "binding"
---@field valueType string
---@field value BindingValueDescriptor

---@generic T
---@class FlexiblePropDescriptor<T>
---@field allowedResolveTypes ["static", "binding"]
---@field resolveType "static" | "binding"
---@field valueType string
---@field value T | BindingValueDescriptor

-- Helpers for creating props
---@return FlexiblePropDescriptor
local function FlexibleProp(valueType, defaultValue)
    return {
        allowedResolveTypes = {"static", "binding"},
        resolveType = "static",
        valueType = valueType,
        value = defaultValue
    }
end

---@return BoundPropDescriptor
local function BoundProp(valueType, defaultValue)
    return {
        allowedResolveTypes = {"binding"},
        resolveType = "binding",
        valueType = valueType,
        value = defaultValue
    }
end

---@return StaticPropDescriptor
local function StaticProp(valueType, defaultValue)
    return {
        allowedResolveTypes = {"static"},
        resolveType = "static",
        valueType = valueType,
        value = defaultValue
    }
end

---@return IconProps
function PropertyFactory.DefaultIconPropeties()
    return {
        icon = FlexibleProp("number", 134400),
        colorMask = FlexibleProp("Color", Color(1, 1, 1, 1)),
        cooldowns = {}
    }
end

function PropertyFactory.DefaultBarProperties()
    return {
        texture = FlexibleProp("string", "Interface\\TargetingFrame\\UI-StatusBar"),
        color = FlexibleProp("Color", Color(1, 1, 1, 1))
    }
end

function PropertyFactory.DefaultTextProperties()
    return {
        text = FlexibleProp("string", "Text"),
        color = FlexibleProp("Color", Color(1, 1, 1, 1)),
        fontSize = FlexibleProp("number", 12)
    }
end

function PropertyFactory.DefaultCooldownProperties()
    return {
            cooldown = BoundProp("Cooldown", nil),
            hideCountdown = FlexibleProp("boolean", false),
            swipe = {enabled = FlexibleProp("boolean", true), color = FlexibleProp("Color", Color(0.0, 0.0, 0.0, 0.8))},
            edge = {enabled = FlexibleProp("boolean", false), color = FlexibleProp("Color", Color(1, 1, 1, 1)), scale = FlexibleProp("number", 1.5)},
            bling = {enabled = FlexibleProp("boolean", false), color = FlexibleProp("Color", Color(0.5, 0.5, 0.5, 1))},
            reverse = FlexibleProp("boolean", false),
    }
end