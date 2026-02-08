--[[
The Context for Auras act a little different compared to the other context since the data is going to be dependant on the blizzard CDM.
Since the only way we can couple SpellID with auraInstanceID is through said frames, it is required by the user to add the buffs to the active part of the CDM to be registered.
]]
---@class AuraContext
---@field id number
---@field name string
---@field icon string
---@field isActive boolean
---@field stacks number
---@field duration { start: number, duration: number, modRate: number }
---@field remaining fun(): number

AuraContext = {}
AuraContext.__index = AuraContext

function AuraContext:new(key)
    local info = C_Spell.GetSpellInfo(key)
    local frame = CooldownViewerIntegration.cache[info.name]

    local context = {
        id = key,
        name = info.name,
        icon = info.iconID,
        isActive = false,
        stacks = 0,
        duration = { start = 0, duration = 0, remaining = 0 },
        internal = { info = info, frame = frame },
    }
    return context
end

function AuraContext:Update()
    local frame = self.internal.frame
    if frame then
        local auraInstanceID = frame:GetAuraSpellInstanceID()
        if auraInstanceID then
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraInstanceID) or C_UnitAuras.GetAuraDataByAuraInstanceID("target", auraInstanceID)
            if aura then
                self.isActive = true
                local duration = C_UnitAuras.GetAuraDuration("player", aura.auraInstanceID) or C_UnitAuras.GetAuraDuration("target", aura.auraInstanceID)
                self.internal.duration = duration

                self.stacks = aura.applications
                self.isActive = true
                self.duration = { start = duration:GetStartTime(), duration = duration:GetTotalDuration(), modRate = duration:GetModRate() }

                self.duration.remaining = function()
                    if not self.internal.duration then return 0 end
                    print(self.internal.duration:GetRemainingDuration())
                    return self.internal.duration:GetRemainingDuration()
                end
            end
        else
            self.isActive = false
        end
    else
        self.internal.frame = nil
        self.isActive = false
    end
end

AuraContextManager = {
    contexts = {},
}

function AuraContextManager:AddContext(key)
    local context = self:new(key)
    self.contexts[key] = context
    context:Update()
end

function AuraContextManager:UpdateContext(key)
    local context = self.contexts[key]
    if not context then return end

    context:Update()
end


function AuraContextManager:RebuildContexts()
    for key, _ in pairs(self.contexts) do
        local new = AuraContext:new(key)
        self.contexts[key] = new
    end
end