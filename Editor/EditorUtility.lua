local AceGUI = LibStub("AceGUI-3.0")

EditorUtil = {}


function EditorUtil.CreateDropdown(container, label, value, width, list, callback)
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel(label)
    dropdown:SetList(list)
    dropdown:SetValue(value)
    dropdown:SetRelativeWidth(width)
    dropdown:SetCallback("OnValueChanged", function(widget, event, newValue)
        callback(newValue)
    end)
    container:AddChild(dropdown)
    return dropdown
end

function EditorUtil.CreateNumberInput(container, label, value, width, callback)
    local input = AceGUI:Create("EditBox")
    input:SetLabel(label)
    input:SetText(tostring(value))
    input:SetRelativeWidth(width)
    input:DisableButton(true)
    input:SetCallback("OnEnterPressed", function(widget, event, text)
        local num = tonumber(text)
        if num then
            callback(num)
        else
            widget:SetText(tostring(value))  -- Reset to previous value
        end
    end)
    container:AddChild(input)
    return input
end

function EditorUtil.GetBindingIcon(binding)
    if binding.type == DataTypes.Spell or binding.type == DataTypes.Aura then
        local spellInfo = C_Spell.GetSpellInfo(binding.key)
        return spellInfo and spellInfo.iconID
    elseif binding.type == DataTypes.Item then
        local itemInfo = C_Item.GetItemIconByID(binding.key)
        return itemInfo
    end
    return QuestionMark
end