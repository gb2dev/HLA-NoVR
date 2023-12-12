function GravityGlovePull()
    if thisEntity:Attribute_GetIntValue("picked_up", 0) == 1 or Entities:GetLocalPlayer():Attribute_GetIntValue("picked_up", 0) == 1 then
        return
    end

    local class = thisEntity:GetClassname()
    local player = Entities:GetLocalPlayer()
    local startVector = player:EyePosition()
    local eyetrace =
    {
        startpos = startVector;
        endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(1000,0,0));
        ignore = player;
        mask =  33636363
    }
    TraceLine(eyetrace)

    if eyetrace.enthit ~= thisEntity then
        return
    end

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
    if thisEntity:GetName() == "peeled_corridor_objects" or class == "prop_reviver_heart" or vlua.find(ignore_props, thisEntity:GetModelName()) == nil and player:Attribute_GetIntValue("gravity_gloves", 0) == 1 and (class == "prop_physics" or class == "item_hlvr_health_station_vial" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_grenade_xen" or class == "item_hlvr_prop_battery" or class == "item_hlvr_combine_console_tank") and (thisEntity:GetMass() <= 15 or class == "item_hlvr_prop_battery" or thisEntity:GetModelName() == "models/interaction/anim_interact/hand_crank_wheel/hand_crank_wheel.vmdl") then
        local grabbity_glove_catch_params = { ["userid"]=player:GetUserID() }
        FireGameEvent("grabbity_glove_catch", grabbity_glove_catch_params)
        player:StopThink("GGTutorial")
        local direction = startVector - thisEntity:GetAbsOrigin()
        thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, direction.z * (115 / direction.z + 1.9)))
        StartSoundEventFromPosition("Grabbity.HoverPing", startVector)
        StartSoundEventFromPosition("Grabbity.Grab", startVector)
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
                        --DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, player, player)
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
end

local name = thisEntity:GetName()
local class = thisEntity:GetClassname()
local player = Entities:GetLocalPlayer()
local startVector = player:EyePosition()
local eyetrace =
{
    startpos = startVector;
    endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(60,0,0));
    ignore = player;
    mask = -1
}
TraceLine(eyetrace)
if eyetrace.hit then
    local useRoutine = 0
    if eyetrace.enthit and eyetrace.enthit:GetClassname() == "worldent" and class ~= "item_combine_tank_locker" and not vlua.find(class, "hlvr_piano") then
        GravityGlovePull()
        return
    end

    -- TODO: There's gotta be a better way than to exclude some things from here
    if eyetrace.enthit == thisEntity or vlua.find(class, "hlvr_piano") or name == "russell_entry_window" or class == "item_combine_tank_locker" or vlua.find(name, "socket") or vlua.find(name, "traincar_01") then
        useRoutine = 1
        player:SetThink(function()
            if IsValidEntity(thisEntity) then
                DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
            end
        end, "useextra", 0.02)
    end

    if VectorDistance(startVector, eyetrace.pos) > cvar_getf("player_use_radius") then
        player:SetThink(function()
            if IsValidEntity(thisEntity) then
                GravityGlovePull()
            end
        end, "GravityGlovePull", 0.02)
    elseif useRoutine == 0 and (eyetrace.enthit == thisEntity or vlua.find(name, "door_hack")) and IsValidEntity(thisEntity) then
		DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
    end
else
    GravityGlovePull()
end
