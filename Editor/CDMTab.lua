local AceGUI = LibStub("AceGUI-3.0")
CDMTab = {}

function CDMTab.Build(container)

    local cdmOptions = BlizzardCDMHandler.GetOptions()

    local topGroup = AceGUI:Create("SimpleGroup")
    topGroup:SetFullWidth(true)
    topGroup:SetFullHeight(true)
    topGroup:SetLayout("Flow")
    container:AddChild(topGroup)

    local information = AceGUI:Create("Label")
    information:SetText("Here you can control what you want to disable or keep enabled from the Blizzard Cooldown Manager")
    information:SetFullWidth(true)
    topGroup:AddChild(information)

    local header = AceGUI:Create("Heading")
    header:SetFullWidth(true)
    topGroup:AddChild(header)
    
    local disableAll = AceGUI:Create("CheckBox")
    disableAll:SetLabel("Disable All")
    disableAll:SetValue(cdmOptions.disableAll)
    disableAll:SetCallback("OnValueChanged", function(widget, callback, value) CDMTab.SetOption("disableAll", value, container)  end)
    topGroup:AddChild(disableAll)

    local generalOptions = AceGUI:Create("InlineGroup")
    generalOptions:SetFullWidth(true)
    generalOptions:SetAutoAdjustHeight(true)
    generalOptions:SetLayout("List")
    generalOptions:SetTitle("General load Options")
    topGroup:AddChild(generalOptions)

    local disableBuffs = AceGUI:Create("CheckBox")
    disableBuffs:SetLabel("Disable Buff Icons")
    disableBuffs:SetValue(cdmOptions.disableBuffIcons)
    disableBuffs:SetDisabled(cdmOptions.disableAll)
    disableBuffs:SetCallback("OnValueChanged", function(widget, callback, value) CDMTab.SetOption("disableBuffIcons", value, container)  end)
    generalOptions:AddChild(disableBuffs)

    local disableBuffBars = AceGUI:Create("CheckBox")
    disableBuffBars:SetLabel("Disable BuffBars")
    disableBuffBars:SetValue(cdmOptions.disableBuffBars)
    disableBuffBars:SetDisabled(cdmOptions.disableAll)
    disableBuffBars:SetCallback("OnValueChanged", function(widget, callback, value) CDMTab.SetOption("disableBuffBars", value, container)  end)
    generalOptions:AddChild(disableBuffBars)

    local disableEssentialCooldowns = AceGUI:Create("CheckBox")
    disableEssentialCooldowns:SetLabel("Disable Essential Cooldowns")
    disableEssentialCooldowns:SetValue(cdmOptions.disableEssentialCooldowns)
    disableEssentialCooldowns:SetDisabled(cdmOptions.disableAll)
    disableEssentialCooldowns:SetCallback("OnValueChanged", function(widget, callback, value) CDMTab.SetOption("disableEssentialCooldowns", value, container)  end)
    generalOptions:AddChild(disableEssentialCooldowns)

    local disableUtilityCooldowns = AceGUI:Create("CheckBox")
    disableUtilityCooldowns:SetLabel("Disable Utility Cooldowns")
    disableUtilityCooldowns:SetValue(cdmOptions.disableUtilityCooldowns)
    disableUtilityCooldowns:SetDisabled(cdmOptions.disableAll)
    disableUtilityCooldowns:SetCallback("OnValueChanged", function(widget, callback, value) CDMTab.SetOption("disableUtilityCooldowns", value, container)  end)
    generalOptions:AddChild(disableUtilityCooldowns)

    --- List of specific buffs/cooldown that should be disabled
    local SpecificOptions = AceGUI:Create("InlineGroup")
    SpecificOptions:SetFullWidth(true)
    SpecificOptions:SetFullHeight(true)
    SpecificOptions:SetLayout("List")
    SpecificOptions:SetTitle("Specific load Options")
    topGroup:AddChild(SpecificOptions)

    local idInput = AceGUI:Create("EditBox")
    idInput:SetLabel("ID")
    idInput:SetDisabled(cdmOptions.disableAll)
    idInput:SetCallback("OnEnterPressed", function(widget, callback, value) CDMTab.AddDisabledID(value, container)  end)
    SpecificOptions:AddChild(idInput)

    local disabledIdsContainer = AceGUI:Create("SimpleGroup")
    disabledIdsContainer:SetFullWidth(true)
    disabledIdsContainer:SetLayout("Flow")
    disabledIdsContainer:SetFullHeight(true)
    SpecificOptions:AddChild(disabledIdsContainer)

    for id, _ in pairs(cdmOptions.disabledIds) do
        local spellInfo = C_Spell.GetSpellInfo(id)
        print(id)
        local idLabel = AceGUI:Create("Label")
        idLabel:SetText(spellInfo.name .. " (" .. id .. ")")
        idLabel:SetImage(spellInfo.iconID or QuestionMark)
        idLabel:SetRelativeWidth(0.33)
        idLabel:SetImageSize(16, 16)
        idLabel:SetHeight(16)
        disabledIdsContainer:AddChild(idLabel)
    end
end

function CDMTab.SetOption(option, value, container)
    BlizzardCDMHandler.SetDisabled(option, value)
    container:ReleaseChildren() --- TODO: Make a proper refresh function?
    CDMTab.Build(container)
end


function CDMTab.AddDisabledID(id, container)
    BlizzardCDMHandler.AddDisabledID(id)
    container:ReleaseChildren() --- TODO: Make a proper refresh function?
    CDMTab.Build(container)
end