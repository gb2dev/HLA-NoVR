local class = thisEntity:GetClassname()
local player = Entities:GetLocalPlayer()
local startVector = player:EyePosition()
local eyetrace =
{
    startpos = startVector;
    endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(60,0,0));
    ignore = player;
    mask =  33636363
}
TraceLine(eyetrace)

if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 then
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
    }
    if eyetrace.hit or thisEntity:GetName() == "ChoreoPhysProxy" then
        DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
    elseif vlua.find(ignore_props, thisEntity:GetModelName()) == nil and player:Attribute_GetIntValue("gravity_gloves", 0) == 1 and (class == "prop_physics" or class == "item_hlvr_health_station_vial" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_grenade_xen" or class == "item_hlvr_prop_battery") and (thisEntity:GetMass() <= 15 or class == "item_hlvr_prop_battery") then
        local grabbity_glove_catch_params = { ["userid"]=player:GetUserID() }
        FireGameEvent("grabbity_glove_catch", grabbity_glove_catch_params)
        local direction = startVector - thisEntity:GetAbsOrigin()
        thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, Clamp(direction.z * 3.8, -400, 400)))
        StartSoundEventFromPosition("Grabbity.HoverPing", startVector)
        StartSoundEventFromPosition("Grabbity.Grab", startVector)
        local delay = 0.35
        if VectorDistance(startVector, thisEntity:GetAbsOrigin()) > 350 then
            delay = 0.45
        end
        thisEntity:SetThink(function()
            local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 120)
            if vlua.find(ents, thisEntity) then
                DoEntFireByInstanceHandle(thisEntity, "Use", "", 0, player, player)
                if class == "item_hlvr_grenade_frag" then
                    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, player, player)
                end
            end
        end, "GrabItem", delay)
    end
end
