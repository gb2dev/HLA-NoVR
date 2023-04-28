DoIncludeScript("bindings.lua", nil)

local map = GetMapName()
local class = thisEntity:GetClassname()
local name = thisEntity:GetName()
local model = thisEntity:GetModelName()
local player = Entities:GetLocalPlayer()

if not (vlua.find(name, "elev_anim_door") and thisEntity:GetVelocity() ~= Vector(0, 0, 0)) then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:Attribute_SetIntValue("toggle", 1)
    else
        thisEntity:Attribute_SetIntValue("toggle", 0)
    end
end

if thisEntity:Attribute_GetIntValue("junction_rotation", 0) == 3 then
    thisEntity:Attribute_SetIntValue("junction_rotation", 0)
else
    thisEntity:Attribute_SetIntValue("junction_rotation", thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1)
end


-- Toner Puzzles

-- First Path in the Puzzle
local toner_start_path
-- Last/Success Path
local toner_end_path
-- example_toner_path = {"leads_to_this_junction", point1, point2, point3, ...}
local toner_paths
-- example_toner_junction = {type (0=straight, 1=right angle, 2=two right angles, 3=static T), "activated_toner_path_1", "activated_toner_path_2", "activated_toner_path_3", "activated_toner_path_4"}
local toner_junctions

if map == "a2_quarantine_entrance" then
    toner_start_path = "toner_path_1"
    toner_end_path = "toner_path_5"

    toner_paths = {
        toner_path_1 = {"toner_junction_1", Vector(-912.1, 1150.47, 100), Vector(-912.1, 1112, 100)},
        toner_path_2 = {"toner_junction_2", Vector(-912.1, 1112, 100), Vector(-912.1, 1099, 100), Vector(-912.1, 1099, 108.658), Vector(-912.1, 1088.1, 108.658), Vector(-929, 1088.1, 108.658)},
        toner_path_3 = {"", Vector(-929, 1088.1, 108.658), Vector(-929, 1088.1, 144), Vector(-946, 1088.1, 144)},
        toner_path_5 = {"", Vector(-970, 1088.1, 98.4348), Vector(-986, 1088.1, 98.4348)},
        toner_path_7 = {"toner_junction_3", Vector(-929, 1088.1, 108.658), Vector(-929, 1088.1, 98.4348), Vector(-947, 1088.1, 98.4348), Vector(-947, 1088.1, 69.5763), Vector(-947, 1088.1, 98.4348), Vector(-970, 1088.1, 98.4348)},
    }
    
    toner_junctions = {
        toner_junction_1 = {0, "toner_path_2", "", "toner_path_2", ""},
        toner_junction_2 = {1, "toner_path_3", "toner_path_7", "", ""},
        toner_junction_3 = {0, "toner_path_5", "", "toner_path_5", ""},
    }
elseif map == "a2_headcrabs_tunnel" then
    toner_start_path = "toner_path_1"
    toner_end_path = ""

    toner_paths = {
        toner_path_1 = {"toner_junction_1", Vector(-440.082, -591.641, 10.1066), Vector(-456.077, -582.406, 10.1066)},
        toner_path_2 = {"", Vector(-456.077, -582.406, 10.1066), Vector(-456.077, -582.406, 1.25), Vector(-492.011, -561.866, 1.25), Vector(-508.747, -590.854, 1.25)},
        toner_path_3 = {"toner_junction_2", Vector(-456.077, -582.406, 10.1066), Vector(-456.077, -582.406, 20.25), Vector(-489.012, -563.389, 20.25), Vector(-507.848, -589.466, 20.25), Vector(-563.691, -557.735, 20.25), Vector(-563.471, -557.356, 0.5)},
        toner_path_5 = {"", Vector(-563.471, -557.356, 0.5), Vector(-591.523, -541.157, 0.5), Vector(-583.348, -527.429, 0.5), Vector(-612.043, -511.988, 3.5)},
        toner_path_6 = {"", Vector(-563.471, -557.356, 0.5), Vector(-551.359, -564.352, 0.5), Vector(-518.847, -584.56, 0.5)},
        toner_path_8 = {"", Vector(), Vector()},
    }

    toner_junctions = {
        toner_junction_1 = {2, "toner_path_3", "toner_path_2", "toner_path_3", "toner_path_2"},
        toner_junction_2 = {2, "toner_path_6", "toner_path_5", "toner_path_6", "toner_path_5"},
        --toner_junction_i = {0, "toner_path_8", "", "toner_path_8", ""},
    }
end

function draw_toner_path(toner_path)
    for i = 3, #toner_path do
        DebugDrawLine(toner_path[i - 1], toner_path[i], 0, 0, 255, false, -1)
    end
end

function draw_toner_junction(junction, center, angles)
    local type = junction[1]

    if type == 0 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)
    elseif type == 1 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)
    elseif type == 2 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        DebugDrawLine(center + min, center + max, 0, 0, 0, true, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        DebugDrawLine(center + min, center + max, 0, 0, 0, true, -1)
    end
end

function toggle_toner_junction()
    local junction = toner_junctions[thisEntity:GetName()]

    if junction then
        DebugDrawClear()
        for toner_path_name, toner_path in pairs(toner_paths) do
            draw_toner_path(toner_path)
        end

        local angles = thisEntity:GetAngles()
        StartSoundEventFromPosition("Toner.JunctionRotate", player:EyePosition())

        local new_index = thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1
        local old_index = new_index - 1
        if old_index == 0 then
            old_index = 4
        end

        ent = Entities:FindByClassname(nil, "info_hlvr_toner_path")
        while ent do
            ent:FireOutput("OnPowerOff", nil, nil, nil, 0)
            ent = Entities:FindByClassname(ent, "info_hlvr_toner_path")
        end

        local toner_path = toner_start_path
        while toner_path ~= "" do
            local junction_name = toner_paths[toner_path][1]
            local junction_entity = Entities:FindByName(nil, junction_name)
            if junction_entity then
                local activated_path = junction_entity:Attribute_GetIntValue("junction_rotation", 0) + 2
                local next_path = toner_junctions[junction_name][activated_path]
                toner_path = next_path
                if next_path ~= "" then
                    SendToConsole("ent_fire_output " .. next_path .. " OnPowerOn")
                    if next_path == toner_end_path then
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())

                        player:Attribute_SetIntValue("circuit_" .. map .. "_" .. toner_start_path .. "_completed", 1)

                        player:SetThink(function()
                            DebugDrawClear()
                        end, "TonerComplete", 3)
                    end
                end
            else
                toner_path = ""
            end
        end

        for junction_name, junction in pairs(toner_junctions) do
            local junction_entity = Entities:FindByName(nil, junction_name)
            local angles = junction_entity:GetAngles()
            angles = QAngle(angles.x, angles.y, junction_entity:Attribute_GetIntValue("junction_rotation", 0) * 90)
            draw_toner_junction(junction, junction_entity:GetCenter(), angles)
        end
    end
end

if class == "info_hlvr_toner_port" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    --thisEntity:Attribute_SetIntValue("used", 1)
    DoEntFireByInstanceHandle(thisEntity, "OnPlugRotated", "", 0, nil, nil)
    DebugDrawClear()
    if toner_junctions then
        for junction_name, junction in pairs(toner_junctions) do
            local junction_entity = Entities:FindByName(nil, junction_name)
            local angles = junction_entity:GetAngles()
            angles = QAngle(angles.x, angles.y, junction_entity:Attribute_GetIntValue("junction_rotation", 0) * 90)
            draw_toner_junction(junction, junction_entity:GetCenter(), angles)
        end
        for toner_path_name, toner_path in pairs(toner_paths) do
            draw_toner_path(toner_path)
        end
    end
end

if class == "info_hlvr_toner_junction" and player:Attribute_GetIntValue("circuit_" .. map .. "_" .. toner_start_path .. "_completed", 0) == 0 then
    toggle_toner_junction()
end


function is_combine_console_locked()
    local ents = Entities:FindAllByClassnameWithin("baseanimating", thisEntity:GetCenter(), 3)
    for i = 1, #ents do
        local ent = ents[i]
        if ent:GetModelName() == "models/props_combine/combine_consoles/handle_plate.vmdl" and ent:GetCycle() == 1 then
            return false
        end
    end
    return true
end

if not vlua.find(model, "doorhandle") and name ~= "@pod_shell" and name ~= "589_panel_switch" and name ~= "tc_door_control" and (class == "item_health_station_charger" or (class == "prop_animinteractable" and (not vlua.find(name, "elev_anim_door") or (vlua.find(name, "elev_anim_door") and thisEntity:Attribute_GetIntValue("toggle", 0) == 1 and thisEntity:GetVelocity() == Vector(0, 0, 0))) and not vlua.find(name, "5628_2901_barricade_door")) or (class == "item_hlvr_combine_console_rack" and is_combine_console_locked() == false)) and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    if map == "a3_distillery" and vlua.find(name, "plug") and player:Attribute_GetIntValue("plug_lever", 0) == 0 then
        return
    end

    if vlua.find(name, "slide_train_door") and Entities:FindByClassnameNearest("phys_constraint", thisEntity:GetCenter(), 20) then
        return
    end

    if name == "12712_shotgun_wheel" and Entities:FindByNameNearest("12712_shotgun_bar_for_wheel", thisEntity:GetCenter(), 20) then
        return
    end

    if name == "greenhouse_door" then
        if string.format("%.2f", thisEntity:GetCycle()) ~= "0.05" then
            return
        end
    end
    
    local count = 0
    if class == "prop_animinteractable" and model == "models/props_subway/scenes/desk_lever.vmdl" then
        thisEntity:FireOutput("OnCompletionB", nil, nil, nil, 0)
    elseif name ~= "plug_console_starter_lever" then
        if name == "track_switch_lever" then
            count = 0.35
            player:SetThink(function()
                if player:Attribute_GetIntValue("use_released", 0) == 1 then
                    SendToConsole("ent_fire track_switch_lever SetCompletionValue 0.35 0")
                    SendToConsole("ent_fire train_switch_reset_relay Trigger 0 0")
                    if player:Attribute_GetIntValue("released_train_lever_once", 0) == 0 then
                        SendToConsole("ent_fire train_switch_control_override_0 Cancel")
                        SendToConsole("ent_fire train_switch_control_override_10 Start")
                        player:Attribute_SetIntValue("released_train_lever_once", 1)
                    end
                else
                    return 0
                end
            end, "", 0)
            SendToConsole("ent_fire traincar_01_hackplug Alpha 0")
        elseif not vlua.find(name, "elev_anim_door") and not vlua.find(name, "tractor_beam_console_lever") then
            thisEntity:Attribute_SetIntValue("used", 1)
        end
    end

    if class == "item_health_station_charger" or class == "item_hlvr_combine_console_rack" then
        DoEntFireByInstanceHandle(thisEntity, "EnableOnlyRunForward", "", 0, nil, nil)
    end

    local is_console = class == "prop_animinteractable" and model == "models/props_combine/combine_consoles/vr_console_rack_1.vmdl"
    if name == "" then
        thisEntity:SetEntityName("" .. thisEntity:GetEntityIndex())
    end
    thisEntity:SetThink(function()
        if not is_console then
            DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "" .. count, 0, nil, nil)
        end

        if map == "a3_distillery" and name == "verticaldoor_wheel" then
            count = count + 0.001
        elseif name == "12712_shotgun_wheel" then
            count = count + 0.003
        elseif name == "console_selector_interact" then
            count = count + 0.0005
        else
            count = count + 0.01
        end

        if is_console then
            DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "" .. count, 0, nil, nil)
        end

        if name == "12712_shotgun_wheel" then
            DoEntFireByInstanceHandle(thisEntity, "DisableReturnToCompletion", "", 0, nil, nil)
            SendToConsole("ent_fire_output " .. thisEntity:GetName() .. " Position " .. count / 2)
        end

        if model == "models/interaction/anim_interact/hand_crank_wheel/hand_crank_wheel.vmdl" then
            SendToConsole("ent_fire_output " .. thisEntity:GetName() .. " Position " .. count)
        end

        if name == "track_switch_lever" and player:Attribute_GetIntValue("use_released", 0) == 1 then
            return nil
        end

        if vlua.find(name, "elev_anim_door") then
            DoEntFireByInstanceHandle(thisEntity, "DisableReturnToCompletion", "", 0, nil, nil)
        end

        if count >= 1 then
            thisEntity:FireOutput("OnCompletionA_Forward", nil, nil, nil, 0)
            if name == "barricade_door_hook" then
                SendToConsole("ent_fire barricade_door SetReturnToCompletionStyle 0")
            elseif name == "12712_shotgun_wheel" then
                local bar = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["model"]="models/props/misc_debris/vort_winch_pipe.vmdl", ["origin"]="711.395874 1319.248047 -168.302490", ["angles"]="0.087952 120.220528 90.588112"})
                bar = Entities:FindByName(nil, "12712_shotgun_bar_for_wheel")
                bar:Kill()
                SendToConsole("ent_remove shotgun_pickup_blocker")
            elseif name == "console_opener_prop_handle_interact" then
                SendToConsole("ent_fire_output console_opener_prop_handle_interact OnCompletionA")
                Entities:FindByName(nil, "console_selector_interact"):Attribute_SetIntValue("used", 0)
            elseif name == "console_selector_interact" then
                SendToConsole("ent_fire_output console_opener_logic_isselected_* ontrue")
            end
            return nil
        else
            return 0
        end
    end, "AnimateCompletionValue", 0)
elseif name == "589_panel_switch" or name == "5628_2901_barricade_door_hook" or (vlua.find(name, "elev_anim_door") and thisEntity:Attribute_GetIntValue("toggle", 0) == 0 and thisEntity:GetVelocity() == Vector(0, 0, 0)) then
    if not vlua.find(name, "elev_anim_door") then
        thisEntity:Attribute_SetIntValue("used", 1)
    end

    local count = 0
    thisEntity:SetThink(function()
        DoEntFireByInstanceHandle(thisEntity, "SetCompletionValue", "" .. 1 - count, 0, nil, nil)
        count = count + 0.01
        if count >= 1 then
            thisEntity:FireOutput("OnCompletionA_Backward", nil, nil, nil, 0)
            return nil
        else
            return 0
        end
    end, "AnimateCompletionValue", 0)
end

if vlua.find(model, "doorhandle") then
    local ent = Entities:FindByClassnameNearest("prop_door_rotating_physics", thisEntity:GetOrigin(), 60)
    DoEntFireByInstanceHandle(ent, "Use", "", 0, player, player)
end

if vlua.find(name, "socket") then
    local ent = Entities:FindByClassname(thisEntity, "prop_physics") 
    DoEntFireByInstanceHandle(ent, "RunScriptFile", "check_useextra_distance", 0, player, player)
end

if class == "prop_ragdoll" or class == "prop_ragdoll_attached" then
    for k, v in pairs(thisEntity:GetChildren()) do
        DoEntFireByInstanceHandle(v, "RunScriptFile", "useextra", 0, player, nil)
    end
end

if name == "falling_cabinet_door" then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,1000,0))
end

if name == "falling_cabinet_door" then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,1000,0))
end

if vlua.find(name, "_locker_door_") then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,5000))
elseif vlua.find(name, "_portaloo_door") then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-1500))
elseif vlua.find(name, "_hazmat_crate_lid") then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-5000,0))
elseif vlua.find(model, "electric_box_door") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,5000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-5000))
    end
elseif vlua.find(name, "_dumpster_lid") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,2000,0))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-800,0))
    end
elseif vlua.find(name, "_portaloo_seat") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-3000,0))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,2000,0))
    end
elseif vlua.find(name, "_drawer") then
    if vlua.find(model, "models/props/desk_1_drawer_") then
        if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
            thisEntity:ApplyAbsVelocityImpulse(-thisEntity:GetRightVector() * 100)
        else
            thisEntity:ApplyAbsVelocityImpulse(thisEntity:GetRightVector() * 100)
        end
    elseif vlua.find(model, "models/props/interior_furniture/interior_kitchen_drawer_") or (vlua.find(model, "models/props/interior_furniture/interior_furniture_cabinet_") and vlua.find(model, "drawer")) then
        if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
            thisEntity:ApplyAbsVelocityImpulse(thisEntity:GetRightVector() * 100)
        else
            thisEntity:ApplyAbsVelocityImpulse(-thisEntity:GetRightVector() * 100)
        end
    else
        if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
            thisEntity:ApplyAbsVelocityImpulse(-thisEntity:GetForwardVector() * 100)
        else
            thisEntity:ApplyAbsVelocityImpulse(thisEntity:GetForwardVector() * 100)
        end
    end
elseif vlua.find(name, "_trashbin02_lid") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,1000,0))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-3000,0))
    end
elseif vlua.find(name, "_car_door_rear") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,1500,0))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-2800,0))
    end
elseif vlua.find(name, "ticktacktoe_") then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,RandomInt(1000, 3000),0))
end

if model == "models/props/zoo/vet_cage_square.vmdl" then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
    end
end

if vlua.find(model, "models/props/interior_furniture/interior_kitchen_cabinet_") or vlua.find(model, "models/props/interior_furniture/interior_furniture_cabinet_") then
    if vlua.find(model, "002") then
        if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
            thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,2000,0))
        else
            thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,-2000,0))
        end
    else
        if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
            thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
        else
            thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
        end
    end
end

if vlua.find(name, "_wooden_board") then
    DoEntFireByInstanceHandle(thisEntity, "Break", "", 0, nil, nil)
end

if class == "prop_door_rotating_physics" and vlua.find(name, "padlock_door") then
    DoEntFireByInstanceHandle(thisEntity, "InteractStart", "", 0, nil, nil)
end

if vlua.find(model, "van_a0") then
    local name = thisEntity:GetName():gsub("_window", "")
    local ent = Entities:FindByName(nil, name)
    if ent then
        if thisEntity == ent then
            DoEntFireByInstanceHandle(ent, "Toggle", "", 0, nil, nil)
            if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
                thisEntity:ApplyAbsVelocityImpulse(-thisEntity:GetForwardVector() * 100)
            else
                thisEntity:ApplyAbsVelocityImpulse(thisEntity:GetForwardVector() * 100)
            end
        else
            DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
        end
    end
end

if vlua.find(model, "car_sedan_a0") then
    local name = thisEntity:GetName():gsub("_door", ""):gsub("car", "car_door"):gsub("_window", "")
    local ent = Entities:FindByName(nil, name)
    if ent then
        DoEntFireByInstanceHandle(ent, "Toggle", "", 0, nil, nil)
    end
end


---------- a1_intro_world ----------

if name == "microphone" or name == "call_button_prop" or model == "maps/a1_intro_world/entities/unnamed_205_2961_1020.vmdl" then
    SendToConsole("ent_fire call_button_relay trigger")
end

if name == "205_2653_door" or name == "205_2653_door2" or name == "205_8018_button_pusher_prop" then
    SendToConsole("ent_fire debug_roof_elevator_call_relay trigger")
end

if name == "205_8032_button_pusher_prop" then
    SendToConsole("ent_fire debug_elevator_relay trigger")
end

if model == "models/props/eli_manor/antique_globe01a.vmdl" then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,1000))
end

if model == "models/props/interactive/washing_machine01a_door.vmdl" then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
    end
end

if model == "models/props/interactive/washing_machine01a_loader.vmdl" then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyAbsVelocityImpulse(-thisEntity:GetForwardVector() * 100)
    else
        thisEntity:ApplyAbsVelocityImpulse(thisEntity:GetForwardVector() * 100)
    end
end

if name == "door_named_for_audio_ent_02" then
    DoEntFireByInstanceHandle(thisEntity, "InteractStart", "", 0, nil, nil)
end

if vlua.find(model, "models/props/c17/antenna01") then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
end

if name == "979_518_button_pusher_prop" then
    SendToConsole("ent_fire debug_choreo_start_relay trigger")
end


---------- a1_intro_world_2 ----------

if name == "russell_headset" then
    SendToConsole("ent_fire debug_relay_put_on_headphones trigger")
    SendToConsole("ent_fire 4962_car_door_left_front close")
end

if name == "carousel" then
    SendToConsole("+attack")
    player:SetThink(function()
        SendToConsole("-attack")
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-500))
    end, "SpinCarousel", 0)
end

if vlua.find(name, "mailbox") and vlua.find(model, "door") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2500))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2500))
    end
end

if name == "russell_entry_window" then
    SendToConsole("fadein 0.2")
    SendToConsole("ent_fire russell_entry_window SetCompletionValue 1")
    SendToConsole("setpos -1728 275 100")
end

if vlua.find(model, "models/props/interior_furniture/interior_furniture_cabinet_002_door_") then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
    end
end

if model == "models/props/fridge_1a_door2.vmdl" or model == "models/props/fridge_1a_door.vmdl" then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-2000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
    end
end

if name == "621_6487_button_pusher_prop" then
    SendToConsole("ent_fire 621_6487_button_branch test")
end

if name == "glove_dispenser_brush" then
    SendToConsole("ent_fire relay_give_gravity_gloves trigger")
    SendToConsole("hidehud 1")
    Entities:GetLocalPlayer():Attribute_SetIntValue("gravity_gloves", 1)
end


---------- a2_pistol ----------

if model == "models/props/distillery/firebox_1_door_a.vmdl" then
    thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,2000))
end


---------- a3_c17_processing_plant ----------

if name == "vent_door" then
    if thisEntity:Attribute_GetIntValue("toggle", 0) == 0 then
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,-1000))
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(0,0,1000))
    end
end


---------- a3_distillery ----------

if name == "cellar_ladder" then
    ClimbLadderSound()
    SendToConsole("ent_fire cellar_ladder SetCompletionValue 1")
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact 1004 1775 546")
end

if name == "larry_ladder" then
    ClimbLadderSound()
    SendToConsole("ent_fire larry_ladder SetCompletionValue 1")
    SendToConsole("fadein 0.2")
    SendToConsole("ent_fire relay_debug_intro_trench trigger")
end


---------- a4_c17_parking_garage ----------

if name == "toner_sliding_ladder" then
    ClimbLadderSound()
    SendToConsole("ent_fire toner_sliding_ladder SetCompletionValue 1")
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact -367 -416 150")
end


---------- Other ----------

if name == "prop_crowbar" then
    thisEntity:Kill()
end

if name == "l_candler" or name == "r_candler" then
    SendToConsole("ent_fire innervault_energize_event_relay Kill")
    SendToConsole("ent_fire_output g_release_hand1 OnHandPosed")
    SendToConsole("ent_fire_output g_release_hand2 OnHandPosed")
    SendToConsole("ent_fire player_speedmod ModifySpeed 0")
    SendToConsole("hidehud 4")
end

if name == "combine_gun_mechanical" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    SendToConsole("ent_fire player_speedmod ModifySpeed 0")
    local angles = thisEntity:GetAngles()
    SendToConsole("ent_fire combine_gun_grab_handle SetParent combine_gun_mechanical")
    SendToConsole("ent_fire combine_gun_interact Alpha 0")
    SendToConsole("ent_fire combine_gun_mechanical SetParent !player")
    thisEntity:SetAngles(angles.x - 15, angles.y, angles.z)
    SendToConsole("bind " .. PRIMARY_ATTACK .. " \"ent_fire relay_shoot_gun trigger\"")
    SendToConsole("r_drawviewmodel 0")
    thisEntity:Attribute_SetIntValue("used", 1)
end

if name == "18918_5316_button_pusher_prop" then
    SendToConsole("ent_fire_output 18918_5316_button_center_pusher OnIn")
end

if name == "18918_5275_button_pusher_prop" then
    SendToConsole("ent_fire_output 18918_5275_button_center_pusher OnIn")
end

if name == "1489_4074_port_demux" then
    SendToConsole("ent_fire_output 1489_4074_path_demux_3_0 onpoweron")
    SendToConsole("ent_fire_output 1489_4074_path_demux_3_3 onpoweron")
    SendToConsole("ent_fire_output 1489_4074_path_demux_3_6 onpoweron")
end

if name == "bridge_crank" then
    SendToConsole("ent_fire driven_bridge SetPlaybackRate 1 1")
    SendToConsole("ent_fire drawbridge_brush Enable")
    local ent = Entities:FindByName(nil, "bridge_crank")
    ent:FireOutput("OnInteractStart", nil, nil, nil, 0)
    ent:FireOutput("OnInteractStop", nil, nil, nil, 2.8)
end

if name == "3_8223_prop_button" then
    SendToConsole("ent_fire_output 3_8223_handpose_combine_switchbox_button_press OnHandPosed")
end

if name == "3_8223_mesh_combine_switch_box" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    thisEntity:Attribute_SetIntValue("used", 1)
    SendToConsole("ent_fire_output 3_8223_switch_box_hack_plug OnHackSuccess")
end

if name == "589_test_outlet" then
    SendToConsole("ent_fire 589_vertical_door Open")
    SendToConsole("ent_fire_output 589_path_11 OnPowerOn")
end

if class == "item_combine_tank_locker" then
    if thisEntity:GetCycle() <= 0.5 then
        DoEntFireByInstanceHandle(thisEntity, "PlayAnimation", "combine_locker_standing", 0, nil, nil)

        ent = Entities:FindByClassname(nil, "item_hlvr_combine_console_tank")
        while ent do
            if ent:GetMoveParent() then
                DoEntFireByInstanceHandle(ent, "EnablePickup", "", 0, nil, nil)
            end
            ent = Entities:FindByClassname(ent, "item_hlvr_combine_console_tank")
        end
    end
end

if class == "item_hlvr_weapon_shotgun" then
    SendToConsole("give weapon_shotgun")
    SendToConsole("ent_fire 12712_relay_player_shotgun_is_ready Trigger")
    SendToConsole("ent_fire item_hlvr_weapon_shotgun Kill")
end

if class == "item_hlvr_weapon_rapidfire" then
    SendToConsole("give weapon_ar2")
    if map == "a3_hotel_interior_rooftop" then
        local ents = Entities:FindAllByClassnameWithin("item_hlvr_clip_rapidfire", thisEntity:GetCenter(), 10)
        for k, v in pairs(ents) do
            DoEntFireByInstanceHandle(v, "RunScriptFile", "useextra", 0, player, nil)
        end
    end
    SendToConsole("ent_fire item_hlvr_weapon_rapidfire Kill")
end

if class == "prop_dynamic" then
    if model == "models/props_combine/health_charger/combine_health_charger_vr_pad.vmdl" then
        local ent = Entities:FindByClassnameNearest("item_health_station_charger", thisEntity:GetOrigin(), 20)
        DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
        ent = Entities:FindByClassnameNearest("item_healthcharger_internals", thisEntity:GetOrigin(), 20)
        if ent:GetSequence() == "idle_deployed" and tostring(thisEntity:GetMaterialGroupMask()) == "5" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
            if player:GetHealth() == player:GetMaxHealth() then
                StartSoundEvent("HealthStation.Deny", player)
            else
                if map == "a2_quarantine_entrance" then
                    SendToConsole("ent_fire_output health_station OnHealingPlayerStart")
                end
                StartSoundEvent("HealthStation.Start", player)
                SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                thisEntity:Attribute_SetIntValue("used", 1)
                thisEntity:SetThink(function()
                    if player:GetHealth() < player:GetMaxHealth() then
                        StartSoundEvent("HealthStation.Loop", player)
                    end
                end, "Loop", .7)
                thisEntity:SetThink(function()
                    if player:GetHealth() < player:GetMaxHealth() then
                        player:SetHealth(player:GetHealth() + 1)
                        return 0.1
                    else
                        if map == "a2_quarantine_entrance" then
                            SendToConsole("ent_fire_output health_station OnHealingPlayerStop")
                        end
                        StopSoundEvent("HealthStation.Loop", player)
                        StartSoundEvent("HealthStation.Complete", player)
                        SendToConsole("ent_fire player_speedmod ModifySpeed 1")
                        thisEntity:Attribute_SetIntValue("used", 0)
                    end
                end, "Heal", 0)
            end
        end
    elseif model == "models/props/alyx_hideout/button_plate.vmdl" then
        SendToConsole("ent_fire 2_8127_elev_button_test_floor_" .. player:Attribute_GetIntValue("next_elevator_floor", 2) .. " Trigger")

        if player:Attribute_GetIntValue("next_elevator_floor", 2) == 2 then
            player:Attribute_SetIntValue("next_elevator_floor", 1)
        else
            player:Attribute_SetIntValue("next_elevator_floor", 2)
        end
    elseif model == "models/props_combine/combine_doors/combine_door_sm01.vmdl" or model == "models/props_combine/combine_lockers/combine_locker_doors.vmdl" then
        local ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", thisEntity:GetCenter(), 40)

        if ent and ent:Attribute_GetIntValue("used", 0) == 0 then
			ent:Attribute_SetIntValue("used", 1)
            DoEntFireByInstanceHandle(ent, "BeginHack", "", 0, nil, nil)
            DoEntFireByInstanceHandle(ent, "EndHack", "", 1.8, nil, nil)
            ent:FireOutput("OnHackSuccess", nil, nil, nil, 1.8)
            ent:FireOutput("OnPuzzleSuccess", nil, nil, nil, 1.8)
        end
    end
end

if map == "a3_hotel_interior_rooftop" and name == "window_sliding1" then
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact 788 -1420 576")
    SendToConsole("-use")
    thisEntity:SetThink(function()
        SendToConsole("+use")
    end, "", 0)
end

if name == "2860_window_sliding1" then
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact 1437 -1422 140")
end

if map == "a3_station_street" then
    if name == "power_stake_1_start" then
        SendToConsole("ent_fire_output toner_path_alarm_1 OnPowerOn")
        SendToConsole("ent_fire toner_path_6_relay_debug Trigger")
    end
end

if name == "2_11128_cshield_station_prop_button" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    thisEntity:Attribute_SetIntValue("used", 1)
    SendToConsole("ent_fire 2_11128_cshield_station_relay_button_pressed Trigger")
end

if name == "2_11128_cshield_station_1" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    thisEntity:Attribute_SetIntValue("used", 1)
    SendToConsole("ent_fire_output 2_11128_cshield_station_hack_plug OnHackSuccess")
end

if name == "254_16189_combine_locker" then
    SendToConsole("ent_fire_output 254_16189_locker_hack_plug OnPuzzleSuccess")
    SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_2_40_92_white.vmdl", ["origin"]="-2018 -1828 216", ["angles"]="0 270 0", ["parentname"]="scanner_return_clip_door"})
    SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_2_40_92_white.vmdl", ["origin"]="-1888 -1744 216", ["angles"]="0 180 0", ["parentname"]="scanner_return_clip", ["modelscale"]=10})
end

if name == "2_203_elev_button_floor_1" then
    SendToConsole("ent_fire_output 2_203_elev_button_floor_1_handpose OnHandPosed")
end

if name == "2_203_inside_elevator_button" then
    SendToConsole("ent_fire_output 2_203_elev_button_elevator_handpose OnHandPosed")
end

if name == "inside_elevator_button" then
    SendToConsole("ent_fire_output elev_button_elevator_handpose OnHandPosed")
end

if name == "@pod_shell" or name == "pod_insides" then
    local ent = Entities:FindByName(nil, "@pod_shell")
    if ent:Attribute_GetIntValue("used", 0) == 0 then
        ent:Attribute_SetIntValue("used", 1)
        SendToConsole("ent_fire @pod_shell Unlock")
    end
end

if name == "ChoreoPhysProxy" then
    SendToConsole("ent_fire eli_fall_relay Trigger")
end

if name == "traincar_01_hatch" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    thisEntity:Attribute_SetIntValue("used", 1)
    SendToConsole("ent_fire_output traincar_01_hackplug OnHackSuccess")
end

if name == "5325_4704_toner_port_train_gate" then
    SendToConsole("ent_fire_output 5325_4704_train_gate_path_20_to_end OnPowerOn")
    SendToConsole("ent_fire_output 5325_4704_train_gate_path_22_to_end OnPowerOn")
end

if name == "270_trip_mine_item_1" then
    SendToConsole("ent_fire 270_trip_mine_item_1 deactivatemine")
end

if class == "prop_hlvr_crafting_station_console" then
    local function AnimTagListener(sTagName, nStatus)
        if sTagName == 'Bootup Done' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("crafting_station_ready", 1)
        elseif sTagName == 'Crafting Done' and nStatus == 2 then
            if Convars:GetStr("chosen_upgrade") == "pistol_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("pistol_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("ent_fire text_pistol_upgrade_aimdownsights ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_burstfire" then
                player:Attribute_SetIntValue("pistol_upgrade_burstfire", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("ent_fire text_pistol_upgrade_burstfire ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_grenadelauncher" then
                player:Attribute_SetIntValue("shotgun_upgrade_grenadelauncher", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("ent_fire text_shotgun_upgrade_grenadelauncher ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_doubleshot" then
                player:Attribute_SetIntValue("shotgun_upgrade_doubleshot", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("ent_fire text_shotgun_upgrade_doubleshot ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("smg_upgrade_aimdownsights", 1)
                if player:Attribute_GetIntValue("smg_upgrade_fasterfirerate", 0) == 0 then
                    SendToConsole("give weapon_ar2")
                else
                    SendToConsole("give weapon_smg1")
                end
                SendToConsole("ent_fire text_smg_upgrade_aimdownsights ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_fasterfirerate" then
                player:Attribute_SetIntValue("smg_upgrade_fasterfirerate", 1)
                SendToConsole("ent_remove weapon_ar2")
                SendToConsole("give weapon_smg1")
            end
            SendToConsole("ent_fire point_clientui_world_panel Enable")
            SendToConsole("ent_fire weapon_in_fabricator Kill")
            thisEntity:SetGraphParameterBool("bCrafting", false)
        elseif sTagName == 'Trays Retracted' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("cancel_cooldown_done", 1)
        end
    end

    thisEntity:RegisterAnimTagListener(AnimTagListener)

    if thisEntity:GetGraphParameter("bBootup") == false then
        local ent = Entities:FindByClassnameNearest("prop_hlvr_crafting_station", thisEntity:GetOrigin(), 20)
        DoEntFireByInstanceHandle(ent, "OpenStation", "", 0, nil, nil)
    elseif thisEntity:Attribute_GetIntValue("crafting_station_ready", 0) == 1 then
        if thisEntity:GetGraphParameter("bCollectingResin") then
            if Convars:GetStr("chosen_upgrade") ~= "" then
                if Convars:GetStr("chosen_upgrade") == "cancel" then
                    thisEntity:SetGraphParameterBool("bCrafting", false)
                    SendToConsole("ent_fire point_clientui_world_panel Enable")
                    thisEntity:Attribute_SetIntValue("cancel_cooldown_done", 0)
                else
                    SendToConsole("ent_fire upgrade_ui kill")
                    -- TODO: ent_create point_clientui_world_movie_panel {src_movie "file://{resources}/videos/wupgrade_frabrication.webm" targetname test width 200 height 100 }
                end
                thisEntity:SetGraphParameterBool("bCollectingResin", false)
            end
        elseif thisEntity:Attribute_GetIntValue("cancel_cooldown_done", 1) == 1 and thisEntity:GetGraphParameter("bCrafting") == false then
            local viewmodel = Entities:FindByClassname(nil, "viewmodel")
            if viewmodel then
                if viewmodel:GetModelName() == "models/weapons/v_pistol.vmdl" then
                    SendToConsole("ent_fire weapon_pistol kill 0.02")
                    SendToConsole("impulse 200")
                    Convars:SetStr("weapon_in_crafting_station", "pistol")
                    local console = Entities:FindByClassnameNearest("prop_hlvr_crafting_station_console", player:GetOrigin(), 100)
                    local ent = Entities:FindByClassnameNearest("trigger_crafting_station_object_placement", console:GetOrigin(), 40)
                    local angles = ent:GetAngles()
                    local origin = ent:GetCenter() - angles:Forward() * 1.5 - Vector(0,0,2.25)
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["targetname"]="weapon_in_fabricator", ["model"]="models/weapons/vr_alyxgun/vr_alyxgun.vmdl", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent:SetParent(console, "item_attach")
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["targetname"]="weapon_in_fabricator", ["model"]="models/weapons/vr_alyxgun/vr_alyxgun_slide_anim_interact.vmdl", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent:SetParent(console, "item_attach")

                    local ents = Entities:FindAllByClassname("point_clientui_world_panel")
                    DoEntFireByInstanceHandle(ents[1], "Disable", "", 0, nil, nil)
                    DoEntFireByInstanceHandle(ents[2], "Disable", "", 0, nil, nil)
                    local angles = ents[2]:GetAngles()
                    local origin = ents[2]:GetOrigin() + Vector(0,0,0.04)
                    ent = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {["panel_dpi"]=60, ["height"]=12, ["width"]=21, ["targetname"]="upgrade_ui", ["dialog_layout_name"]="file://{resources}/layout/custom_game/crafting_station_pistol.xml", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent.upgrade1 = function()
                        if player:Attribute_GetIntValue("pistol_upgrade_aimdownsights", 0) == 0 then
                            SendToConsole("chooseupgrade1")
                        end
                    end
                    ent.upgrade2 = function()
                        if player:Attribute_GetIntValue("pistol_upgrade_burstfire", 0) == 0 then
                            SendToConsole("chooseupgrade2")
                        end
                    end
                    ent.cancelupgrade = function()
                        SendToConsole("cancelupgrade")
                    end
                    ent:RedirectOutput("CustomOutput0", "upgrade1", ent)
                    ent:RedirectOutput("CustomOutput1", "upgrade2", ent)
                    ent:RedirectOutput("CustomOutput2", "cancelupgrade", ent)
                    SendToConsole("ent_fire upgrade_ui addcssclass HasObject")
                elseif viewmodel:GetModelName() == "models/weapons/v_shotgun.vmdl" then
                    SendToConsole("ent_fire weapon_shotgun kill 0.02")
                    SendToConsole("impulse 200")
                    Convars:SetStr("weapon_in_crafting_station", "shotgun")
                    local console = Entities:FindByClassnameNearest("prop_hlvr_crafting_station_console", player:GetOrigin(), 100)
                    local ent = Entities:FindByClassnameNearest("trigger_crafting_station_object_placement", console:GetOrigin(), 40)
                    local angles = ent:GetAngles()
                    local origin = ent:GetCenter() - angles:Forward() * 1.5 - Vector(0,0,2.25)
                    ent = SpawnEntityFromTableSynchronous("item_hlvr_weapon_shotgun", {["targetname"]="weapon_in_fabricator", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent:SetParent(console, "item_attach")

                    local ents = Entities:FindAllByClassname("point_clientui_world_panel")
                    DoEntFireByInstanceHandle(ents[1], "Disable", "", 0, nil, nil)
                    DoEntFireByInstanceHandle(ents[2], "Disable", "", 0, nil, nil)
                    local angles = ents[2]:GetAngles()
                    local origin = ents[2]:GetOrigin() + Vector(0,0,0.04)
                    ent = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {["panel_dpi"]=60, ["height"]=12, ["width"]=21, ["targetname"]="upgrade_ui", ["dialog_layout_name"]="file://{resources}/layout/custom_game/crafting_station_shotgun.xml", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent.upgrade1 = function()
                        if player:Attribute_GetIntValue("shotgun_upgrade_doubleshot", 0) == 0 then
                            SendToConsole("chooseupgrade1")
                        end
                    end
                    ent.upgrade2 = function()
                        if player:Attribute_GetIntValue("shotgun_upgrade_grenadelauncher", 0) == 0 then
                            SendToConsole("chooseupgrade2")
                        end
                    end
                    ent.cancelupgrade = function()
                        SendToConsole("cancelupgrade")
                    end
                    ent:RedirectOutput("CustomOutput0", "upgrade1", ent)
                    ent:RedirectOutput("CustomOutput1", "upgrade2", ent)
                    ent:RedirectOutput("CustomOutput2", "cancelupgrade", ent)
                    SendToConsole("ent_fire upgrade_ui addcssclass HasObject")
                elseif viewmodel:GetModelName() == "models/weapons/v_smg1.vmdl" then
                    if player:Attribute_GetIntValue("smg_upgrade_fasterfirerate", 0) == 0 then
                        SendToConsole("ent_fire weapon_ar2 kill 0.02")
                    else
                        SendToConsole("ent_fire weapon_smg1 kill 0.02")
                    end
                    SendToConsole("impulse 200")
                    Convars:SetStr("weapon_in_crafting_station", "smg")
                    local console = Entities:FindByClassnameNearest("prop_hlvr_crafting_station_console", player:GetOrigin(), 100)
                    local ent = Entities:FindByClassnameNearest("trigger_crafting_station_object_placement", console:GetOrigin(), 40)
                    local angles = ent:GetAngles()
                    local origin = ent:GetCenter() - angles:Forward() * 1.5 - Vector(0,0,2.25)
                    ent = SpawnEntityFromTableSynchronous("item_hlvr_weapon_rapidfire", {["targetname"]="weapon_in_fabricator", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent:SetParent(console, "item_attach")

                    local ents = Entities:FindAllByClassname("point_clientui_world_panel")
                    DoEntFireByInstanceHandle(ents[1], "Disable", "", 0, nil, nil)
                    DoEntFireByInstanceHandle(ents[2], "Disable", "", 0, nil, nil)
                    local angles = ents[2]:GetAngles()
                    local origin = ents[2]:GetOrigin() + Vector(0,0,0.04)
                    ent = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {["panel_dpi"]=60, ["height"]=12, ["width"]=21, ["targetname"]="upgrade_ui", ["dialog_layout_name"]="file://{resources}/layout/custom_game/crafting_station_smg.xml", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z })
                    ent.upgrade1 = function()
                        if player:Attribute_GetIntValue("smg_upgrade_aimdownsights", 0) == 0 then
                            SendToConsole("chooseupgrade1")
                        end
                    end
                    ent.upgrade2 = function()
                        if player:Attribute_GetIntValue("smg_upgrade_fasterfirerate", 0) == 0 then
                            SendToConsole("chooseupgrade2")
                        end
                    end
                    ent.cancelupgrade = function()
                        SendToConsole("cancelupgrade")
                    end
                    ent:RedirectOutput("CustomOutput0", "upgrade1", ent)
                    ent:RedirectOutput("CustomOutput1", "upgrade2", ent)
                    ent:RedirectOutput("CustomOutput2", "cancelupgrade", ent)
                    SendToConsole("ent_fire upgrade_ui addcssclass HasObject")
                else
                    return
                end
                thisEntity:SetGraphParameterBool("bCollectingResin", true)
                thisEntity:SetGraphParameterBool("bCrafting", true)
                thisEntity:Attribute_GetIntValue("crafting_station_ready", 0)
            end
        end
        if thisEntity:GetGraphParameter("bCrafting") == false then
            Convars:SetStr("chosen_upgrade", "")
        end
    end
end

if class == "item_hlvr_combine_console_tank" then
    if thisEntity:GetMoveParent() then
        DoEntFireByInstanceHandle(thisEntity, "ClearParent", "", 0, nil, nil)
    else
        thisEntity:ApplyLocalAngularVelocityImpulse(Vector(200,0,0))
    end
end

if name == "room1_lights_circuitbreaker_switch" then
    SendToConsole("ent_fire_output controlroom_circuitbreaker_relay ontrigger")
end

if map == "a4_c17_parking_garage" then
    if name == "toner_port" then
        SendToConsole("ent_fire_output toner_path_2 OnPowerOn")
        SendToConsole("ent_fire_output toner_path_8 OnPowerOn")
    end
end

if map == "a2_train_yard" then
    if is_combine_console_locked() == false then
        local ent = Entities:FindByName(nil, "5325_3947_combine_console")
        DoEntFireByInstanceHandle(ent, "RackOpening", "1", 0, thisEntity, thisEntity)
    end
end

if map == "a2_headcrabs_tunnel" then
    if name == "flashlight" then
        SendToConsole("ent_fire_output flashlight OnAttachedToHand")
        SendToConsole("bind " .. FLASHLIGHT .. " inv_flashlight")
        player:Attribute_SetIntValue("has_flashlight", 1)
        SendToConsole("ent_remove flashlight")
    end
end

if map == "a2_quarantine_entrance" then
    if is_combine_console_locked() == false then
        local ent = Entities:FindByName(nil, "17670_combine_console")
        DoEntFireByInstanceHandle(ent, "RackOpening", "1", 0, thisEntity, thisEntity)
    end
    
    if name == "27788_combine_locker" then
        SendToConsole("ent_fire_output 27788_locker_hack_plug OnHackSuccess")
    end
end

if map == "a3_hotel_lobby_basement" then
    if name == "power_stake_1_start" and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
        SendToConsole("ent_fire_output power_logic_enable_lights OnTrigger")
        SendToConsole("ent_fire_output toner_path_11 OnPowerOn")
        player:Attribute_SetIntValue("EnabledHotelLobbyPower", 1)
    end
end

if name == "plug_console_starter_lever" then
    if map == "a4_c17_tanker_yard" then
        if thisEntity:Attribute_GetIntValue("used", 0) == 1 then
            return
        end

        thisEntity:Attribute_SetIntValue("used", 1)
    end

    SendToConsole("ent_fire_output plug_console_starter_lever OnCompletionB_Forward")
end

if GetMapName() == "a3_distillery" then
    if name == "11578_2635_380_button_center" then
        SendToConsole("ent_fire_output 11578_2635_380_button_center_pusher onin")
    end

    if name == "intro_rollup_door" then
        SendToConsole("ent_fire_output intro_rollup_door oncompletiona_forward")
        SendToConsole("ent_fire door_xen_crust break")
        SendToConsole("ent_fire relay_door_xen_crust_c trigger")
        SendToConsole("ent_fire relay_door_xen_crust_d trigger")
        SendToConsole("ent_fire relay_door_xen_crust_e trigger")
    end

    if name == "barricade_door" then
        SendToConsole("ent_fire barricade_door setreturntocompletionamount 1")
    end

    if name == "tc_door_control" then
        SendToConsole("ent_fire tc_door_control setcompletionvalue 0")
        SendToConsole("ent_fire relay_close_compactor_doors trigger")
    end

    if name == "11478_6233_tutorial_wheel" then
        SendToConsole("ent_fire 11478_6233_verticaldoor_wheel_tutorial open")
    end

    if name == "verticaldoor_wheel" then
        SendToConsole("ent_fire @verticaldoor setspeed 10")
        SendToConsole("ent_fire @verticaldoor open")
    end

    if name == "11479_2385_button_pusher_prop" then
        SendToConsole("ent_fire_output 11479_2385_button_center_pusher onin")
    end

    if name == "11479_2386_button_pusher_prop" then
        SendToConsole("ent_fire_output 11479_2386_button_center_pusher onin")
    end

    if name == "freezer_toner_outlet_1" then
        SendToConsole("ent_fire_output freezer_toner_path_3 onpoweron")
        SendToConsole("ent_fire_output freezer_toner_path_6 onpoweron")
        SendToConsole("ent_remove debug_teleport_player_freezer_door")
        SendToConsole("ent_fire relay_debug_freezer_breakout trigger")
    end

    if name == "freezer_toner_outlet_2" then
        SendToConsole("ent_fire_output freezer_toner_path_7 onpoweron")
    end

    if name == "freezer_port_b_2" then
        SendToConsole("ent_fire_output freezer_toner_path_8 onpoweron")
    end

    if name == "11578_2420_181_antlion_plug_crank_a" then
        SendToConsole("ent_fire_output 11578_2420_181_antlion_plug_crank_a oncompletionc_forward")
    end

    if name == "11578_2420_183_antlion_plug_crank_a" then
        SendToConsole("ent_fire_output 11578_2420_183_antlion_plug_crank_a oncompletionc_forward")
    end

    if name == "antlion_plug_crank_c" then
        SendToConsole("ent_fire_output antlion_plug_crank_c oncompletionc_forward")
    end
end

if name == "lift_button_box" then
    if thisEntity:Attribute_GetIntValue("used", 0) == 1 then
        SendToConsole("ent_fire_output lift_button_down onin")
        thisEntity:Attribute_SetIntValue("used", 0)
    else
        SendToConsole("ent_fire_output lift_button_up onin")
        thisEntity:Attribute_SetIntValue("used", 1)
    end
end

if name == "1517_3301_lift_prop_animated" then
    SendToConsole("ent_fire_output lift_button_down onin")
end

if name == "shack_path_6_port_1" then
    SendToConsole("ent_fire_output pallet_panel_power_on ontrigger")
end

if name == "pallet_lever_vertical" then
    SendToConsole("ent_fire_output pallet_logic_phys_raise ontrigger")
end

if name == "pallet_lever" then
    SendToConsole("ent_fire_output pallet_logic_extend ontrigger")
end

if class == "item_hlvr_headcrab_gland" then
    SendToConsole("ent_fire achievement_squeeze_heart FireEvent")
end

if class == "baseanimating" and vlua.find(name, "Console") and thisEntity:Attribute_GetIntValue("used", 0) == 0 then
    thisEntity:Attribute_SetIntValue("used", 1)
    SendToConsole("ent_fire_output *_console_hacking_plug OnHackSuccess")
    local ents = Entities:FindAllByClassnameWithin("item_hlvr_combine_console_tank", thisEntity:GetCenter(), 20)
    for k, v in pairs(ents) do
        DoEntFireByInstanceHandle(v, "DisablePickup", "", 0, player, nil)
    end
    SendToConsole("ent_fire 5325_3947_combine_console AddOutput OnTankAdded>item_hlvr_combine_console_tank>DisablePickup>>0>1")
end

if class == "item_hlvr_grenade_xen" then
    thisEntity:SetThink(function()
        if GetPhysVelocity(thisEntity):Length() > 200 then
            DoEntFireByInstanceHandle(thisEntity, "ArmGrenade", "", 0, nil, nil)
        else
            return 0
        end
    end, "ArmOnHighVelocity", 0.1)
end

if class == "prop_reviver_heart" then
    player:SetContextNum("player_picked_up_heart", 1, 10)
end

local item_pickup_params = { ["userid"]=player:GetUserID(), ["item"]=class, ["item_name"]=name }

if vlua.find(class, "item_hlvr_crafting_currency_") then
    if name == "currency_booby_trap" then
        thisEntity:FireOutput("OnPlayerPickup", nil, nil, nil, 0)
    end

    FireGameEvent("item_pickup", item_pickup_params)
    if vlua.find(class, "large") then
        SendToConsole("hlvr_addresources 0 0 0 5")
    else
        SendToConsole("hlvr_addresources 0 0 0 1")
    end
    StartSoundEventFromPosition("Inventory.BackpackGrabItemResin", player:EyePosition())
    
    -- Show resin count
    player:SetThink(function()
        local t = {}
        player:GatherCriteria(t)
        local ent = Entities:FindByName(nil, "text_resin")
        DoEntFireByInstanceHandle(ent, "SetText", "Resin: " .. t.current_crafting_currency, 0, nil, nil)
        DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
    end, "", 0.02)

    thisEntity:Kill()
elseif class == "item_hlvr_clip_energygun" then
    FireGameEvent("item_pickup", item_pickup_params)
    if name == "pistol_clip_1" then
        SendToConsole("ent_remove weapon_bugbait")
        SendToConsole("give weapon_pistol")
        SendToConsole("ent_fire_output ammo_insert_listener OnEventFired")
        player:SetThink(function()
            SendToConsole("ent_fire text_shoot ShowMessage")
            SendToConsole("play sounds/ui/beepclear.vsnd")
        end, "ShowShootTutorial", 4)
    else
        SendToConsole("hlvr_addresources 10 0 0 0")
    end
    StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    viewmodel:RemoveEffects(32)
    thisEntity:Kill()
elseif class == "item_hlvr_clip_energygun_multiple" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 40 0 0 0")
    StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    viewmodel:RemoveEffects(32)
    thisEntity:Kill()
elseif class == "item_hlvr_clip_shotgun_multiple" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 0 0 4 0")
    StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    viewmodel:RemoveEffects(32)
    thisEntity:Kill()
elseif class == "item_hlvr_clip_shotgun_single" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 0 0 1 0")
    StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    viewmodel:RemoveEffects(32)
    thisEntity:Kill()
elseif class == "item_hlvr_clip_rapidfire" then
    FireGameEvent("item_pickup", item_pickup_params)
    SendToConsole("hlvr_addresources 0 30 0 0")
    StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    viewmodel:RemoveEffects(32)
    thisEntity:Kill()
elseif class == "item_hlvr_grenade_frag" then
    if thisEntity:GetSequence() == "vr_grenade_unarmed_idle" then
        FireGameEvent("item_pickup", item_pickup_params)
        StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
        SendToConsole("give weapon_frag")
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        viewmodel:RemoveEffects(32)
        thisEntity:Kill()
    end
elseif class == "item_healthvial" then
    if player:GetHealth() < player:GetMaxHealth() then
        player:SetContextNum("used_health_pen", 1, 10)
        player:SetHealth(min(player:GetHealth() + cvar_getf("hlvr_health_vial_amount"), player:GetMaxHealth()))
        FireGameEvent("item_pickup", item_pickup_params)
        StartSoundEventFromPosition("HealthPen.Stab", player:EyePosition())
        StartSoundEventFromPosition("HealthPen.Success01", player:EyePosition())
        StartSoundEventFromPosition("HealthPen.Success02", player:EyePosition())
        thisEntity:Kill()
    end
end
