TrackedObject = {}
TrackedObject.__index = TrackedObject

local _, env = ...

TrackedObjectTypes = {
    Spell = 1,
    Item = 2,
    Aura = 3
}

function OnInit(frame)
    frame:SetScript("OnDragStart", function(self, button)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
end

FramePool = CreateFramePool("Frame", nil, "BackdropTemplate", nil, nil, OnInit)

function TrackedObject.CreateTrackedSpell(guid, id, parentFrame, config)
    guid = guid or GenerateGUID()

    local spell = env.spellLookup[id]
    if spell == nil then
        return nil
    end
    
    local item = TrackedObject:new(guid, TrackedObjectTypes.Spell, spell, parentFrame, config)
    return item
end


function TrackedObject:new(guid, type, data, parentFrame, config)
    local trackedObject = {}
    trackedObject.guid = guid
    trackedObject.type = type
    trackedObject.data = data
    
    trackedObject.config = config or {
        size = env.baseSize
    }

    trackedObject.internalState = {
        timers = {},
    }
    
    trackedObject.frame = FramePool:Acquire()
    trackedObject.frame:SetParent(parentFrame)
    trackedObject.frame:SetPoint("CENTER", parentFrame, "CENTER", 0, 0)
    trackedObject.frame:SetSize(trackedObject.config.size, trackedObject.config.size)
    trackedObject.frame.tex = trackedObject.frame:CreateTexture()
    trackedObject.frame.tex:SetAllPoints()
    trackedObject.frame.tex:SetTexture(data.iconId)
    trackedObject.frame:Show()

    if data.hasCharges then
        trackedObject.chargeFrame = CreateFrame("Frame", nil, trackedObject.frame, "BackdropTemplate")
        trackedObject.chargeFrame:SetAllPoints()
        
        trackedObject.charges = trackedObject.chargeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        trackedObject.charges:SetPoint("CENTER", trackedObject.frame, "BOTTOMRIGHT", -10, 10)

        if data.hasCharges then
            print(data.id)
            local charges = C_Spell.GetSpellCharges(data.id)
            trackedObject.charges:SetText(tostring(charges.currentCharges))
        end
    end

    trackedObject.Cooldown = CreateFrame("Cooldown", nil, trackedObject.frame, "CooldownFrameTemplate")
    trackedObject.Cooldown:SetAllPoints(trackedObject.frame)
    trackedObject.Cooldown:SetDrawEdge(false)
    trackedObject.Cooldown:SetDrawSwipe(true)
    trackedObject.Cooldown:SetSwipeColor(0, 0, 0, 0.8)
    trackedObject.Cooldown:SetHideCountdownNumbers(false)
    trackedObject.Cooldown:SetReverse(false)
    
    setmetatable(trackedObject, TrackedObject)
    return trackedObject
end

function TrackedObject:SetPoint(point, offsetX, offsetY)
    self.frame:SetPoint(point, offsetX, offsetY)
end

function TrackedObject:Show()
    self.frame:Show()
end

function TrackedObject:Hide()
    self.frame:Hide()
end

CDTimerTypes = {
    Charge = 1,
    Cooldown = 2,
    Aura = 3,
}

function TrackedObject:Update(DirtyState)
    if(DirtyState["spellID"][self.data.id] or (self.data.hasCharges and DirtyState["charges"])) then
        self.internalState.timers = {}
        
        if self.type == TrackedObjectTypes.Spell then
            if self.data.hasCharges then
                local charges = C_Spell.GetSpellCharges(self.data.id)
                if charges then
                    self.charges:SetText(tostring(charges.currentCharges))
                    local timer = self.CreateTimer(CDTimerTypes.Charge, charges.cooldownStartTime, charges.cooldownDuration)
                    table.insert(self.internalState.timers, timer)
                end
            end
            
            local cooldownData = C_Spell.GetSpellCooldown(self.data.id)
            
            if self.data.linkedSpellIDs and (self.data.selfAura or self.data.hasAura) then
                for _, linkedSpellId in pairs(self.data.linkedSpellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(linkedSpellId)
                    if aura then
                        local timer = self.CreateTimer(CDTimerTypes.Aura, aura.expirationTime - aura.duration, aura.duration)
                        table.insert(self.internalState.timers, timer)
                    end
                end
            end
        
            if cooldownData and cooldownData.duration > 1 then
                local timer = self.CreateTimer(CDTimerTypes.Cooldown, cooldownData.startTime, cooldownData.duration)
                table.insert(self.internalState.timers, timer)
            end
        end
    end

    if #self.internalState.timers > 0 then
        local type = -1
        local timer = nil

        for _, t in ipairs(self.internalState.timers) do
            local isOld = t.startTime + t.duration < GetTime()
            if t.type > type and not isOld then
                type = t.type
                timer = t
            end
        end

        if type == CDTimerTypes.Charge then
            self.Cooldown:SetCooldown(timer.startTime, timer.duration)
            self.Cooldown:SetDrawSwipe(false)
            self.Cooldown:SetDrawEdge(true)
            self.Cooldown:SetReverse(false)
        elseif type == CDTimerTypes.Cooldown then
            self.Cooldown:SetCooldown(timer.startTime, timer.duration)
            self.Cooldown:SetDrawSwipe(true)
            self.Cooldown:SetDrawEdge(false)
            self.Cooldown:SetReverse(false)
        elseif type == CDTimerTypes.Aura then
            self.Cooldown:SetCooldown(timer.startTime, timer.duration)
            self.Cooldown:SetDrawSwipe(true)
            self.Cooldown:SetDrawEdge(false)
            self.Cooldown:SetReverse(true)
        else
            self.Cooldown:Clear()
        end
    end
end

function TrackedObject.CreateTimer(type, startTime, duration)
    local timer = {
        startTime = startTime,
        duration = duration,
        type = type
    }
    return timer
end