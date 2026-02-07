---@class SpellContext
---@field id number
---@field name string
---@field icon string
---@field cooldown? fun(): { start: number, duration: number, modRate: number}
---@field charges? fun(): { current: number, max: number, cooldown?: { start: number, duration: number, modRate: number}}
---@field inRange boolean
---@field usable boolean
---@field noMana boolean

SpellContext = {}

---@param key number | string
---@return SpellContext
function SpellContext.Create(key)
    local spellInfo = C_Spell.GetSpellInfo(key)
    local charges = C_Spell.GetSpellCharges(key)
    local cooldown = C_Spell.GetSpellCooldown(key)
    local isUsable, noMana = C_Spell.IsSpellUsable(key)
    local inRange = C_Spell.IsSpellInRange(key, "target")

    local context = {
        id = spellInfo.spellID,
        name = spellInfo.name,
        icon = spellInfo.iconID,
        inRange = inRange,
        usable = isUsable,
        noMana = noMana,
        internal = {},
        cooldown = {
            start = cooldown.startTime,
            duration = cooldown.duration,
            modRate = cooldown.modRate,
        },
        charges = {
            current = charges.currentCharges,
            max = charges.maxCharges,
            cooldown = {
                start = charges.cooldownStartTime,
                duration = charges.cooldownDuration,
                modRate = charges.chargeModRate
            }
        }
    }

    if cooldown then
        context.internal.cooldownDurationUtil = C_Spell.GetSpellCooldownDuration(key)
    end

    context.cooldown.remaining = function()
        if not context.internal.cooldownDurationUtil then return 0 end
        return context.internal.cooldownDurationUtil:GetRemainingDuration(Enum.DurationTimeModifier.RealTime) or 0
    end

    context.cooldown.isActive = function()
        return context.internal.cooldown and not context.internal.cooldown.durationUtil:IsZero()
    end

    context.internal.charges = {
        current = charges.currentCharges,
        max = charges.maxCharges,
        cooldown = {
            start = charges.cooldownStartTime,
            duration = charges.cooldownDuration,
            modRate = charges.chargeModRate
        },
    }
    return context
end