local map = GetMapName()
local name = thisEntity:GetName()
local class = thisEntity:GetClassname()
local model = thisEntity:GetModelName()
local player = Entities:GetLocalPlayer()

if thisEntity:Attribute_GetIntValue("junction_rotation", 0) == 3 then
    thisEntity:Attribute_SetIntValue("junction_rotation", 0)
else
    thisEntity:Attribute_SetIntValue("junction_rotation", thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1)
end

-- First Path in the Puzzle
local toner_start_path
-- Last/Success Path
local toner_end_path
-- example_toner_path = {"leads_to_this_junction", point1, point2, point3, ...}
local toner_paths
-- example_toner_junction = {type (0=straight, 1=right angle, 2=two right angles, 3=static T), position, "activated_toner_path_1", "activated_toner_path_2", "activated_toner_path_3", "activated_toner_path_4"}
local toner_junctions

if map == "a2_quarantine_entrance" then
    toner_start_path = "toner_path_1"
    toner_end_path = "toner_path_5"

    toner_paths = {
        toner_path_1 = {"toner_junction_1", Vector(-912.1, 1150.47, 100), Vector(-912.1, 1115, 100)},
        toner_path_2 = {"toner_junction_2", Vector(-912.1, 1109, 100), Vector(-912.1, 1099, 100), Vector(-912.1, 1099, 108.658), Vector(-912.1, 1088.1, 108.658), Vector(-926, 1088.1, 108.658)},
        toner_path_3 = {"", Vector(-929, 1088.1, 111.658), Vector(-929, 1088.1, 144), Vector(-946, 1088.1, 144)},
        toner_path_5 = {"", Vector(-973, 1088.1, 98.4348), Vector(-986, 1088.1, 98.4348)},
        toner_path_7 = {"toner_junction_3", Vector(-929, 1088.1, 105.658), Vector(-929, 1088.1, 98.4348), Vector(-947, 1088.1, 98.4348), Vector(-947, 1088.1, 69.5763), Vector(-947, 1088.1, 98.4348), Vector(-967, 1088.1, 98.4348)},
    }

    toner_junctions = {
        toner_junction_1 = {0, Vector(-912.1, 1112, 100), "toner_path_2", "", "toner_path_2", ""},
        toner_junction_2 = {1, Vector(-929, 1088.1, 108.658), "toner_path_3", "toner_path_7", "", ""},
        toner_junction_3 = {0, Vector(-970, 1088.1, 98.4348), "toner_path_5", "", "toner_path_5", ""},
    }
elseif map == "a2_headcrabs_tunnel" then
    toner_start_path = "toner_path_1"
    toner_end_path = ""

    toner_paths = {
        toner_path_1 = {"toner_junction_1", Vector(-440.082, -591.641, 10.1066), Vector(-453.538, -583.872, 10.1066)},
        toner_path_2 = {"", Vector(-456.077, -582.406, 7.1066), Vector(-456.077, -582.406, 1.25), Vector(-492.011, -561.866, 1.25), Vector(-508.747, -590.854, 1.25)},
        toner_path_3 = {"toner_junction_2", Vector(-456.077, -582.406, 13.1066), Vector(-456.077, -582.406, 20.25), Vector(-489.012, -563.389, 20.25), Vector(-507.848, -589.466, 20.25), Vector(-563.691, -557.735, 20.25), Vector(-563.471, -557.356, 3.5)},
        toner_path_5 = {"", Vector(-566.054, -555.864, 0.5), Vector(-591.523, -541.157, 0.5), Vector(-583.348, -527.429, 0.5), Vector(-612.043, -511.988, 3.5)},
        toner_path_6 = {"", Vector(-561.36, -558.574, 0.5), Vector(-551.359, -564.352, 0.5), Vector(-518.847, -584.56, 0.5)},
        toner_path_8 = {"", Vector(), Vector()},
    }

    toner_junctions = {
        toner_junction_1 = {2, Vector(-456.077, -582.406, 10.1066), "toner_path_3", "toner_path_2", "toner_path_3", "toner_path_2"},
        toner_junction_2 = {2, Vector(-563.471, -557.356, 0.5), "toner_path_6", "toner_path_5", "toner_path_6", "toner_path_5"},
        --toner_junction_i = {0, Vector(), "toner_path_8", "", "toner_path_8", ""},
    }
end

function DrawTonerPath(toner_path)
    for i = 3, #toner_path do
        DebugDrawLine(toner_path[i - 1], toner_path[i], 0, 0, 255, false, -1)
    end
end

function DrawTonerJunction(junction, center, angles)
    local type = junction[1]

    if type == 0 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    elseif type == 1 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    elseif type == 2 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    end
end

function ToggleTonerJunction()
    local junction = toner_junctions[thisEntity:GetName()]

    if junction then
        DebugDrawClear()
        for toner_path_name, toner_path in pairs(toner_paths) do
            DrawTonerPath(toner_path)
        end

        local angles = thisEntity:GetAngles()
        StartSoundEventFromPosition("Toner.JunctionRotate", player:EyePosition())

        local new_index = thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1
        local old_index = new_index - 1
        if old_index == 0 then
            old_index = 4
        end

        local ent = Entities:FindByClassname(nil, "info_hlvr_toner_path")
        while ent do
            ent:FireOutput("OnPowerOff", nil, nil, nil, 0)
            ent = Entities:FindByClassname(ent, "info_hlvr_toner_path")
        end

        local toner_path = toner_start_path
        while toner_path ~= "" do
            local junction_name = toner_paths[toner_path][1]
            local junction_entity = Entities:FindByName(nil, junction_name)
            if junction_entity then
                local activated_path = junction_entity:Attribute_GetIntValue("junction_rotation", 0) + 3
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
            DrawTonerJunction(junction, junction[2], angles)
        end
    end
end

if class == "info_hlvr_toner_port" and (thisEntity:Attribute_GetIntValue("used", 0) == 0 or thisEntity:Attribute_GetIntValue("redraw_toner", 0) == 1) then
    DoEntFireByInstanceHandle(thisEntity, "OnPlugRotated", "", 0, nil, nil)
    DebugDrawClear()
    if toner_junctions then
        for junction_name, junction in pairs(toner_junctions) do
            local junction_entity = Entities:FindByName(nil, junction_name)
            local angles = junction_entity:GetAngles()
            angles = QAngle(angles.x, angles.y, junction_entity:Attribute_GetIntValue("junction_rotation", 0) * 90)
            DrawTonerJunction(junction, junction[2], angles)
        end
        for toner_path_name, toner_path in pairs(toner_paths) do
            DrawTonerPath(toner_path)
        end
    end

    if thisEntity:Attribute_GetIntValue("redraw_toner", 0) == 0 then
        if name == "5325_4704_toner_port_train_gate" then
            SendToConsole("ent_fire_output 5325_4704_train_gate_path_20_to_end OnPowerOn")
            SendToConsole("ent_fire_output 5325_4704_train_gate_path_22_to_end OnPowerOn")
        end

        if map == "a3_station_street" and name == "power_stake_1_start" then
            SendToConsole("ent_fire_output toner_path_alarm_1 OnPowerOn")
            SendToConsole("ent_fire toner_path_6_relay_debug Trigger")
        end

        if map == "a3_hotel_lobby_basement" and name == "power_stake_1_start" then
            SendToConsole("ent_fire_output power_logic_enable_lights OnTrigger")
            SendToConsole("ent_fire_output toner_path_11 OnPowerOn")
            player:Attribute_SetIntValue("EnabledHotelLobbyPower", 1)
        end

        if map == "a3_hotel_street" and name == "power_stake_1_start" then
            SendToConsole("ent_fire_output toner_path_11 onpoweron")
        end

        if map == "a3_c17_processing_plant" and name == "shack_path_6_port_1" then
            DoEntFireByInstanceHandle(thisEntity, "Disable", "", 0, nil, nil)
            -- TODO: Remove once puzzle implemented
            SendToConsole("ent_fire_output shack_path_5 OnPowerOn")
        end

        if map == "a3_distillery" then
            if name == "freezer_toner_outlet_1" then
                SendToConsole("ent_fire_output barricade_door OnCompletionA_Backward")
                SendToConsole("ent_fire_output freezer_toner_path_3 OnPowerOn")
                SendToConsole("ent_fire_output freezer_toner_path_6 OnPowerOn")
                SendToConsole("ent_remove debug_teleport_player_freezer_door")
                SendToConsole("ent_fire relay_debug_freezer_breakout Trigger")
            end

            if name == "freezer_toner_outlet_2" then
                SendToConsole("ent_fire_output freezer_toner_path_7 OnPowerOn")
                -- TODO: Remove once puzzle implemented
                SendToConsole("ent_fire_output freezer_toner_path_8 OnPowerOn 0 0 5")
            end
        end

        if map == "a4_c17_zoo" and name == "589_test_outlet" then
            SendToConsole("ent_fire_output 589_path_unlock_door OnPowerOn")
            SendToConsole("ent_fire_output 589_path_11 OnPowerOn")
        end

        if map == "a4_c17_tanker_yard" and name == "1489_4074_port_demux" then
            SendToConsole("ent_fire_output 1489_4074_path_demux_3_0 onpoweron")
            SendToConsole("ent_fire_output 1489_4074_path_demux_3_3 onpoweron")
            SendToConsole("ent_fire_output 1489_4074_path_demux_3_6 onpoweron")
        end

        if map == "a4_c17_parking_garage" then
            if name == "toner_port" then
                SendToConsole("ent_fire_output toner_path_2 OnPowerOn")
                Entities:FindByName(nil, "falling_cabinet_door"):ApplyLocalAngularVelocityImpulse(Vector(0, 1200, 0))
            elseif name == "toner_port_2" then
                SendToConsole("ent_fire_output toner_path_5 OnPowerOn")
            elseif name == "toner_port_3" then
                SendToConsole("ent_fire_output toner_path_8 OnPowerOn")
                if Entities:FindByName(nil, "door_reset"):GetCycle() >= 0.99 then
                    SendToConsole("ent_fire_output door_reset OnCompletionA_Forward")
                end
            end
        end
    end

    thisEntity:Attribute_SetIntValue("used", 1)
    thisEntity:Attribute_SetIntValue("redraw_toner", 0)
end

if class == "info_hlvr_toner_junction" and toner_start_path ~= nil and player:Attribute_GetIntValue("circuit_" .. map .. "_" .. toner_start_path .. "_completed", 0) == 0 then
    ToggleTonerJunction()
end

if model == "models/props_combine/combine_doors/combine_door_sm01.vmdl" or model == "models/props_combine/combine_lockers/combine_locker_doors.vmdl" then
    if thisEntity:GetSequence() == "open_idle" then
        return
    end

    local ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", thisEntity:GetCenter(), 40)

    if ent and ent:Attribute_GetIntValue("used", 0) == 0 then
        ent:Attribute_SetIntValue("used", 1)
        DoEntFireByInstanceHandle(ent, "BeginHack", "", 0, nil, nil)
        DoEntFireByInstanceHandle(ent, "EndHack", "", 1.8, nil, nil)
        ent:FireOutput("OnHackSuccess", nil, nil, nil, 1.8)
        ent:FireOutput("OnPuzzleSuccess", nil, nil, nil, 1.8)
    end
end

-- Combine Fabricator
if class == "prop_hlvr_crafting_station_console" then
    local function AnimTagListener(sTagName, nStatus)
        if sTagName == 'Bootup Done' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("crafting_station_ready", 1)
        elseif sTagName == 'Crafting Done' and nStatus == 2 then
            if Convars:GetStr("chosen_upgrade") == "pistol_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("pistol_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_aimdownsights ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_burstfire" then
                player:Attribute_SetIntValue("pistol_upgrade_burstfire", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_burstfire ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_hopper" then
                player:Attribute_SetIntValue("pistol_upgrade_hopper", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_lasersight" then
                player:Attribute_SetIntValue("pistol_upgrade_lasersight", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not work yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_grenadelauncher" then
                player:Attribute_SetIntValue("shotgun_upgrade_grenadelauncher", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_grenadelauncher ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_doubleshot" then
                player:Attribute_SetIntValue("shotgun_upgrade_doubleshot", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_doubleshot ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_lasersight" then
                player:Attribute_SetIntValue("shotgun_upgrade_lasersight", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not work yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_hopper" then
                player:Attribute_SetIntValue("shotgun_upgrade_hopper", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("smg_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_smg_upgrade_aimdownsights ShowMessage")
                SendToConsole("play sounds/ui/beepclear.vsnd")
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_lasersight" then
                player:Attribute_SetIntValue("smg_upgrade_lasersight", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not work yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_casing" then
                player:Attribute_SetIntValue("smg_upgrade_casing", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            end

            SendToConsole("ent_fire point_clientui_world_panel Enable")
            SendToConsole("ent_fire weapon_in_fabricator Kill")
            thisEntity:SetGraphParameterBool("bCrafting", false)
            Convars:SetStr("chosen_upgrade", "")
            Convars:SetStr("weapon_in_crafting_station", "")
        elseif sTagName == 'Trays Retracted' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("cancel_cooldown_done", 1)
        end
    end

    thisEntity:RegisterAnimTagListener(AnimTagListener)
end
