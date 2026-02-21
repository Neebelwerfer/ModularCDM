local _, ns = ...
local AceGUI = LibStub("AceGUI-3.0")

local SettingsTab = {}
ns.Editor.SettingsTab = SettingsTab

function SettingsTab.Build(container)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText("Settings")
    container:AddChild(label)    
end