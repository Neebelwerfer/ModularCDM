FramePools = {}

--------------------------------------------
--- Root
--------------------------------------------
local function RootFrameInit(frame)
    -- Adding movement scripts, starts disabled
    frame:SetScript("OnMouseDown", function(self, button)
        self:StartMoving()
    end)
    frame:SetScript("OnMouseUp", function(self, button)
        self:StopMovingOrSizing()
        
    end)
    frame:SetMovable(true)
    frame:EnableMouse(false)

    frame.frames = {}
    frame.frameType = "Root"
end

local function RootFrameReset(_, frame)
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:Hide()

    for _, child in pairs(frame.frames) do
        local childFrame = child.frame
        FramePools.ReleaseFrame(childFrame)
    end

    table.wipe(frame.frames)
end
FramePools.root = CreateFramePool("Frame", nil, nil, RootFrameReset, nil, RootFrameInit)

--------------------------------------------
--- Icon
--------------------------------------------
local function IconFrameReset(_, frame)
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:Hide()

    for _, child in ipairs(frame.cooldowns) do
        local childFrame = child
        FramePools.ReleaseFrame(childFrame)
    end
    table.wipe(frame.cooldowns)

    frame.tex:SetTexture(nil)
    frame.tex:SetVertexColor(1, 1, 1, 1)
end

local function IconFrameInit(frame)
    frame.tex = frame:CreateTexture()
    frame.tex:SetAllPoints(frame)

    frame.cooldowns = {}
    frame.frameType = "Icon"
end

FramePools.icon = CreateFramePool("Frame", nil, "BackdropTemplate", IconFrameReset, nil, IconFrameInit)

--------------------------------------------
--- Text
--------------------------------------------
local function TextFrameInit(frame)
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetAllPoints(frame)

    frame.frameType = "Text"
end

local function TextFrameReset(_, frame)
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:Hide()

    frame.text:SetText("")
    frame.text:SetTextColor(1, 1, 1, 1)
end
FramePools.text = CreateFramePool("Frame", nil, nil, TextFrameReset, nil, TextFrameInit)

--------------------------------------------
--- Cooldown
--------------------------------------------
local function CooldownFrameInit(frame)
    frame.frameType = "Cooldown"
end

local function CooldownFrameReset(_, frame)
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:Hide()
end
FramePools.cooldown = CreateFramePool("Cooldown", nil, "CooldownFrameTemplate", CooldownFrameReset, nil, CooldownFrameInit)

--------------------------------------------
--- Bar
--------------------------------------------

local function BarFrameInit(frame)
    frame.frameType = "Bar"
end

local function BarFrameReset(_, frame)
    frame:ClearAllPoints()
    frame:SetParent(nil)
    frame:Hide()
    frame:SetMinMaxValues(0, 100)
    frame:SetValue(0)
    frame:SetStatusBarTexture(nil)
end
FramePools.bar = CreateFramePool("StatusBar", nil, nil, BarFrameReset, nil, BarFrameInit)


--------------------------------------------
--- Pools
--------------------------------------------
FramePools.pools = {
    ["Root"] = FramePools.root,
    ["Icon"] = FramePools.icon,
    ["Bar"] = FramePools.bar,
    ["Text"] = FramePools.text,
    ["Cooldown"] = FramePools.cooldown
}

---comment
---@param type "Root" | "Icon" | "Bar" | "Text" | "Cooldown"
---@param parent? Frame
---@return Frame
function FramePools.AquireFrame(type, parent)
    local frame = FramePools.pools[type]:Acquire()
    frame:SetParent(parent)
    return frame
end

function FramePools.ReleaseFrame(frame)
    FramePools.pools[frame.frameType]:Release(frame)
end