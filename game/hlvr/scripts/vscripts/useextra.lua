local map = GetMapName()
local class = thisEntity:GetClassname()
local name = thisEntity:GetName()
local player = Entities:GetLocalPlayer()

if class == "item_hlvr_weapon_shotgun" then
    SendToConsole("give weapon_shotgun")
    SendToConsole("ent_fire 12712_relay_player_shotgun_is_ready trigger")
    thisEntity:Kill()
end

if name == "12712_shotgun_wheel" then
    SendToConsole("ent_fire !picker setcompletionvalue 10")
    return
end

if name == "bell" then
    DoEntFireByInstanceHandle(thisEntity, "PlayAnimation", "chain_pull", 0, nil, nil)
    DoEntFireByInstanceHandle(thisEntity, "SetPlaybackRate", "8", 0, nil, nil)
    SendToConsole("ent_fire_output bell OnCompletionA_Forward")
    return
end

if name == "4910_135_interactive_wheel" then
    SendToConsole("ent_fire 4910_139_verticaldoor_movelinear open")
    return
end

if class == "prop_hlvr_crafting_station_console" then
    SendToConsole("ent_fire prop_hlvr_crafting_station OpenStation")
end

if class == "item_hlvr_combine_console_tank" then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(500,0,0))
end

if class == "prop_animinteractable" then
    DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "1", 0, nil, nil)
end

if class == "item_health_station_charger" then
    DoEntFireByInstanceHandle(thisEntity, "EnableOnlyRunForward", "", 0, nil, nil)
    DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "1", 0, nil, nil)
    thisEntity:FireOutput("OnCompletionA_Forward", nil, nil, nil, 0)
end

if class == "item_healthcharger_reservoir" then
    StartSoundEventFromPosition("HealthStation.Start", player:EyePosition())
end

if map == "a2_quarantine_entrance" then
    if name == "toner_port" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
        SendToConsole("ent_fire_output toner_path_5 OnPowerOn")
        thisEntity:Attribute_SetIntValue("used", 1)
    end

    if class == "item_hlvr_combine_console_rack" then
        DoEntFireByInstanceHandle(thisEntity, "EnableOnlyRunForward", "", 0, nil, nil)
        DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "1", 0, nil, nil)
        local ent = Entities:FindByName(nil, "17670_combine_console")
        DoEntFireByInstanceHandle(ent, "RackOpening", "1", 0, thisEntity, thisEntity)
    end
    
    if name == "27788_combine_locker" then
        SendToConsole("ent_fire_output 27788_locker_hack_plug OnHackSuccess")
    end
    
    if class == "baseanimating" then
        SendToConsole("ent_fire_output 17670_console_hacking_plug OnHackSuccess")
        SendToConsole("ent_fire item_hlvr_combine_console_tank disablepickup")
    end
end

local item_pickup_params = { ["userid"]=player:GetUserID(), ["item"]=class, ["item_name"]=name }

if class == "item_hlvr_crafting_currency_small" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 0 0 0 1")
    SendToConsole("play sounds\\player\\inventory\\inv_grab_item_resin_01")
    thisEntity:Kill()
elseif class == "item_hlvr_clip_energygun" then
    FireGameEvent("item_pickup", item_pickup_params)
    if name == "pistol_clip_1" then
        SendToConsole("ent_remove weapon_bugbait")
        SendToConsole("give weapon_pistol")
    else
        SendToConsole("hlvr_addresources 10 0 0 0")
    end
    SendToConsole("play sounds\\player\\inventory\\inv_backpack_deposit_01")
    thisEntity:Kill()
end
