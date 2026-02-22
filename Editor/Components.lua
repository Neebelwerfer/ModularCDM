local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local FrameTypes = ns.Frames.FrameTypes
local DataTypes = ns.Core.DataTypes
local NodeFactory = ns.Nodes.NodeFactory
local RuntimeNodeManager = ns.Nodes.RuntimeNodeManager

local Components = {}
ns.Editor.Components = Components

-- Create a padded button with a before and after padding
function Components.PaddedButton(container, padBefore, padAfter)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullHeight(true)
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    container:AddChild(group)

    if padBefore > 0 then 
        local padBeforeGroup = AceGUI:Create("SimpleGroup")
        padBeforeGroup:SetLayout("Fill")
        padBeforeGroup:SetFullHeight(true)
        padBeforeGroup:SetRelativeWidth(padBefore)
        group:AddChild(padBeforeGroup)
    end

    local button = AceGUI:Create("Button")
    group:AddChild(button)

    if padAfter > 0 then 
        local padAfterGroup = AceGUI:Create("SimpleGroup")
        padAfterGroup:SetLayout("Fill")
        padAfterGroup:SetFullHeight(true)
        padAfterGroup:SetRelativeWidth(padAfter)
        group:AddChild(padAfterGroup)
    end

    return button
end