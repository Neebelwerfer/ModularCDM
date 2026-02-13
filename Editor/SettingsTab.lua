local AceGUI = LibStub("AceGUI-3.0")

SettingsTab = {}

function SettingsTab.Build(container)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText("Settings")
    container:AddChild(label)    
end