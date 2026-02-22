local addonName, ns = ...

ns.Core   = ns.Core   or {}
ns.Data   = ns.Data   or {}
ns.Nodes  = ns.Nodes  or {}
ns.Frames = ns.Frames or {}
ns.Editor = ns.Editor or {}

ns.Core.ModularCore = LibStub("AceAddon-3.0"):NewAddon("ModularCDM", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")
local ModularCore = ns.Core.ModularCore

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")


ns.CdManagerCategories = {
    Enum.CooldownViewerCategory.Essential,
    Enum.CooldownViewerCategory.Utility,
    Enum.CooldownViewerCategory.TrackedBar,
    Enum.CooldownViewerCategory.TrackedBuff
}

ns.baseSize = 46



local DirtyState = {spellID = {}, auraID = {}}

function ModularCore:OnInitialize()
    local NodeFactory = ns.Nodes.NodeFactory
    local FrameDescriptionFactory = ns.Frames.FrameDescriptionFactory
    local PropertyFactory = ns.Frames.PropertyFactory

	self.db = LibStub("AceDB-3.0"):New("ModularCDM_DB", self.defaults, true)
    
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("ModularCDM_Profiles", profiles)
	ACD:AddToBlizOptions("ModularCDM_Profiles", "ModularCDM")

    self:RegisterChatCommand("ModularCDM", "SlashCommand")
    self:RegisterChatCommand("mcdm", "SlashCommand")
    self:RegisterChatCommand("mcd", "SlashCommand")

    ns.Nodes.NodeDatabase:Initialize(self.db)
    ns.Nodes.RuntimeNodeManager.BuildAll()
    self:ScheduleRepeatingTimer("Update", 0.2)

    ns.Core.BlizzardCDMHandler.Initialize()
    ns.Data.DataContext.Initialize()
end


function ModularCore:UpdateCooldown(event, spellId, baseSpellID, category, startRecoveryCategory)
    if spellId == nil and baseSpellID == nil then
        return
    end

    if spellId then
        DirtyState["spellID"][spellId] = true
    end

    if baseSpellID then
        DirtyState["spellID"][baseSpellID] = true
    end
end

function ModularCore:SpellChanged(event)
    DirtyState["spells"] = true
end

function ModularCore:UpdateCharges(event)
    DirtyState["charges"] = true
end

function ModularCore:SlashCommand()
    if ns.Editor.EditorManager.IsOpen() then
        ns.Editor.EditorManager.Close()
        return
    end
    ns.Editor.EditorManager.Open()
end

function ModularCore:SpecChanged()
    self:BuildSpellLookup()
end

function ModularCore:Update()
    ns.Data.DataContext.UpdateContext()

    ns.Nodes.RuntimeNodeManager.UpdateNodes()
end