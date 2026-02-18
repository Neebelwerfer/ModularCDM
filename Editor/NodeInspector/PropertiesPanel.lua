local AceGUI = LibStub("AceGUI-3.0")
PropertiesPanel = {}

function PropertiesPanel.Build(container)
    local runtimeNode = RuntimeNodeManager.lookupTable[NodesTab.selectedNodeGuid]
    assert(runtimeNode, "Tree nodes not matching runtime nodes")
    
    local node = runtimeNode.node

    -- Scroll frame for all properties
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    container:AddChild(scroll)
    
    -- Node metadata
    local metaGroup = AceGUI:Create("InlineGroup")
    metaGroup:SetTitle("General Properties")
    metaGroup:SetFullWidth(true)
    metaGroup:SetLayout("Flow")
    scroll:AddChild(metaGroup)
    
    -- Name
    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetLabel("Node Name")
    nameInput:SetText(node.name or "")
    nameInput:SetFullWidth(true)
    nameInput:SetCallback("OnEnterPressed", function(widget, event, text)
        node.name = text
        NodesTab.Repaint()
    end)
    metaGroup:AddChild(nameInput)
    
    -- Enabled
    local enabledCheckbox = AceGUI:Create("CheckBox")
    enabledCheckbox:SetLabel("Enabled")
    enabledCheckbox:SetValue(node.enabled)
    enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        node.enabled = value
        runtimeNode.rootFrame:SetShown(value)
    end)
    metaGroup:AddChild(enabledCheckbox)
    
    -- --Frame-specific properties for each frame descriptor
    -- for frameName, propertyFrame in pairs(runtimeNode.rootFrame.frames) do
    --     local descriptor = propertyFrame.descriptor
        
    --     local frameGroup = AceGUI:Create("InlineGroup")
    --     frameGroup:SetTitle(frameName .. " (" .. descriptor.type .. ")")
    --     frameGroup:SetFullWidth(true)
    --     frameGroup:SetLayout("Flow")
    --     scroll:AddChild(frameGroup)
        
    --     -- Build type-specific property UI
    --     if descriptor.type == FrameTypes.Icon then
    --         NodesTab.BuildIconProperties(frameGroup, descriptor)
    --     elseif descriptor.type == FrameTypes.Text then
    --         NodesTab.BuildTextProperties(frameGroup, descriptor)
    --     elseif descriptor.type == FrameTypes.Bar then
    --         NodesTab.BuildBarProperties(frameGroup, descriptor)
    --     end
    -- end
end

function PropertiesPanel.BuildIconProperties(container, descriptor)
    local props = descriptor.props
    
    -- Icon texture
    PropertiesPanel.BuildPropEditor(container, "Icon", props.icon, "string", function(value)
        props.icon.value = value
        NodesTab.UpdateFrames()
    end)
    
    -- Color mask
    PropertiesPanel.BuildColorEditor(container, "Color Mask", props.colorMask, function(r, g, b, a)
        props.colorMask.value = {r=r, g=g, b=b, a=a}
        NodesTab.UpdateFrames()
    end)
    
    -- Cooldowns (if any)
    if #props.cooldowns > 0 then
        local cdGroup = AceGUI:Create("InlineGroup")
        cdGroup:SetTitle("Cooldowns")
        cdGroup:SetFullWidth(true)
        cdGroup:SetLayout("Flow")
        container:AddChild(cdGroup)
        
        -- List each cooldown
        for i, cd in ipairs(props.cooldowns) do
            local label = AceGUI:Create("Heading")
            label:SetText("Cooldown " .. i)
            label:SetFullWidth(true)
            cdGroup:AddChild(label)
            
            -- Cooldown properties...
        end
    end
end

function PropertiesPanel.BuildTextProperties(container, descriptor)
    local props = descriptor.props
    
    -- Text content
    NodesTab.BuildPropEditor(container, "Text", props.text, "string", function(value)
        props.text.value = value
        NodesTab.UpdateFrames()
    end)
    
    -- Font size
    NodesTab.BuildPropEditor(container, "Font Size", props.fontSize, "number", function(value)
        props.fontSize.value = tonumber(value)
        NodesTab.UpdateFrames()
    end)
    
    -- Color
    NodesTab.BuildColorEditor(container, "Color", props.color, function(r, g, b, a)
        props.color.value = {r=r, g=g, b=b, a=a}
        NodesTab.UpdateFrames()
    end)
end

function PropertiesPanel.BuildPropEditor(container, label, propDescriptor, valueType, onChanged)
    -- Show resolve type toggle
    if propDescriptor.allowedResolveTypes and #propDescriptor.allowedResolveTypes > 1 then
        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetLabel(label .. " (Mode)")
        dropdown:SetList({static="Static", binding="Binding"})
        dropdown:SetValue(propDescriptor.resolveType)
        dropdown:SetFullWidth(true)
        dropdown:SetCallback("OnValueChanged", function(widget, event, value)
            propDescriptor.resolveType = value
            NodesTab.RepaintInspector()
        end)
        container:AddChild(dropdown)
    end
    
    -- Show appropriate input based on resolve type
    if propDescriptor.resolveType == "static" then
        local input = AceGUI:Create("EditBox")
        input:SetLabel(label)
        input:SetText(tostring(propDescriptor.value))
        input:SetFullWidth(true)
        input:SetCallback("OnEnterPressed", function(widget, event, text)
            onChanged(text)
        end)
        container:AddChild(input)
    else
        -- Binding mode - show binding selector
        local bindingLabel = AceGUI:Create("Label")
        bindingLabel:SetText(label .. ": Bound to " .. (propDescriptor.value.binding or "none"))
        bindingLabel:SetFullWidth(true)
        container:AddChild(bindingLabel)
    end
end
