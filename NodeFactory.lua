NodeFactory = {}

---@enum NodeFactory.NodeTemplateTypes
NodeFactory.NodeTemplateTypes = {
    Spell = 1,
    Item = 2,
    Aura = 3,
    Text = 4,
    Group = 5,
    DynamicGroup = 6
}


function NodeFactory.DefaultNode()
    return Node:New()
end

local templateCreators = {
    [NodeFactory.NodeTemplateTypes.Spell] = NodeFactory.CreateSpellNode
}

---@param NodeTemplate? NodeFactory.NodeTemplateTypes
function NodeFactory.CreateNode(NodeTemplate)
    if NodeTemplate then
        return templateCreators[NodeTemplate]()
    else
        return NodeFactory.DefaultNode()
    end
end

function NodeFactory.CreateSpellNode()
    local node = NodeFactory.DefaultNode()
    node.frames = {
        { type = FrameTypes.Icon, name = "icon", props = {} }
    }
    node.bindings = {
        { type = DataTypes.Spell, alias = "main", key = nil }
    }
    return node
end




-- NodeFactory.FrameDescriptors
local function CreateIconFrame()
    return {
        type = FrameTypes.Icon,
        name = "Icon",
        props = {
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            desaturated = false
        },

        options = {
            size = {
                width = 32,
                height = 32
            }
        }
    }
end

local function CreateCooldownFrame()
    return {
        type = FrameTypes.Cooldown,
        name = "Cooldown",
        props = {
            Timers = {

            }
        },
        options = {
            size = {
                width = 32,
                height = 32
            }
        }
    }
end


