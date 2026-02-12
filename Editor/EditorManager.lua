local AceGUI = LibStub("AceGUI-3.0")

EditorManager = {
    frame = nil,           -- Main AceGUI frame
    selectedNode = nil,    -- Currently selected node GUID
    treeView = nil,        -- AceGUI TreeGroup
    inspector = nil        -- AceGUI container for property widgets
}

function EditorManager.Open()
    if EditorManager.frame then
        EditorManager.frame:Show()
        return
    end
    
    -- Create main window
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Node Editor")
    frame:SetLayout("Fill")
    frame:SetWidth(900)
    frame:SetHeight(600)
    
    -- Create horizontal container for panels
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    
    -- Left panel: Tree view
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetTree(EditorManager.BuildTree())
    treeGroup:SetCallback("OnGroupSelected", EditorManager.OnNodeSelected)
    treeGroup:SetRelativeWidth(0.3)
    treeGroup:SetFullHeight(true)
    container:AddChild(treeGroup)
    
    -- Right panel: Inspector
    local inspector = AceGUI:Create("ScrollFrame")
    inspector:SetLayout("Flow")
    inspector:SetRelativeWidth(0.7)
    inspector:SetFullHeight(true)
    container:AddChild(inspector)
    
    frame:AddChild(container)
    
    EditorManager.frame = frame
    EditorManager.treeView = treeGroup
    EditorManager.inspector = inspector
end

function EditorManager.OnNodeSelected(group)
    -- EditorManager.selectedNode = EditorManager.treeView:GetSelected()
    -- EditorManager.inspector:ReleaseChildren()
    for k, v in pairs(group)
    do
        print(k, v)
    end
end

function EditorManager.BuildTree()
    local tree = {}
    
    for _, root in ipairs(RuntimeNodeManager.roots) do
        table.insert(tree, EditorManager.BuildTreeNode(root.guid, ""))
    end
    
    return tree
end

function EditorManager.BuildTreeNode(guid, parentPath)
    local node = RuntimeNodeManager.lookupTable[guid].node
    local path = parentPath .. "\001" .. guid  -- AceGUI tree path format
    
    local treeNode = {
        value = guid,
        text = (node.name or "Node ") .. guid,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    }

    if node.children and #node.children > 0 then
        treeNode.children = {}
    end
    
    -- Recursively add children
    for _, childGuid in ipairs(node.children) do
        table.insert(treeNode.children, EditorManager.BuildTreeNode(childGuid, path))
    end
    
    return treeNode
end