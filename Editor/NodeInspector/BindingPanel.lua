local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")
local DataTypes = ns.Core.DataTypes
local RuntimeNodeManager = ns.Nodes.RuntimeNodeManager
local EditorUtil = ns.Editor.EditorUtil

local BindingPanel = {}
ns.Editor.BindingPanel = BindingPanel

local DataTypeToString = {
    [DataTypes.Spell] = "Spell",
    [DataTypes.Aura] = "Aura",
    [DataTypes.Item] = "Item",
    [DataTypes.Resource] = "Resource"
}

function BindingPanel.Build(container)
    local NodesTab = ns.Editor.NodesTab
    local runtimeNode = RuntimeNodeManager.lookupTable[NodesTab.selectedNodeGuid]
    local node = runtimeNode.node
    
    container:SetLayout("Flow")
    
    -- Add Binding Button
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Binding")
    addButton:SetFullWidth(true)
    addButton:SetCallback("OnClick", function()
        BindingPanel.ShowBindingEditor(node.guid, nil)  -- nil = create new
    end)
    container:AddChild(addButton)
    
    -- Spacer
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    container:AddChild(spacer)
    
    -- Existing Bindings List
    local bindingsGroup = AceGUI:Create("InlineGroup")
    bindingsGroup:SetTitle("Bindings (" .. #node.bindings .. ")")
    bindingsGroup:SetFullWidth(true)
    bindingsGroup:SetLayout("Flow")
    container:AddChild(bindingsGroup)
    
    if #node.bindings == 0 then
        local emptyLabel = AceGUI:Create("Label")
        emptyLabel:SetText("No bindings. Click 'Add Binding' to create one.")
        emptyLabel:SetFullWidth(true)
        bindingsGroup:AddChild(emptyLabel)
    else
        for i, binding in ipairs(node.bindings) do
            local bindingRow = AceGUI:Create("SimpleGroup")
            bindingRow:SetFullWidth(true)
            bindingRow:SetLayout("Flow")
            bindingsGroup:AddChild(bindingRow)
            
            -- Icon (if available)
            local icon = EditorUtil.GetBindingIcon(binding)
            if icon then
                local iconWidget = AceGUI:Create("Icon")
                iconWidget:SetImage(icon)
                iconWidget:SetImageSize(24, 24)
                iconWidget:SetWidth(32)
                bindingRow:AddChild(iconWidget)
            end
            
            -- Alias + Type/ID info
            local infoLabel = AceGUI:Create("Label")
            infoLabel:SetText(string.format("%s\n|cFF888888%s: %s|r", 
                binding.alias, 
                DataTypeToString[binding.type], 
                tostring(binding.key)))
            infoLabel:SetRelativeWidth(0.6)
            bindingRow:AddChild(infoLabel)
            
            -- Edit button
            local editButton = AceGUI:Create("Button")
            editButton:SetText("Edit")
            editButton:SetWidth(60)
            editButton:SetCallback("OnClick", function()
                BindingPanel.ShowBindingEditor(node.guid, i)
            end)
            bindingRow:AddChild(editButton)
            
            -- Delete button
            local deleteButton = AceGUI:Create("Button")
            deleteButton:SetText("Delete")
            deleteButton:SetWidth(120)
            deleteButton:SetCallback("OnClick", function()
                runtimeNode:RemoveBinding(i)
                NodesTab.RepaintInspector()
            end)
            bindingRow:AddChild(deleteButton)
        end
    end
end

-- Binding Editor Dialog
function BindingPanel.ShowBindingEditor(nodeGuid, bindingIndex)
    local NodesTab = ns.Editor.NodesTab
    local runtimeNode = RuntimeNodeManager.lookupTable[nodeGuid]
    local node = runtimeNode.node
    if not node then return end
    
    local isEdit = bindingIndex ~= nil
    local binding = isEdit and node.bindings[bindingIndex] or {
        type = DataTypes.Spell,
        alias = "",
        key = ""
    }
    
    -- Create editor frame
    local frame = AceGUI:Create("Window")
    frame:SetTitle(isEdit and "Edit Binding" or "Create Binding")
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(300)
    frame.frame:SetFrameStrata("TOOLTIP")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    
    -- Type dropdown
    local typeDropdown = AceGUI:Create("Dropdown")
    typeDropdown:SetLabel("Type")
    typeDropdown:SetList({
        [DataTypes.Spell] = "Spell",
        [DataTypes.Aura] = "Aura",
        [DataTypes.Item] = "Item",
        [DataTypes.Resource] = "Resource"
    })
    typeDropdown:SetValue(binding.type)
    typeDropdown:SetFullWidth(true)
    frame:AddChild(typeDropdown)
    
    -- Alias input
    local aliasInput = AceGUI:Create("EditBox")
    aliasInput:SetLabel("Alias (Display Name)")
    aliasInput:SetText(binding.alias)
    aliasInput:SetFullWidth(true)
    aliasInput:DisableButton(true)
    frame:AddChild(aliasInput)
    
    -- Key input
    local keyInput = AceGUI:Create("EditBox")
    keyInput:SetLabel("ID (Spell/Aura/Item/Resource ID)")
    keyInput:SetText(tostring(binding.key))
    keyInput:SetFullWidth(true)
    keyInput:DisableButton(true)
    frame:AddChild(keyInput)
    
    -- Options section (if needed later)
    -- local optionsGroup = AceGUI:Create("InlineGroup")
    -- optionsGroup:SetTitle("Options")
    -- optionsGroup:SetFullWidth(true)
    -- optionsGroup:SetLayout("Flow")
    -- frame:AddChild(optionsGroup)
    
    -- Buttons
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetFullWidth(true)
    buttonGroup:SetLayout("Flow")
    frame:AddChild(buttonGroup)
    
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText(isEdit and "Save" or "Create")
    saveButton:SetWidth(120)
    saveButton:SetCallback("OnClick", function()
        local newBinding = {
            type = typeDropdown:GetValue(),
            alias = aliasInput:GetText(),
            key = tonumber(keyInput:GetText()) or keyInput:GetText()
        }
        
        if newBinding.alias == "" or newBinding.key == "" then
            print("Alias and ID are required")
            return
        end
        
        if isEdit then
            runtimeNode:UpdateBinding(bindingIndex, newBinding)
        else
            runtimeNode:AddBinding(newBinding)
        end       
        frame:Hide()
        NodesTab.RepaintInspector()
    end)
    buttonGroup:AddChild(saveButton)
end
