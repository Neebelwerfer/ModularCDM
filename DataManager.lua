DataManager = {
    context = {
        spells = {},
        auras = {},
        items = {},
        resources = {}
    },
    dirty = {
        spells = {},
        auras = {},
        items = {},
        resources = {}
    },
    updateInterval = 0.5,
    lastUpdate = 0
}

---Mark a data entry as dirty (needs update)
---@param dataType DataTypes
---@param key number | string
function DataManager:MarkDirty(dataType, key)
    if dataType == DataTypes.Spell then
        self.dirty.spells[key] = true
    elseif dataType == DataTypes.Aura then
        self.dirty.auras[key] = true
    elseif dataType == DataTypes.Item then
        self.dirty.items[key] = true
    elseif dataType == DataTypes.Resource then
        self.dirty.resources[key] = true
    end
end

---Register all bindings from loaded nodes
---@param nodes Node[]
function DataManager:RegisterBindings(nodes)
    -- Clear existing registrations
    self.registeredSpells = {}
    self.registeredAuras = {}
    self.registeredItems = {}
    self.registeredResources = {}
    
    -- Collect all bindings from loaded nodes
    for _, node in ipairs(nodes) do
        if node.visibility.enabled then  -- Only from visible/loaded nodes
            for _, binding in ipairs(node.bindings) do
                if binding.type == DataTypes.Spell then
                    self.registeredSpells[binding.key] = true
                elseif binding.type == DataTypes.Aura then
                    self.registeredAuras[binding.key] = true
                elseif binding.type == DataTypes.Item then
                    self.registeredItems[binding.key] = true
                elseif binding.type == DataTypes.Resource then
                    self.registeredResources[binding.key] = true
                end
            end
        end
    end
end

---Update the data context based on dirty flags
---@param elapsed number
function DataManager:OnUpdate(elapsed)
    self.lastUpdate = self.lastUpdate + elapsed
    
    if self.lastUpdate >= self.updateInterval then
        self.lastUpdate = 0
        
        -- Update spells
        for spellID, _ in pairs(self.dirty.spells) do
            if self.registeredSpells[spellID] then
                self.context.spells[spellID] = self:FetchSpellData(spellID)
            end
        end
        
        -- Update auras
        for auraID, _ in pairs(self.dirty.auras) do
            if self.registeredAuras[auraID] then
                self.context.auras[auraID] = self:FetchAuraData(auraID)
            end
        end
        
        -- Update items
        for itemID, _ in pairs(self.dirty.items) do
            if self.registeredItems[itemID] then
                self.context.items[itemID] = self:FetchItemData(itemID)
            end
        end
        
        -- Update resources
        for resourceKey, _ in pairs(self.dirty.resources) do
            if self.registeredResources[resourceKey] then
                self.context.resources[resourceKey] = self:FetchResourceData(resourceKey)
            end
        end
        
        -- Clear dirty flags
        self.dirty = {
            spells = {},
            auras = {},
            items = {},
            resources = {}
        }
    end
end

---Fetch spell data from WoW API (ONLY place WoW API is called)
---@param spellID number
---@return SpellContext
function DataManager:FetchSpellData(spellID)
    local name, _, icon = C_Spell.GetSpellInfo(spellID)
    local start, duration = GetSpellCooldown(spellID)
    local charges, maxCharges, chargeStart, chargeDuration = C_Spell.GetSpellCharges(spellID)
    local inRange = C_Spell.IsSpellInRange(spellID, "target") == 1
    local usable, nomana = C_Spell.IsUsableSpell(spellID)
    
    local remaining = 0
    if start > 0 and duration > 0 then
        remaining = math.max(0, duration - (GetTime() - start))
    end
    
    return {
        id = spellID,
        name = name,
        icon = icon,
        cooldown = {
            start = start,
            duration = duration,
            remaining = remaining
        },
        charges = {
            current = charges or 0,
            max = maxCharges or 0,
            cooldown = chargeDuration or 0
        },
        inRange = inRange,
        usable = usable,
        noMana = nomana
    }
end

---Fetch aura data from WoW API
---@param auraID number
---@return AuraContext
function DataManager:FetchAuraData(auraID)
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(auraID)
    
    if aura then
        local remaining = aura.expirationTime > 0 and (aura.expirationTime - GetTime()) or 0
        return {
            id = auraID,
            name = aura.name,
            icon = aura.icon,
            isActive = true,
            stacks = aura.applications,
            duration = {
                start = GetTime() - (aura.duration - remaining),
                duration = aura.duration,
                remaining = remaining
            },
            source = aura.sourceUnit or "unknown"
        }
    else
        return {
            id = auraID,
            name = "",
            icon = "",
            isActive = false,
            stacks = 0,
            duration = { start = 0, duration = 0, remaining = 0 },
            source = "none"
        }
    end
end

---Fetch item data from WoW API
---@param itemID number | string
---@return ItemContext
function DataManager:FetchItemData(itemID)
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    local count = GetItemCount(itemID)
    local start, duration = GetItemCooldown(itemID)
    
    local remaining = 0
    if start > 0 and duration > 0 then
        remaining = math.max(0, duration - (GetTime() - start))
    end
    
    return {
        id = itemID,
        name = name or "",
        icon = icon or "",
        count = count,
        cooldown = {
            start = start,
            duration = duration,
            remaining = remaining
        }
    }
end

---Fetch resource data from WoW API
---@param resourceKey string -- e.g., "player.mana", "player.energy"
---@return ResourceContext
function DataManager:FetchResourceData(resourceKey)
    -- Parse "unit.powerType" format
    local unit, powerType = resourceKey:match("([^.]+)%.([^.]+)")
    
    local powerTypeEnum = Enum.PowerType[powerType:upper()]
    if not powerTypeEnum then
        return { current = 0, max = 0, percent = 0, type = powerType }
    end
    
    local current = UnitPower(unit, powerTypeEnum)
    local max = UnitPowerMax(unit, powerTypeEnum)
    local percent = max > 0 and (current / max * 100) or 0
    
    return {
        current = current,
        max = max,
        percent = percent,
        type = powerType
    }
end