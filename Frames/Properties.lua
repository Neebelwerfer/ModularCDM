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
---@field min FlexiblePropDescriptor<number>
---@field max FlexiblePropDescriptor<number>
---@field value BoundPropDescriptor<number>
---@field reverse FlexiblePropDescriptor<boolean>
---@field orientation StaticPropDescriptor<string>

---@class TextProps
---@field text FlexiblePropDescriptor<string>
---@field color FlexiblePropDescriptor<Color>
---@field fontSize FlexiblePropDescriptor<number>

---@generic T
---@class StaticPropDescriptor<T>
---@field resolveType "static"
---@field value T

---@class BoundPropDescriptor
---@field resolveType "binding"
---@field value BindingValueDescriptor

---@generic T
---@class FlexiblePropDescriptor<T>
---@field resolveType "static" | "binding"
---@field value T | BindingValueDescriptor

---@class PropertyMetadata
---@field allowedResolutions ["static" | "binding"]
---@field valueType string

-- Helpers for creating props
---@return FlexiblePropDescriptor
local function FlexibleProp(defaultValue)
    return {
        resolveType = "static",
        value = defaultValue
    }
end

---@return BoundPropDescriptor
local function BoundProp(defaultValue)
    return {
        resolveType = "binding",
        value = defaultValue
    }
end

---@return StaticPropDescriptor
local function StaticProp(defaultValue)
    return {
        resolveType = "static",
        value = defaultValue
    }
end

---@param allowedResolutions ["static" | "binding" | "template"]
---@param valueType string
---@return PropertyMetadata
local function PropertyMetadata(allowedResolutions, valueType)
    return {
        allowedResolutions = allowedResolutions,
        valueType = valueType
    }
end

---@return IconProps
function PropertyFactory.DefaultIconPropeties()
    return {
        icon = FlexibleProp(134400),
        colorMask = FlexibleProp(Color(1, 1, 1, 1)),
        cooldowns = {}
    }
end

---@return table<string, PropertyMetadata>
PropertyFactory.IconPropertyMetadata = {
    icon = PropertyMetadata({"static", "binding"}, "string"),
    colorMask = PropertyMetadata({"static"}, "Color"),
}

function PropertyFactory.DefaultBarProperties()
    return {
        texture = FlexibleProp("Interface\\TargetingFrame\\UI-StatusBar"),
        color = FlexibleProp(Color(1, 1, 1, 1)),
        min = FlexibleProp(0),
        max = FlexibleProp(100),
        value = BoundProp(nil),
        reverse = FlexibleProp(false),
        orientation = StaticProp("HORIZONTAL")
    }
end

---@return table<string, PropertyMetadata>
PropertyFactory.BarPropertyMetadata = {
    texture = PropertyMetadata({"static"}, "string"), -- TODO: Texture handling
    color = PropertyMetadata({"static"}, "Color"),
    min = PropertyMetadata({"static", "binding"}, "number"),
    max = PropertyMetadata({"static", "binding"}, "number"),
    value = PropertyMetadata({"binding"}, "number"),
    reverse = PropertyMetadata({"static"}, "boolean"),
    orientation = PropertyMetadata({"static"}, "string") -- TODO: Enum
}


function PropertyFactory.DefaultTextProperties()
    return {
        text = {value = "Text", resolveType = "template"}, -- Special case. This is a template property where {binding:field} will be replaced by the binding value runtime
        color = FlexibleProp(Color(1, 1, 1, 1)),
        fontSize = FlexibleProp(12)
    }
end

---@return table<string, PropertyMetadata>
PropertyFactory.TextPropertyMetadata ={
    text = PropertyMetadata({"template"}, "string"),
    color = PropertyMetadata({"static"}, "Color"),
    fontSize = PropertyMetadata({"static", "binding"}, "number")
}

function PropertyFactory.DefaultCooldownProperties()
    return {
            cooldown = BoundProp(nil),
            hideCountdown = FlexibleProp(false),
            swipe = {enabled = FlexibleProp(true), color = StaticProp(Color(0.0, 0.0, 0.0, 0.8))},
            edge = {enabled = FlexibleProp(false), color = StaticProp(Color(1, 1, 1, 1)), scale = StaticProp(1.5)},
            bling = {enabled = FlexibleProp(false), color = StaticProp(Color(0.5, 0.5, 0.5, 1))},
            reverse = FlexibleProp(false),
    }
end

---@return table<string, PropertyMetadata>
PropertyFactory.CooldownPropertyMetadata = {
    cooldown = PropertyMetadata({"binding"}, "string"),
    hideCountdown = PropertyMetadata({"static", "binding"}, "boolean"),
    swipe = {
        enabled = PropertyMetadata({"static", "binding"}, "boolean"),
        color = PropertyMetadata({"static"}, "Color")
    },
    edge = {
        enabled = PropertyMetadata({"static", "binding"}, "boolean"),
        color = PropertyMetadata({"static"}, "Color"),
        scale = PropertyMetadata({"static"}, "number")
    },
    bling = {
        enabled = PropertyMetadata({"static", "binding"}, "boolean"),
        color = PropertyMetadata({"static"}, "Color")
    },
    reverse = PropertyMetadata({"static", "binding"}, "boolean")
}
