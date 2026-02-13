local AceGUI = LibStub("AceGUI-3.0")

NodesTab = {}

function NodesTab.Build(container)
    -- Create horizontal container for panels
    local containerGroup = AceGUI:Create("SimpleGroup")
    containerGroup:SetLayout("Flow")
    containerGroup:SetFullWidth(true)
    containerGroup:SetFullHeight(true)
    
    -- Left panel: Tree view
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetTree(EditorManager.BuildTree())
    treeGroup:SetCallback("OnGroupSelected", NodesTab.OnNodeSelected)
    treeGroup:SetRelativeWidth(0.3)
    treeGroup:SetFullHeight(true)
    containerGroup:AddChild(treeGroup)
    
    -- Right panel: Inspector
    local inspector = AceGUI:Create("ScrollFrame")
    inspector:SetLayout("Flow")
    inspector:SetRelativeWidth(0.7)
    inspector:SetFullHeight(true)
    containerGroup:AddChild(inspector)
    
    container:AddChild(containerGroup)
end

function NodesTab.OnNodeSelected(group)
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