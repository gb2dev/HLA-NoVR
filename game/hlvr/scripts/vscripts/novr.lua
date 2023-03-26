if player_hurt_ev ~= nil then
    StopListeningToGameEvent(player_hurt_ev)
end

player_hurt_ev = ListenToGameEvent('player_hurt', function(info)
    -- Hack to stop pausing the game on death
    if info.health == 0 then
        SendToConsole("reload")
        SendToConsole("r_drawvgui 0")
    end

    -- Kill on fall damage
    if GetPhysVelocity(Entities:GetLocalPlayer()).z < -450 then
        SendToConsole("ent_fire !player SetHealth 0")
    end
end, nil)

if entity_killed_ev ~= nil then
    StopListeningToGameEvent(entity_killed_ev)
end

entity_killed_ev = ListenToGameEvent('entity_killed', function(info)
    local player = Entities:GetLocalPlayer()
    player:SetThink(function()
        function GibBecomeRagdoll(classname)
            ent = Entities:FindByClassname(nil, classname)
            while ent do
                if vlua.find(ent:GetModelName(), "models/creatures/headcrab_classic/headcrab_classic_gib") then
                    DoEntFireByInstanceHandle(ent, "BecomeRagdoll", "", 0.01, nil, nil)
                end
                ent = Entities:FindByClassname(ent, classname)
            end
        end

        GibBecomeRagdoll("prop_physics")
        GibBecomeRagdoll("prop_ragdoll")
        return nil
    end, "", 0)
end, nil)

if changelevel_ev ~= nil then
    StopListeningToGameEvent(changelevel_ev)
end

changelevel_ev = ListenToGameEvent('change_level_activated', function(info)
    SendToConsole("r_drawvgui 0")
end, nil)

if pickup_ev ~= nil then
    StopListeningToGameEvent(pickup_ev)
end

pickup_ev = ListenToGameEvent('physgun_pickup', function(info)
    local ent = EntIndexToHScript(info.entindex)
    ent:Attribute_SetIntValue("picked_up", 1)
    DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
end, nil)

Convars:RegisterCommand("useextra", function()
    local player = Entities:GetLocalPlayer()
    if not player:IsUsePressed() then
        DoEntFire("!picker", "RunScriptFile", "check_useextra_distance", 0, nil, nil)
        DoEntFire("!picker", "FireUser4", "", 0, nil, nil)

        if GetMapName() == "a3_hotel_interior_rooftop" then
            if vlua.find(Entities:FindAllInSphere(Vector(2381, -1841, 448), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact 2339 -1839 560")
            elseif vlua.find(Entities:FindAllInSphere(Vector(2345, -1834, 758), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact 2345 -1834 840")
            end
        end

        if GetMapName() == "a3_hotel_lobby_basement" and vlua.find(Entities:FindAllInSphere(Vector(976, -1467, 208), 20), player) then
            SendToConsole("fadein 0.2")
            SendToConsole("setpos_exact 975 -1507 280")
        end

        if GetMapName() == "a2_headcrabs_tunnel" and vlua.find(Entities:FindAllInSphere(Vector(347,-242,-63), 20), player) then
            SendToConsole("fadein 0.2")
            SendToConsole("setpos_exact 347 -297 2")
        end

        if GetMapName() == "a2_hideout" then
            local startVector = player:EyePosition()
            local traceTable =
            {
                startpos = startVector;
                endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(100, 0, 0));
                ignore = player;
                mask =  33636363
            }
        
            TraceLine(traceTable)
        
            if traceTable.hit 
            then
                local ent = Entities:FindByClassnameNearest("func_physical_button", traceTable.pos, 10)
                if ent then
                    ent:FireOutput("OnIn", nil, nil, nil, 0)
                    StartSoundEventFromPosition("Button_Basic.Press", player:EyePosition())
                end
            end
        end

        if GetMapName() == "a3_c17_processing_plant" then
            if vlua.find(Entities:FindAllInSphere(Vector(-80, -2215, 760), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact -26 -2215 870")
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-240,-2875,392), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact -241 -2823 410")
            end

            if vlua.find(Entities:FindAllInSphere(Vector(414,-2459,328), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact 365 -2465 410")
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-1392,-2471,115), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact -1415 -2485 410")
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-1420,-2482,472), 20), player) then
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact -1392 -2471 53")
            end
        end
    end
end, "", 0)

if player_spawn_ev ~= nil then
    StopListeningToGameEvent(player_spawn_ev)
end

player_spawn_ev = ListenToGameEvent('player_activate', function(info)
	if not IsServer() then return end

    local ent

    if GetMapName() == "startup" then
        SendToConsole("sv_cheats 1")
        SendToConsole("hidehud 4")
        SendToConsole("mouse_disableinput 1")
        SendToConsole("bind MOUSE1 +use")
        ent = Entities:FindByClassname(ent, "player_speedmod")
        if not ent then
            SpawnEntityFromTableSynchronous("player_speedmod", nil)
            SendToConsole("ent_fire player_speedmod ModifySpeed 0")
        else
            GoToMainMenu()
        end
        ent = Entities:FindByName(nil, "startup_relay")
        ent:RedirectOutput("OnTrigger", "GoToMainMenu", ent)
    else
        SendToConsole("binddefaults")
        SendToConsole("bind space jumpfixed")
        SendToConsole("bind e \"+use;useextra\"")
        SendToConsole("bind v noclip")
        SendToConsole("bind ctrl +crouch")
        SendToConsole("bind F5 \"save quick\"")
        SendToConsole("bind F9 \"load quick\"")
        SendToConsole("bind M \"map startup\"")
        SendToConsole("bind MOUSE2 \"\"")
        SendToConsole("cl_forwardspeed 60;cl_backspeed 60;cl_sidespeed 60")
        SendToConsole("alias -crouch \"-duck;cl_forwardspeed 60;cl_backspeed 60;cl_sidespeed 60\"")
        SendToConsole("alias +crouch \"+duck;cl_forwardspeed 80;cl_backspeed 80;cl_sidespeed 80\"")
        SendToConsole("hl2_sprintspeed 160")
        SendToConsole("hl2_normspeed 160")
        SendToConsole("r_drawviewmodel 0")
        SendToConsole("fov_desired 90")
        SendToConsole("sv_infinite_aux_power 1")
        SendToConsole("cc_spectator_only 1")
        SendToConsole("sv_gameinstructor_disable 1")
        SendToConsole("hud_draw_fixed_reticle 0")
        SendToConsole("r_drawvgui 1")
        SendToConsole("ent_fire *_locker_door_* DisablePickup")
        SendToConsole("ent_fire *_hazmat_crate_lid DisablePickup")
        SendToConsole("ent_fire electrical_panel_*_door* DisablePickup")
        SendToConsole("ent_remove player_flashlight")
        SendToConsole("hl_headcrab_deliberate_miss_chance 0")
        SendToConsole("headcrab_powered_ragdoll 0")
        SendToConsole("combine_grenade_timer 4")
        SendToConsole("sk_max_grenade 1")
        SendToConsole("sv_gravity 500")

        ent = Entities:FindByClassname(nil, "item_healthcharger_reservoir")
        while ent do
            SpawnEntityFromTableSynchronous("func_healthcharger", {["targetname"]="healthcharger_" .. ent:entindex()})
            DoEntFireByInstanceHandle(ent, "SetParent", "healthcharger_" .. ent:entindex(), 0, nil, nil)
            ent = Entities:FindByClassname(ent, "item_healthcharger_reservoir")
        end

        if GetMapName() == "a1_intro_world" then
            ent = Entities:FindByClassname(ent, "player_speedmod")
            if not ent then
                SpawnEntityFromTableSynchronous("player_speedmod", nil)
                SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                SendToConsole("mouse_disableinput 1")
                SendToConsole("give weapon_bugbait")
                SendToConsole("hidehud 4")
            else
                MoveFreely()
            end

            ent = Entities:FindByName(nil, "relay_teleported_to_refuge")
            ent:RedirectOutput("OnTrigger", "MoveFreely", ent)

            ent = Entities:FindByName(nil, "microphone")
            ent:RedirectOutput("OnUser4", "AcceptEliCall", ent)

            ent = Entities:FindByName(nil, "greenhouse_door")
            ent:RedirectOutput("OnUser4", "OpenGreenhouseDoor", ent)

            ent = Entities:FindByName(nil, "205_2653_door")
            ent:RedirectOutput("OnUser4", "OpenElevator", ent)
            ent = Entities:FindByName(nil, "205_2653_door2")
            ent:RedirectOutput("OnUser4", "OpenElevator", ent)
            ent = Entities:FindByName(nil, "205_8018_button_pusher_prop")
            ent:RedirectOutput("OnUser4", "OpenElevator", ent)

            ent = Entities:FindByName(nil, "205_8032_button_pusher_prop")
            ent:RedirectOutput("OnUser4", "RideElevator", ent)

            ent = Entities:FindByName(nil, "563_vent_door")
            ent:RedirectOutput("OnUser4", "EnterCombineElevator", ent)

            ent = Entities:FindByName(nil, "979_518_button_pusher_prop")
            ent:RedirectOutput("OnUser4", "OpenCombineElevator", ent)
        elseif GetMapName() == "a1_intro_world_2" then
            SendToConsole("give weapon_bugbait")
            SendToConsole("hidehud 96")

            ent = Entities:FindByName(nil, "hint_crouch_trigger")
            ent:RedirectOutput("OnStartTouch", "GetOutOfCrashedVan", ent)
            
            ent = Entities:FindByName(nil, "spawner_scanner")
            ent:RedirectOutput("OnEntitySpawned", "RedirectHeadset", ent)

            ent = Entities:FindByName(nil, "4962_car_door_left_front")
            ent:RedirectOutput("OnUser4", "ToggleCarDoor", ent)

            ent = Entities:FindByName(nil, "balcony_ladder")
            ent:RedirectOutput("OnUser4", "ClimbBalconyLadder", ent)

            ent = Entities:FindByName(nil, "russell_entry_window")
            ent:RedirectOutput("OnUser4", "OpenRussellWindow", ent)

            ent = Entities:FindByName(nil, "621_6487_button_pusher_prop")
            ent:RedirectOutput("OnUser4", "OpenRussellDoor", ent)

            SendToConsole("ent_fire gg_training_start_trigger kill")

            ent = Entities:FindByName(nil, "glove_dispenser_brush")
            ent:RedirectOutput("OnUser4", "EquipGravityGloves", ent)

            ent = Entities:FindByName(nil, "trigger_heli_flyby2")
            ent:RedirectOutput("OnTrigger", "GivePistol", ent)

            ent = Entities:FindByName(nil, "relay_weapon_pistol_fakefire")
            ent:RedirectOutput("OnTrigger", "RedirectPistol", ent)
        else
            SendToConsole("hidehud 64")
            SendToConsole("give weapon_pistol")
            SendToConsole("r_drawviewmodel 1")

            if GetMapName() == "a2_quarantine_entrance" then
                SendToConsole("ent_fire puzzle_crate kill")
                ent = SpawnEntityFromTableSynchronous("prop_physics", {["collisiongroupoverride"]=0, ["model"]="models/props/plastic_container_1.vmdl", ["origin"]="-2080 2775 247"})
                EntFireByHandle(nil, ent, "skin", "4")
                EntFireByHandle(nil, ent, "color", "135 173 159")
                EntFireByHandle(nil, ent, "setmass", "30")
            elseif GetMapName() == "a2_pistol" then
                SendToConsole("ent_fire *_rebar EnablePickup")
            elseif GetMapName() == "a2_headcrabs_tunnel" then
                ent = Entities:GetLocalPlayer()
                if ent:Attribute_GetIntValue("has_flashlight", 0) == 1 then
                    SendToConsole("bind F inv_flashlight")
                end
            elseif GetMapName() ~= "a2_hideout" then
                SendToConsole("bind F inv_flashlight")
                SendToConsole("give weapon_shotgun")

                if GetMapName() == "a3_hotel_interior_rooftop" then
                    SendToConsole("ent_create npc_headcrab_runner { origin \"1657 -1949 710\" }")
                elseif GetMapName() == "a3_hotel_street" then
                    SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")
                    ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(775, 1677, 248), 10)
                    if ent then
                        ent:Kill()
                    end
                    ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(1440, 1306, 331), 10)
                    if ent then
                        ent:Kill()
                    end
                elseif GetMapName() == "a3_c17_processing_plant" then
                    SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")
                    ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-896, -3768, 348), 10)
                    if ent then
                        ent:Kill()
                    end
                    ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-1165, -3770, 158), 10)
                    if ent then
                        ent:Kill()
                    end
                    ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-1105, -4058, 163), 10)
                    if ent then
                        ent:Kill()
                    end
                end
            end
        end
    end
end, nil)

function GoToMainMenu(a, b)
    SendToConsole("setpos_exact 805 -80 -26")
    SendToConsole("setang_exact -5 0 0")
    SendToConsole("mouse_disableinput 0")
    SendToConsole("hidehud 96")
end

function MoveFreely(a, b)
    SendToConsole("mouse_disableinput 0")
    SendToConsole("ent_fire player_speedmod ModifySpeed 1")
    SendToConsole("hidehud 96")
end

function AcceptEliCall(a, b)
    SendToConsole("ent_fire call_button_relay trigger")
end

function OpenGreenhouseDoor(a, b)
    local ent = Entities:FindByName(nil, "greenhouse_door")
    if string.format("%.2f", ent:GetCycle()) == "0.05" then
        SendToConsole("ent_fire greenhouse_door playanimation alyx_door_open")
    end
end

function OpenElevator(a, b)
    SendToConsole("ent_fire debug_roof_elevator_call_relay trigger")
end

function RideElevator(a, b)
    SendToConsole("ent_fire debug_elevator_relay trigger")
end

function EnterCombineElevator(a, b)
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact 574 -2328 -115")
    SendToConsole("ent_setpos 581 540.885 -2331.526 -71.911")
end

function OpenCombineElevator(a, b)
    SendToConsole("ent_fire debug_choreo_start_relay trigger")
end

function GetOutOfCrashedVan(a, b)
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact -1408 2307 -104")
    SendToConsole("ent_fire 4962_car_door_left_front open")
end

function RedirectHeadset(a, b)
    local ent = Entities:FindByName(nil, "russell_headset")
    ent:RedirectOutput("OnUser4", "EquipHeadset", ent)
end

function EquipHeadset(a, b)
    SendToConsole("ent_fire debug_relay_put_on_headphones trigger")
    SendToConsole("ent_fire 4962_car_door_left_front close")
end

function ToggleCarDoor(a, b)
    SendToConsole("ent_fire 4962_car_door_left_front toggle")
end

function ClimbBalconyLadder(a, b)
    SendToConsole("fadein 0.2")
    SendToConsole("setpos_exact -1296 576 80")
end

function OpenRussellWindow(a, b)
    SendToConsole("fadein 0.2")
    SendToConsole("ent_fire russell_entry_window setcompletionvalue 1")
    SendToConsole("setpos -1728 275 100")
end

function OpenRussellDoor(a, b)
    SendToConsole("ent_fire 621_6487_button_branch test")
end

function EquipGravityGloves(a, b)
    SendToConsole("ent_fire relay_give_gravity_gloves trigger")
    SendToConsole("hidehud 1")
end

function RedirectPistol(a, b)
    ent = Entities:FindByName(nil, "weapon_pistol")
    ent:RedirectOutput("OnUser4", "EquipPistol", ent)
end

function GivePistol(a, b)
    SendToConsole("ent_fire pistol_give_relay trigger")
end

function EquipPistol(a, b)
    SendToConsole("ent_fire_output weapon_equip_listener oneventfired")
    SendToConsole("hidehud 64")
    SendToConsole("r_drawviewmodel 1")
    SendToConsole("ent_fire item_hlvr_weapon_energygun kill")
end
