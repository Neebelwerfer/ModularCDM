local _, ns = ...
local DataTypes = ns.Core.DataTypes

local PreviewDataProvider = {}
ns.Editor.Preview = {}
ns.Editor.Preview.PreviewDataProvider = PreviewDataProvider

local fakeSpell = {
    id = 1234,
    name = "FakeSpell",
    icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    cooldown = { start = 0, duration = 0, remaining = 0 },
    charges = { current = 0, max = 0 },
    inRange = true,
    usable = true,
    noMana = false
}

local fakeAura = {
    id = 1234,
    name = "FakeAura",
    icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    duration = C_DurationUtil.CreateDuration(),
    remaining = 0,
    stack = 0
}

local typeToData = {
    [DataTypes.Spell] = fakeSpell,
    [DataTypes.Aura] = fakeAura
}

local elapsedTime = 0
local first = true
function PreviewDataProvider.Update(deltaTime)
    elapsedTime = elapsedTime + deltaTime
    if first or elapsedTime > 10 then
        elapsedTime = 0
        fakeSpell.cooldown = { start = GetTime(), duration = 8, remaining = 8 }
        first = false
    else
        if fakeSpell.cooldown then
            fakeSpell.cooldown.remaining = fakeSpell.cooldown.duration - elapsedTime
            if fakeSpell.cooldown.remaining < 0 then
                fakeSpell.cooldown = nil
            end
        end
    end
end

function PreviewDataProvider.Restart()
    first = true
end


function PreviewDataProvider.ResolveBinding(type, key, field)
    return PreviewDataProvider.HandleNestedFields(typeToData[type], field)
end

function PreviewDataProvider.HandleNestedFields(context, field)
    local parts = { strsplit(".", field) }

    local value = context
    for _, part in ipairs(parts) do
        value = value[part]
        if not value then return nil end

        if type(value) == "function" then
            value = value()
        end
    end
    return value
end