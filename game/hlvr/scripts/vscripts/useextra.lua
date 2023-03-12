local class = thisEntity:GetClassname()
local name = thisEntity:GetName()

local item_pickup_params = { ["userid"]=Entities:GetLocalPlayer():GetUserID(), ["item"]=class, ["item_name"]=name }

if class == "item_hlvr_crafting_currency_small" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 0 0 0 1")
    SendToConsole("play sounds\\player\\inventory\\inv_grab_item_resin_01")
    thisEntity:Kill()
elseif class == "item_hlvr_clip_energygun" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 10 0 0 0")
    SendToConsole("play sounds\\player\\inventory\\inv_backpack_deposit_01")
    thisEntity:Kill()
end
