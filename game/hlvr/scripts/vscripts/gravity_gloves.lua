local player = Entities:GetLocalPlayer()

if thisEntity:Attribute_GetIntValue("picked_up", 0) == 1 or player:Attribute_GetIntValue("picked_up", 0) == 1 then
    player:Attribute_SetIntValue("used_gravity_gloves", 1)
    return
end

local class = thisEntity:GetClassname()
local eyePos = player:EyePosition()

local ignore_props = {
    "models/props/hazmat/hazmat_crate_lid.vmdl",
    "models/props/electric_box_door_1_32_48_front.vmdl",
    "models/props/electric_box_door_1_32_96_front.vmdl",
    "models/props/electric_box_door_2_32_48_front.vmdl",
    "models/props/interactive/washing_machine01a_door.vmdl",
    "models/props/fridge_1a_door.vmdl",
    "models/props/fridge_1a_door2.vmdl",
    "models/props_c17/mailbox_01/mailbox_02_door_a.vmdl",
    "models/props_c17/mailbox_01/mailbox_02_door_b.vmdl",
    "models/props_c17/mailbox_01/mailbox_02_door_d.vmdl",
    "models/props_c17/mailbox_01/mailbox_01_door.vmdl",
    "models/props/interactive/dumpster01a_lid.vmdl",
    "models/props/construction/portapotty_toilet_seat.vmdl",
    "models/props/interactive/file_cabinet_a_interactive_drawer_1.vmdl",
    "models/props/interactive/file_cabinet_a_interactive_drawer_2.vmdl",
    "models/props/interactive/file_cabinet_a_interactive_drawer_3.vmdl",
    "models/props/interactive/file_cabinet_a_interactive_drawer_4.vmdl",
    "models/props/interior_furniture/interior_locker_001_door_a.vmdl",
    "models/props/interior_furniture/interior_locker_001_door_b.vmdl",
    "models/props/interior_furniture/interior_locker_001_door_c.vmdl",
    "models/props/interior_furniture/interior_locker_001_door_d.vmdl",
    "models/props/interior_furniture/interior_locker_001_door_e.vmdl",
    "models/props/construction/pallet_jack_1.vmdl",
    "models/props_junk/wood_crate001a.vmdl",
    "models/props/desk_1_drawer_middle.vmdl",
}

if player:Attribute_GetIntValue("used_gravity_gloves", 0) == 1 then
    return
end

local class = thisEntity:GetClassname()
local player = Entities:GetLocalPlayer()
local startVector = thisEntity:GetCenter()
local traceTable =
{
    startpos = startVector;
    endpos = player:EyePosition();
    ignore = thisEntity;
    mask =  33636363
}
TraceLine(traceTable)

if traceTable.enthit ~= player then
    return
end

if thisEntity:GetName() == "peeled_corridor_objects" or class == "prop_reviver_heart" or vlua.find(ignore_props, thisEntity:GetModelName()) == nil and player:Attribute_GetIntValue("gravity_gloves", 0) == 1 and (class == "prop_physics" or class == "item_hlvr_health_station_vial" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_grenade_xen" or class == "item_hlvr_prop_battery" or class == "item_hlvr_combine_console_tank" or class == "item_hlvr_weapon_energygun") and (thisEntity:GetMass() <= 15 or vlua.find(thisEntity:GetModelName(), "bottle") or class == "item_hlvr_prop_battery" or thisEntity:GetModelName() == "models/interaction/anim_interact/hand_crank_wheel/hand_crank_wheel.vmdl") then
    -- prevent gravity gloving installed combine console tank
    if class == "item_hlvr_combine_console_tank" and Entities:FindByClassnameWithin(nil, "baseanimating", thisEntity:GetCenter(), 3) then
        return
    end


    -- prevent wristpocket pickup of holograms
    if string.match(thisEntity:GetModelName(), "combine_battery_hologram") then
        return
    end

    -- prevent wristpocket pickup if health station vial is already mounted in charger
    if class == "item_hlvr_health_station_vial" then
        local entcharger = Entities:FindByClassnameNearest("item_healthcharger_internals", thisEntity:GetOrigin(), 20)
        if entcharger ~= nil then
            if entcharger:GetSequence() == "idle_deployed" or entcharger:GetSequence() == "idle_retracted" then
                return
            end
        end
    end

    local parent = thisEntity:GetMoveParent()
    if parent then
        local parentClass = parent:GetClassname()
        if parentClass == "prop_ragdoll" or parentClass == "npc_zombie" or parentClass == "npc_combine_s" then
            local pos = thisEntity:GetOrigin()
            thisEntity:Kill()
            thisEntity = SpawnEntityFromTableSynchronous(class, {["origin"]="" .. pos.x .. " " .. pos.y .. " " .. pos.z})
        end
    end

    local grabbity_glove_catch_params = { ["userid"]=player:GetUserID() }
    FireGameEvent("grabbity_glove_catch", grabbity_glove_catch_params)
    player:StopThink("GGTutorial")
    local direction = eyePos - thisEntity:GetAbsOrigin()
    thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, direction.z * (115 / direction.z + 1.9)))
    StartSoundEventFromPosition("Grabbity.HoverPing", eyePos)
    StartSoundEventFromPosition("Grabbity.Grab", eyePos)
    player:Attribute_SetIntValue("used_gravity_gloves", 1)
    local count = 0
    thisEntity:SetThink(function()
        local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 60)
        if vlua.find(ents, thisEntity) then
            if not WristPockets_PickUpValuableItem(player, thisEntity) and thisEntity:GetMass() ~= 1 then
                DoEntFireByInstanceHandle(thisEntity, "Use", "", 0, player, player)
            end
            if class == "item_hlvr_grenade_frag" then
                SendToConsole("+use")
                thisEntity:SetThink(function()
                    SendToConsole("-use")
                    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0.02, player, player)
                end, "", 0.02)
                if vlua.find(thisEntity:GetSequence(), "vr_grenade_arm_") then
                    DoEntFireByInstanceHandle(thisEntity, "SetTimer", "3", 0, nil, nil)
                end
            end
            return nil
        end

        if count < 5 then
            count = count + 1
            return 0.1
        end
    end, "GrabItem", 0.1)
end
