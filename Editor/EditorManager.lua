local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")

local EditorManager = {
    frame = nil,           -- Main AceGUI frame
}
ns.Editor.EditorManager = EditorManager

local tabGroups = {
    nodes = "Nodes",
    BCDM = "Blizzard CDM Options",
    settings = "Settings",
}

function EditorManager.IsOpen()
    return EditorManager.frame and EditorManager.frame:IsShown()
end

function EditorManager.Close()
    if EditorManager.frame then
        AceGUI:Release(EditorManager.frame)
        EditorManager.frame = nil
    end
end

function EditorManager.Open()
    -- Create main window
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Modular CDM")
    frame:SetLayout("Fill")
    frame:SetWidth(900)
    frame:SetHeight(600)

    -- Tab group for Hierarchy/Settings
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")

    tabGroup:SetTabs({
        { text = tabGroups.nodes, value = tabGroups.nodes },
        { text = tabGroups.BCDM, value = tabGroups.BCDM },
        { text = tabGroups.settings, value = tabGroups.settings },
    })
    tabGroup:SetCallback("OnGroupSelected", EditorManager.OnTabSelected)
    tabGroup:SelectTab(tabGroups.nodes)
    
    frame:AddChild(tabGroup)
    
    EditorManager.frame = frame
end

function EditorManager.OnTabSelected(container, event, group)
    container:ReleaseChildren()
    
    if group == tabGroups.nodes then
        ns.Editor.NodesTab.Build(container)
    elseif group == tabGroups.BCDM then
        ns.Editor.CDMTab.Build(container)
    elseif group == tabGroups.settings then
        ns.Editor.SettingsTab.Build(container)
    end
end