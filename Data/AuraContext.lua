---@class AuraContext
---@field id number
---@field name string
---@field icon string
---@field isActive boolean
---@field stacks number
---@field duration { start: number, duration: number, modRate: number }
---@field remaining fun(): number
---@field source string -- "player", "target", etc.


AuraContext = {}

ViewerMap = {}

function AuraContext.BuildViewerMap()
    local viewer = BuffIconCooldownViewer
    
    if InCombatLockdown() then
        return
    end

    scrubsecretvalues(ViewerMap)
    ViewerMap = {}
    for i,k in pairs(viewer:GetLayoutChildren()) do
        local spellID = k:GetSpellID()
        local info = C_Spell.GetSpellInfo(spellID)
        
        ViewerMap[info.name] = k
    end

end

function AuraContext.Create(key)
    local info = C_Spell.GetSpellInfo(key)

    AuraContext.BuildViewerMap()

    local context = {
        id = key,
        name = info.name,
        icon = info.iconID,
        isActive = false,
        stacks = 0,
        duration = { start = 0, duration = 0, remaining = 0 },
        source = "player",
        internal = {},
    }

    local frame = ViewerMap[info.name]

    if frame then
        local auraInstanceID = frame:GetAuraSpellInstanceID()
        if auraInstanceID then
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraInstanceID) or C_UnitAuras.GetAuraDataByAuraInstanceID("target", auraInstanceID)
            if aura then
                local duration = C_UnitAuras.GetAuraDuration("player", aura.auraInstanceID) or C_UnitAuras.GetAuraDuration("target", aura.auraInstanceID)
                context.internal.duration = duration

                context.stacks = aura.applications
                context.isActive = true
                context.duration = { start = duration:GetStartTime(), duration = duration:GetTotalDuration(), modRate = duration:GetModRate() }

                context.duration.remaining = function()
                    if not context.internal.duration then return 0 end
                    print(context.internal.duration:GetRemainingDuration())
                    return context.internal.duration:GetRemainingDuration()
                end
            end
        end
    end


    return context

    -- if auraInfo then
    --     local duration = C_UnitAuras.GetAuraDuration("player", auraInfo.auraInstanceID)
    --     context.internal.duration = duration

    --     context.stacks = auraInfo.applications
    --     context.isActive = true
    --     context.duration = { start = duration:GetStartTime(), duration = duration:GetTotalDuration(), modRate = duration:GetModRate() }

    --     context.duration.remaining = function()
    --         if not context.internal.duration then return 0 end
    --         print(context.internal.duration:GetRemainingDuration())
    --         return context.internal.duration:GetRemainingDuration()
    --     end
    -- end

    -- return context
end