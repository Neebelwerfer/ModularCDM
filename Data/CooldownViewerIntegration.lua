CooldownViewerIntegration = {
    cache = {},
    initialized = false
}

function CooldownViewerIntegration:BuildCache()
    if InCombatLockdown() then
        return
    end
    
    local map = {}

    for i,k in ipairs(BuffIconCooldownViewer:GetLayoutChildren()) do
        local spellID = k:GetSpellID()
        local info = C_Spell.GetSpellInfo(spellID)
        
        map[info.name] = k
    end

    for i,k in ipairs(BuffBarCooldownViewer:GetLayoutChildren()) do
        if k then
            local spellID = k:GetSpellID()
            if spellID then
                if issecretvalue(spellID) then
                    return
                end

                local info = C_Spell.GetSpellInfo(spellID)
                map[info.name] = k
            end
        end
    end

    self.cache = map
end


function CooldownViewerIntegration:AddEventListeners()
    if CooldownViewerIntegration.initialized then
        return
    end

    hooksecurefunc(BuffIconCooldownViewer, "UpdateSystem", function(self, ...)
        print("UpdateSystem")
    end)

    hooksecurefunc(BuffIconCooldownViewer, "RefreshData", function(self, ...)
        print("RefreshData")
        CooldownViewerIntegration:BuildCache()
    end)

    
    hooksecurefunc(BuffIconCooldownViewer, "OnUnitAura", function(self, ...)
        
        end)
end

function CooldownViewerIntegration:Initialize()
    if CooldownViewerIntegration.initialized then
        return
    end

    self:BuildCache()
    self:AddEventListeners()
    self.initialized = true
end

function CooldownViewerIntegration:Dispose()
    if not CooldownViewerIntegration.initialized then
        return
    end

    self.cache = {}
    self.initialized = false
end