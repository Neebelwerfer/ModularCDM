local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local RuntimeNodeManager = ns.Nodes.RuntimeNodeManager
local EditorUtil = ns.Editor.EditorUtil
local GroupAxis = ns.Core.GroupAxis
local GroupAnchorMode = ns.Core.GroupAnchorMode


local LayoutPanel = {}
ns.Editor.LayoutPanel = LayoutPanel

function LayoutPanel.Build(container)
    local NodesTab = ns.Editor.NodesTab
    local runtimeNode = RuntimeNodeManager.lookupTable[NodesTab.selectedNodeGuid]
    local node = runtimeNode.node
    local nodeLayout = node.layout
    local nodeTransform = node.transform
    
    -- Wrap ScrollFrame in SimpleGroup (same as Properties)
    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetHeight(10)
    scrollContainer:SetLayout("Fill")
    container:AddChild(scrollContainer)
    
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scrollContainer:AddChild(scroll)
    
    -- Transform Section
    local transformGroup = AceGUI:Create("InlineGroup")
    transformGroup:SetTitle("Transform")
    transformGroup:SetFullWidth(true)
    transformGroup:SetLayout("Flow")
    scroll:AddChild(transformGroup)
    
    -- Anchor points
    EditorUtil.CreateDropdown(transformGroup, "Anchor Point", nodeTransform.point, 0.5, 
        LayoutPanel.AnchorList, function(value)
            nodeTransform.point = value
            runtimeNode:MarkLayoutAsDirty()
        end)
    
    EditorUtil.CreateDropdown(transformGroup, "Relative To", nodeTransform.relativePoint, 0.5,
        LayoutPanel.AnchorList, function(value)
            nodeTransform.relativePoint = value
            runtimeNode:MarkLayoutAsDirty()
        end)
    
    -- Position
    EditorUtil.CreateNumberInput(transformGroup, "X Offset", nodeTransform.offsetX, 0.5, function(value)
        nodeTransform.offsetX = value
        runtimeNode:MarkLayoutAsDirty()
    end)
    
    EditorUtil.CreateNumberInput(transformGroup, "Y Offset", nodeTransform.offsetY, 0.5, function(value)
        nodeTransform.offsetY = value
        runtimeNode:MarkLayoutAsDirty()
    end)
    
    
    -- Size Section
    local sizeGroup = AceGUI:Create("InlineGroup")
    sizeGroup:SetTitle("Size")
    sizeGroup:SetFullWidth(true)
    sizeGroup:SetLayout("Flow")
    scroll:AddChild(sizeGroup)

    -- Scale
    EditorUtil.CreateNumberInput(sizeGroup, "Scale", nodeTransform.scale or 1, 1, function(value)
        nodeTransform.scale = value
        runtimeNode:MarkLayoutAsDirty()
    end)
    
    EditorUtil.CreateNumberInput(sizeGroup, "Width", nodeLayout.size.width, 0.5, function(value)
        nodeLayout.size.width = value
        runtimeNode:MarkLayoutAsDirty()
    end)
    
    EditorUtil.CreateNumberInput(sizeGroup, "Height", nodeLayout.size.height, 0.5, function(value)
        nodeLayout.size.height = value
        runtimeNode:MarkLayoutAsDirty()
    end)
    
    -- Dynamic Layout Section
    local dynamicGroup = AceGUI:Create("InlineGroup")
    dynamicGroup:SetTitle("Dynamic Layout")
    dynamicGroup:SetFullWidth(true)
    dynamicGroup:SetLayout("Flow")
    scroll:AddChild(dynamicGroup)
    
    local enabledCheckbox = AceGUI:Create("CheckBox")
    enabledCheckbox:SetLabel("Enable Dynamic Layout")
    enabledCheckbox:SetValue(nodeLayout.dynamic.enabled)
    enabledCheckbox:SetFullWidth(true)
    enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        nodeLayout.dynamic.enabled = value
        runtimeNode:MarkLayoutAsDirty()
        NodesTab.RepaintInspector()
    end)
    dynamicGroup:AddChild(enabledCheckbox)
    
    if nodeLayout.dynamic.enabled then
        -- Axis
        EditorUtil.CreateDropdown(dynamicGroup, "Axis", nodeLayout.dynamic.axis, 1,
            {[GroupAxis.Horizontal] = "Horizontal", [GroupAxis.Vertical] = "Vertical"},
            function(value)
                nodeLayout.dynamic.axis = value
                runtimeNode:MarkLayoutAsDirty()
            end)
        
        -- Anchor Mode
        EditorUtil.CreateDropdown(dynamicGroup, "Anchor Mode", nodeLayout.dynamic.anchorMode, 1,
            {[GroupAnchorMode.Leading] = "Leading", [GroupAnchorMode.Centered] = "Centered", [GroupAnchorMode.Trailing] = "Trailing"},
            function(value)
                nodeLayout.dynamic.anchorMode = value
                runtimeNode:MarkLayoutAsDirty()
            end)
        
        -- Spacing
        EditorUtil.CreateNumberInput(dynamicGroup, "Spacing", nodeLayout.dynamic.spacing, 0.5, function(value)
            nodeLayout.dynamic.spacing = value
            runtimeNode:MarkLayoutAsDirty()
        end)
        
        -- Max Per Row
        EditorUtil.CreateNumberInput(dynamicGroup, "Max Per Row", nodeLayout.dynamic.maxPerRow, 0.5, function(value)
            nodeLayout.dynamic.maxPerRow = value
            runtimeNode:MarkLayoutAsDirty()
        end)
        
        -- Collapse
        local collapseCheckbox = AceGUI:Create("CheckBox")
        collapseCheckbox:SetLabel("Collapse Hidden Children")
        collapseCheckbox:SetValue(nodeLayout.dynamic.collapse)
        collapseCheckbox:SetFullWidth(true)
        collapseCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            nodeLayout.dynamic.collapse = value
            runtimeNode:MarkLayoutAsDirty()
        end)
        dynamicGroup:AddChild(collapseCheckbox)
    end

    scroll:DoLayout()
end

LayoutPanel.AnchorList = {
        TOPLEFT = "Top Left",
        TOP = "Top",
        TOPRIGHT = "Top Right",
        LEFT = "Left",
        CENTER = "Center",
        RIGHT = "Right",
        BOTTOMLEFT = "Bottom Left",
        BOTTOM = "Bottom",
        BOTTOMRIGHT = "Bottom Right"
    }