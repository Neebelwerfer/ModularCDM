Bar = {}
Bar.__index = Bar

local _, env = ...


function OnFrameRelease(pool, frame)
    frame:ClearAttributes()
    frame:UnregisterAllEvents()
    frame:SetPoint("CENTER")
    frame:Show()
end

function OnFrameInit(frame)
    frame:SetScript("OnMouseDown", function(self, button)
        self:StartMoving()
    end)
    frame:SetScript("OnMouseUp", function(self, button)
        self:StopMovingOrSizing()
    end)
end

BarPool = CreateFramePool("Frame", UIParent, nil, OnFrameRelease, nil, OnFrameInit)

function Bar:new()
    local bar = {}
    bar.frame = BarPool:Acquire()
    bar.trackedSpells = {}
    bar.iconSize = env.baseSize
    setmetatable(bar, self)
    return bar
end

function Bar:SetSize(x, y)
    self.frame:SetSize(x, y)
end

function Bar:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    self.frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
end

function Bar:SetMovable(movable)
    self.frame:SetMovable(movable)
end

function Bar:Release()
    BarPool:Release(self.frame)
    self.frame = nil
end

function Bar:AddTrackedSpell(spellData)
    local trackedSpell = TrackedSpell:new(spellData, self.frame)
    self.trackedSpells[spellData.id] = trackedSpell
    self:RecalculateIconPositions()
end

function Bar:RecalculateIconPositions()
    local count = #self.trackedSpells
    self:SetSize(self.iconSize * count, self.iconSize)

    for k, v in pairs(self.trackedSpells) do
        v:SetPoint("LEFT", (k - 1) * self.iconSize, 0)
    end
end
