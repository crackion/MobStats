setfenv(1, MobStats)

---@class ArmorDrawer
ArmorDrawer = {}

---@param value_or_nil ArmorVO|nil
---@param tooltip TooltipInterface
function ArmorDrawer:Draw(value_or_nil, tooltip)
    if value_or_nil == nil then
        return
    end
    local value = --[[---@type ArmorVO]] value_or_nil

    local integer_amount = round(value:GetAmount(), 0)

    local amount_string
    if integer_amount == 0 then
        amount_string = "None"
    else
        amount_string = format("%d (%d%% DR)", integer_amount, round(value:GetDamageReductionInPercents(), 0))
    end

    tooltip:AddValue("Armor", amount_string, false)
end
