local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local AceHook = LibStub("AceHook-3.0")
local RuntimeNodeManager = ns.Nodes.RuntimeNodeManager
local DataTypes = ns.Core.DataTypes
local NodeFactory = ns.Nodes.NodeFactory

local NodesTab = {
    nodes = {},
    selectedNodeGuid = nil,
}
ns.Editor.NodesTab = NodesTab

local function SetHooks(buttons)
    for _, button in ipairs(buttons) do --TODO: Make it not hook on addNode, also is this the best way to do this?
        if not AceHook:IsHooked(button, "OnClick") and button.value ~= "add" then
            AceHook:HookScript(button, "OnClick", function(frame, mouseButton)
                if mouseButton == "RightButton" then
                    NodesTab.OpenContextMenu(frame, frame.value)
                end
            end)
        end
    end
end


function NodesTab.Build(container)
    NodesTab.container = container
    container:SetLayout("Fill")
    
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetFullHeight(true)
    treeGroup:SetTree(NodesTab.BuildTree())
    treeGroup:SetCallback("OnGroupSelected", NodesTab.OnNodeSelected)
    container:AddChild(treeGroup)
    NodesTab.treeGroup = treeGroup
    NodesTab.currentInspectorGroup = "properties"

    SetHooks(treeGroup.buttons)
    
    -- Select first node
    if not NodesTab.selectedNodeGuid and #RuntimeNodeManager.roots > 0 then
        local firstRoot = RuntimeNodeManager.roots[1]
        treeGroup:SelectByPath(firstRoot.guid)
    end

end

function NodesTab.BuildTree()
    local tree = {}
    
    local addNode = {
        value = "add",
        text = "Add Node",
        icon = ns.AddSign,
    }
    table.insert(tree, addNode)

    for _, runtimeNode in ipairs(RuntimeNodeManager.roots) do
        table.insert(tree, NodesTab.BuildTreeNode(runtimeNode))
    end
    
    return tree
end

function NodesTab.BuildTreeNode(runtimeNode)
    local node = runtimeNode.node
    
    -- Get icon from first binding or use question mark
    -- TODO: Node should store a seperate icon for the node itself
    local icon = ns.QuestionMark
    if node.bindings and #node.bindings > 0 then
        local firstBinding = node.bindings[1]
        if firstBinding.type == DataTypes.Spell then
            local spellInfo = C_Spell.GetSpellInfo(firstBinding.key)
            if spellInfo then
                icon = spellInfo.iconID
            end
        elseif firstBinding.type == DataTypes.Aura then
            local spellInfo = C_Spell.GetSpellInfo(firstBinding.key)
            if spellInfo then
                icon = spellInfo.iconID
            end
        end
    end
    
    local treeNode = {
        value = node.guid,
        text = node.name or "Node",
        icon = icon,
    }
    
    -- Build children
    if #node.children == 0 then return treeNode end
    treeNode.children = {}
    for _, childGuid in ipairs(node.children) do
        local childRuntime = RuntimeNodeManager.lookupTable[childGuid]
        if childRuntime then
            table.insert(treeNode.children, NodesTab.BuildTreeNode(childRuntime))
        end
    end
    
    return treeNode
end

--TODO: Dont rebuild Inspector every time
function NodesTab.OnNodeSelected(container, event, path)
    -- Extract GUID from path (last segment after \001)
    SetHooks(NodesTab.treeGroup.buttons)
    
    NodesTab.inspectorTabs = nil
    container:ReleaseChildren()
    if path == "add" then
        NodesTab.DrawAddPanel(container)
        return
    end


    local guid = path:match("([^\001]+)$")
    NodesTab.selectedNodeGuid = guid

    container:SetLayout("Fill")
    local inspectorTabs = AceGUI:Create("TabGroup")
    inspectorTabs:SetFullHeight(true)
    inspectorTabs:SetFullWidth(true)
    inspectorTabs:SetLayout("Fill")
    inspectorTabs:SetTabs({
        {text="Properties", value="properties"},
        {text="Layout", value="layout"},
        {text="Bindings", value="bindings"},
        {text="Conditions", value="conditions"},
        {text="Load", value="load"},
    })
    inspectorTabs:SetCallback("OnGroupSelected", NodesTab.OnInspectorTabSelected)
    inspectorTabs:SelectTab(NodesTab.currentInspectorGroup)
    container:AddChild(inspectorTabs)
    
    NodesTab.inspectorTabs = inspectorTabs
end

function NodesTab.OnInspectorTabSelected(container, event, group)
    container:ReleaseChildren()
    container:SetLayout("Fill")
    container:SetFullHeight(true)
    container:SetFullWidth(true)
    
    NodesTab.currentInspectorGroup = group

    if group == "properties" then
        ns.Editor.PropertiesPanel.Build(container)
    elseif group == "layout" then
        ns.Editor.LayoutPanel.Build(container)
    elseif group == "bindings" then
        ns.Editor.BindingPanel.Build(container)
    end
end


local function AddButton(container, NodeType, Text, relativeSize)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullHeight(true)
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    container:AddChild(group)

    local padGroup = AceGUI:Create("SimpleGroup")
    padGroup:SetLayout("Fill")
    padGroup:SetFullHeight(true)
    padGroup:SetRelativeWidth(0.5 - (relativeSize / 2))
    group:AddChild(padGroup)

    local addIconButton = AceGUI:Create("Button")
    addIconButton:SetText("Add " .. Text .. " Node")
    addIconButton:SetRelativeWidth(relativeSize)
    addIconButton:SetCallback("OnClick", function()
        print("Add " .. NodeType)
        local newNode = NodeFactory.Create(NodeType)
        RuntimeNodeManager.AddNewNode(newNode)
        NodesTab.Repaint()
    end)
    group:AddChild(addIconButton)
end


function NodesTab.DrawAddPanel(container)
    local templateTypes = NodeFactory.TemplateTypes
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullHeight(true)
    group:SetFullWidth(true)
    group:SetLayout("List")
    container:AddChild(group)

    AddButton(group, templateTypes.Icon, "Icon", 0.2)
    AddButton(group, templateTypes.Text, "Text", 0.2)
    AddButton(group, templateTypes.Empty, "Group", 0.2)
    AddButton(group, templateTypes.DynamicGroup, "Dynamic Group", 0.2)
end

--------------------------------------------
--- Context Menu
--------------------------------------------

function NodesTab.OpenContextMenu(frame, guid)
    local menu = MenuUtil.CreateContextMenu(frame, function (ownerRegion, description)
        description:CreateTitle(frame.value)

        description:CreateButton("Add Child Node", function()
            NodesTab.treeGroup:SelectByPath("add")
        end)
        
        description:CreateButton("Duplicate", function()
            NodesTab.DuplicateNode(guid)
        end)
        
        -- description:CreateDivider()
        
        -- description:CreateButton("Move Up", function()
        --     NodesTab.MoveNode(guid, -1)
        -- end)
        
        -- description:CreateButton("Move Down", function()
        --     NodesTab.MoveNode(guid, 1)
        -- end)
        
        -- description:CreateDivider()
        
        -- description:CreateButton("Copy", function()
        --     NodesTab.CopyNode(guid)
        -- end)
        
        -- description:CreateButton("Paste as Child", function()
        --     NodesTab.PasteNode(guid)
        -- end)
        
        description:CreateDivider()
        
        description:CreateButton("Rename", function()
            NodesTab.ShowRenameDialog(guid)
        end)
        
        description:CreateButton("Delete", function() --TODO: Make sure to delete the node in the node tables aswell, right now we just do it for the runtime node.
            RuntimeNodeManager.RemoveNode(guid)
            NodesTab.Repaint()
        end)
    end)

    --Make menu appear on top
    if menu then
        menu:SetFrameStrata("TOOLTIP")
    end
end

--------------------------------------------
--- Repaint Utility
--------------------------------------------

-- Full refresh (tree structure changed)
function NodesTab.Repaint()
    NodesTab.container:ReleaseChildren()
    NodesTab.Build(NodesTab.container)
end

-- Just refresh the current inspector panel
function NodesTab.RepaintInspector()
    if NodesTab.inspectorTabs then
        NodesTab.inspectorTabs:SelectTab(NodesTab.currentInspectorGroup)
    end
end

-- Just refresh the tree (when node name changes) 
-- TODO: Fix
function NodesTab.RepaintTree()
    NodesTab.treeGroup:SetTree(NodesTab.BuildTree())
    -- Reselect current node
    if NodesTab.selectedNodeGuid then
        NodesTab.treeGroup:SelectByPath(NodesTab.selectedNodeGuid)
    end
end