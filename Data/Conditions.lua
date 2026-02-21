local addonName, ns = ...

ns.Data.Conditions = {}
local Conditions = ns.Data.Conditions

---@enum Conditions.RuleOperators
Conditions.RuleOperators = {
    Equals = "==",
    NotEquals = "!=",
    GreaterThan = ">",
    LessThan = "<",
    GreaterOrEqual = ">=",
    LessOrEqual = "<=",
    Contains = "contains",
    NotContains = "notcontains",
    Matches = "matches",  -- For pattern matching
}

---@class RuleBindingDescriptor
---@field binding string
---@field field string
---@field operator Conditions.RuleOperators
---@field value any

---@class RuleComposite
---@field type "and" | "or"
---@field rules (RuleBindingDescriptor | RuleComposite)[]

---@class ConditionDescriptor
---@field condition RuleBindingDescriptor | RuleComposite
---@field trueValue any | BindingValueDescriptor | ConditionDescriptor
---@field falseValue any | BindingValueDescriptor | ConditionDescriptor

---Create a binding rule (pure data, no functions)
---@param binding string
---@param field string
---@param operator Conditions.RuleOperators
---@param value any
---@return RuleBindingDescriptor
function Conditions.CreateRule(binding, field, operator, value)
    return {
        binding = binding,
        field = field,
        operator = operator,
        value = value
    }
end

---Create a composite rule (pure data, no functions)
---@param type "and" | "or"
---@param rules (RuleBindingDescriptor | RuleComposite)[]
---@return RuleComposite
function Conditions.CreateComposite(type, rules)
    return {
        type = type,
        rules = rules
    }
end

---Resolve a rule against a node
---@param rule RuleBindingDescriptor | RuleComposite
---@param node Node
---@return boolean
function Conditions.Resolve(rule, node)
    if rule.type == "and" or rule.type == "or" then
        -- Composite rule
        if rule.type == "and" then
            for _, r in ipairs(rule.rules) do
                if not Conditions.Resolve(r, node) then
                    return false
                end
            end
            return true
        else -- "or"
            for _, r in ipairs(rule.rules) do
                if Conditions.Resolve(r, node) then
                    return true
                end
            end
            return false
        end
    else
        -- Simple binding rule
        -- local actualValue = BindingResolver.GetValue(rule.binding, rule.field, node)
        -- return Conditions.CompareValues(actualValue, rule.operator, rule.value)
        return false
    end
end

---Helper: Compare values based on operator
---@param actualValue any
---@param operator Conditions.RuleOperators
---@param expectedValue any
---@return boolean
function Conditions.CompareValues(actualValue, operator, expectedValue)
    if operator == Conditions.RuleOperators.Equals then
        return actualValue == expectedValue
    elseif operator == Conditions.RuleOperators.NotEquals then
        return actualValue ~= expectedValue
    elseif operator == Conditions.RuleOperators.GreaterThan then
        return actualValue > expectedValue
    elseif operator == Conditions.RuleOperators.LessThan then
        return actualValue < expectedValue
    elseif operator == Conditions.RuleOperators.GreaterOrEqual then
        return actualValue >= expectedValue
    elseif operator == Conditions.RuleOperators.LessOrEqual then
        return actualValue <= expectedValue
    elseif operator == Conditions.RuleOperators.Contains then
        return type(actualValue) == "string" and actualValue:find(expectedValue, 1, true) ~= nil
    elseif operator == Conditions.RuleOperators.NotContains then
        return type(actualValue) == "string" and actualValue:find(expectedValue, 1, true) == nil
    elseif operator == Conditions.RuleOperators.Matches then
        return type(actualValue) == "string" and actualValue:match(expectedValue) ~= nil
    end
    return false
end