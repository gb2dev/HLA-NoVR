if GlobalSys:CommandLineCheck("-novr") then
    DoIncludeScript("flashlight.lua", nil)
    DoIncludeScript("jumpfix.lua", nil)

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
                    if vlua.find(ent:GetModelName(), "models/creatures/headcrab_classic/headcrab_classic_gib") or vlua.find(ent:GetModelName(), "models/creatures/headcrab_armored/armored_hc_gib") then
                        DoEntFireByInstanceHandle(ent, "BecomeRagdoll", "", 0.01, nil, nil)
                    end
                    ent = Entities:FindByClassname(ent, classname)
                end
            end

            GibBecomeRagdoll("prop_physics")
            GibBecomeRagdoll("prop_ragdoll")
        end, "GibBecomeRagdoll", 0)

        local ent = EntIndexToHScript(info.entindex_killed):GetChildren()[1]
        if ent and ent:GetClassname() == "weapon_smg1" then
            ent:SetThink(function()
                if ent:GetMoveParent() then
                    return 0
                else
                    DoEntFireByInstanceHandle(ent, "BecomeRagdoll", "", 0.02, nil, nil)
                end
            end, "BecomeRagdollWhenNoParent", 0)
        end
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
        ent:SetThink(function()
            ent:Attribute_SetIntValue("picked_up", 0)
        end, "", 0.35)
        DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
    end, nil)

    Convars:RegisterConvar("chosen_upgrade", "", "", 0)

    Convars:RegisterConvar("weapon_in_crafting_station", "", "", 0)

    Convars:RegisterCommand("chooseupgrade1", function()
        local t = {}
        Entities:GetLocalPlayer():GatherCriteria(t)

        if t.current_crafting_currency >= 10 then
            if Convars:GetStr("weapon_in_crafting_station") == "pistol" then
                Convars:SetStr("chosen_upgrade", "pistol_upgrade_aimdownsights")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -10")
            elseif Convars:GetStr("weapon_in_crafting_station") == "shotgun" then
                Convars:SetStr("chosen_upgrade", "shotgun_upgrade_doubleshot")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -10")
            elseif Convars:GetStr("weapon_in_crafting_station") == "smg" then
                Convars:SetStr("chosen_upgrade", "smg_upgrade_aimdownsights")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -10")
            end
        else
            SendToConsole("ent_fire text_resin SetText #HLVR_CraftingStation_NotEnoughResin")
            SendToConsole("ent_fire text_resin Display")
            SendToConsole("play sounds/common/wpn_denyselect.vsnd")
            SendToConsole("cancelupgrade")
        end
    end, "", 0)

    Convars:RegisterCommand("chooseupgrade2", function()
        local t = {}
        Entities:GetLocalPlayer():GatherCriteria(t)

        if t.current_crafting_currency >= 20 then
            if Convars:GetStr("weapon_in_crafting_station") == "pistol" then
                Convars:SetStr("chosen_upgrade", "pistol_upgrade_burstfire")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -20")
            elseif Convars:GetStr("weapon_in_crafting_station") == "shotgun" then
                Convars:SetStr("chosen_upgrade", "shotgun_upgrade_grenadelauncher")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -20")
            elseif Convars:GetStr("weapon_in_crafting_station") == "smg" then
                Convars:SetStr("chosen_upgrade", "smg_upgrade_fasterfirerate")
                SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
                SendToConsole("hlvr_addresources 0 0 0 -20")
            end
        else
            SendToConsole("ent_fire text_resin SetText #HLVR_CraftingStation_NotEnoughResin")
            SendToConsole("ent_fire text_resin Display")
            SendToConsole("play sounds/common/wpn_denyselect.vsnd")
            SendToConsole("cancelupgrade")
        end
    end, "", 0)

    Convars:RegisterCommand("cancelupgrade", function()
        Convars:SetStr("chosen_upgrade", "cancel")
        -- TODO: Give weapon back, but don't fill magazine
        if Convars:GetStr("weapon_in_crafting_station") == "pistol" then
            SendToConsole("give weapon_pistol")
        elseif Convars:GetStr("weapon_in_crafting_station") == "shotgun" then
            SendToConsole("give weapon_shotgun")
        elseif Convars:GetStr("weapon_in_crafting_station") == "smg" then
            if Entities:GetLocalPlayer():Attribute_SetIntValue("smg_upgrade_fasterfirerate", 0) == 0 then
                SendToConsole("give weapon_ar2")
            else
                SendToConsole("give weapon_smg1")
            end
        end
        SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
    end, "", 0)


    -- Custom attack

    Convars:RegisterCommand("+customattack", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        if viewmodel then
            if viewmodel:GetModelName() == "models/grenade.vmdl" then
                SendToConsole("+attack2")
                Entities:GetLocalPlayer():SetThink(function()
                    SendToConsole("-attack2")
                end, "StopAttack", 0.02)
                Entities:GetLocalPlayer():SetThink(function()
                    SendToConsole("+attack")
                end, "StartAttack2", 0.06)
                Entities:GetLocalPlayer():SetThink(function()
                    SendToConsole("-attack")
                end, "StopAttack2", 0.08)
            else
                SendToConsole("+attack")
                if viewmodel:GetModelName() == "models/pistol.vmdl" then
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("-attack")
                    end, "StopAttack", 0.1)
                end
            end
        end
    end, "", 0)

    Convars:RegisterCommand("-customattack", function()
        SendToConsole("-attack")
        SendToConsole("-attack2")
    end, "", 0)


    -- Custom attack 2

    Convars:RegisterCommand("+customattack2", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        local player = Entities:GetLocalPlayer()
        if viewmodel and viewmodel:GetModelName() ~= "models/grenade.vmdl" then
            if viewmodel:GetModelName() == "models/shotgun.vmdl" then
                if player:Attribute_GetIntValue("shotgun_upgrade_doubleshot", 0) == 1 then
                    SendToConsole("+attack2")
                end
            elseif viewmodel:GetModelName() == "models/pistol.vmdl" then
                if player:Attribute_GetIntValue("pistol_upgrade_aimdownsights", 0) == 1 then
                    SendToConsole("toggle_zoom")
                end
            elseif viewmodel:GetModelName() == "models/smg.vmdl" then
                if player:Attribute_GetIntValue("smg_upgrade_aimdownsights", 0) == 1 then
                    SendToConsole("toggle_zoom")
                end
            end
        end
    end, "", 0)

    Convars:RegisterCommand("-customattack2", function()
        SendToConsole("-attack")
        SendToConsole("-attack2")
    end, "", 0)


    -- Custom attack 3

    Convars:RegisterCommand("+customattack3", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        local player = Entities:GetLocalPlayer()
        if viewmodel then
            if viewmodel:GetModelName() == "models/shotgun.vmdl" then
                if player:Attribute_GetIntValue("shotgun_upgrade_grenadelauncher", 0) == 1 then
                    SendToConsole("use weapon_frag")
                    SendToConsole("+attack")
                    SendToConsole("ent_fire weapon_frag hideweapon")
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("-attack")
                    end, "StopAttack", 0.36)
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("use weapon_shotgun")
                    end, "BackToShotgun", 0.66)
                end
            elseif viewmodel:GetModelName() == "models/pistol.vmdl" then
                if player:Attribute_GetIntValue("pistol_upgrade_burstfire", 0) == 1 then
                    SendToConsole("sk_plr_dmg_pistol 7")
                    SendToConsole("+attack")
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("-attack")
                    end, "StopAttack", 0.02)
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("+attack")
                    end, "StartAttack2", 0.14)
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("-attack")
                    end, "StopAttack2", 0.16)
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("+attack")
                    end, "StartAttack3", 0.28)
                    Entities:GetLocalPlayer():SetThink(function()
                        SendToConsole("-attack")
                        SendToConsole("sk_plr_dmg_pistol 5")
                    end, "StopAttack3", 0.3)
                end
            end
        end
    end, "", 0)

    Convars:RegisterCommand("-customattack3", function()
    end, "", 0)


    Convars:RegisterCommand("shootadvisorvortenergy", function()
        local ent = SpawnEntityFromTableSynchronous("env_explosion", {["origin"]="886 -4111.625 -1188.75", ["explosion_type"]="custom", ["explosion_custom_effect"]="particles/vortigaunt_fx/vort_beam_explosion_i_big.vpcf"})
        DoEntFireByInstanceHandle(ent, "Explode", "", 0, nil, nil)
        StartSoundEventFromPosition("VortMagic.Throw", Vector(886, -4111.625, -1188.75))
        SendToConsole("bind MOUSE1 \"\"")
        SendToConsole("ent_fire relay_advisor_dead Trigger")
    end, "", 0)

    Convars:RegisterCommand("shootvortenergy", function()
        local player = Entities:GetLocalPlayer()
        local startVector = player:EyePosition()
        local traceTable =
        {
            startpos = startVector;
            endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(1000000, 0, 0));
            ignore = player;
            mask =  33636363
        }

        TraceLine(traceTable)

        if traceTable.hit then
            ent = SpawnEntityFromTableSynchronous("env_explosion", {["origin"]=traceTable.pos.x .. " " .. traceTable.pos.y .. " " .. traceTable.pos.z, ["explosion_type"]="custom", ["explosion_custom_effect"]="particles/vortigaunt_fx/vort_beam_explosion_i_big.vpcf"})
            DoEntFireByInstanceHandle(ent, "Explode", "", 0, nil, nil)
            SendToConsole("npc_kill")
            DoEntFire("!picker", "RunScriptFile", "vortenergyhit", 0, nil, nil)
            StartSoundEventFromPosition("VortMagic.Throw", startVector)
            local vortEnergyCell = Entities:FindByClassnameNearest("point_vort_energy", Vector(traceTable.pos.x,traceTable.pos.y,traceTable.pos.z), 15)
            if vortEnergyCell then
                vortEnergyCell:FireOutput("OnEnergyPulled", nil, nil, nil, 0)
            end
        end
    end, "", 0)

    Convars:RegisterCommand("useextra", function()
        local player = Entities:GetLocalPlayer()

        if not player:IsUsePressed() then
            DoEntFire("!picker", "RunScriptFile", "check_useextra_distance", 0, nil, nil)
            -- TODO: Remove this old method
            DoEntFire("!picker", "FireUser4", "", 0, nil, nil)

            if GetMapName() == "a5_vault" then
                if vlua.find(Entities:FindAllInSphere(Vector(-468, 2902, -519), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos -486 2908 -420")
                end
            end

            if GetMapName() == "a4_c17_parking_garage" then
                ent = Entities:FindByName(nil, "toner_sliding_ladder")
                ent:RedirectOutput("OnUser4", "ClimbGarageLadder", ent)
            end

            if GetMapName() == "a4_c17_water_tower" then
                if vlua.find(Entities:FindAllInSphere(Vector(3314, 6048, 64), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 3276 6048 142")
                elseif vlua.find(Entities:FindAllInSphere(Vector(2374, 6207, -177), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 2342 6257 -153")
                elseif vlua.find(Entities:FindAllInSphere(Vector(2432, 6662, 160), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 2431 6715 310")
                elseif vlua.find(Entities:FindAllInSphere(Vector(2848, 6130, 384), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 2850 6186 550")
                end
            end

            if GetMapName() == "a4_c17_tanker_yard" then
                if vlua.find(Entities:FindAllInSphere(Vector(6980, 2591, 13), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 6965 2600 261")
                elseif vlua.find(Entities:FindAllInSphere(Vector(6069, 3902, 416), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 6118 3903 686")
                elseif vlua.find(Entities:FindAllInSphere(Vector(5434, 5755, 273), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos 5450, 5714, 403")
                end
            end

            if GetMapName() == "a3_station_street" then
                if vlua.find(Entities:FindAllInSphere(Vector(934, 1883, -135), 20), player) then
                    SendToConsole("ent_fire_output 2_8127_elev_button_floor_1_call OnIn")
                end
            end

            if GetMapName() == "a3_hotel_interior_rooftop" then
                if vlua.find(Entities:FindAllInSphere(Vector(2381, -1841, 448), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 2339 -1839 560")
                elseif vlua.find(Entities:FindAllInSphere(Vector(2345, -1834, 758), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 2345 -1834 840")
                end
            end

            if GetMapName() == "a3_hotel_lobby_basement" then
                if vlua.find(Entities:FindAllInSphere(Vector(1059, -1475, 200), 20), player) then
                    SendToConsole("ent_fire_output elev_button_floor_1 OnIn")
                elseif vlua.find(Entities:FindAllInSphere(Vector(976, -1467, 208), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 975 -1507 280")
                end
            end

            if GetMapName() == "a2_headcrabs_tunnel" and vlua.find(Entities:FindAllInSphere(Vector(347,-242,-63), 20), player) then
                ClimbLadderSound()
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
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact -26 -2215 870")
                end

                if vlua.find(Entities:FindAllInSphere(Vector(-240,-2875,392), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact -241 -2823 410")
                end

                if vlua.find(Entities:FindAllInSphere(Vector(414,-2459,328), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 365 -2465 410")
                end

                if vlua.find(Entities:FindAllInSphere(Vector(-1392,-2471,115), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact -1415 -2485 410")
                end

                if vlua.find(Entities:FindAllInSphere(Vector(-1420,-2482,472), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact -1392 -2471 53")
                end
            end

            if GetMapName() == "a3_distillery" then
                if vlua.find(Entities:FindAllInSphere(Vector(20,-518,211), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 20 -471 452")
                end

                if vlua.find(Entities:FindAllInSphere(Vector(515,1595,578), 20), player) then
                    ClimbLadderSound()
                    SendToConsole("fadein 0.2")
                    SendToConsole("setpos_exact 577 1597 668")
                end

                ent = Entities:FindByName(nil, "cellar_ladder")
                ent:RedirectOutput("OnUser4", "ClimbCellarLadder", ent)

                ent = Entities:FindByName(nil, "larry_ladder")
                if ent then
                    ent:RedirectOutput("OnUser4", "ClimbLarryLadder", ent)
                end
            end
        end
    end, "", 0)

    if player_spawn_ev ~= nil then
        StopListeningToGameEvent(player_spawn_ev)
    end

    player_spawn_ev = ListenToGameEvent('player_activate', function(info)
        if not IsServer() then return end

        local loading_save_file = false
        local ent = Entities:FindByClassname(ent, "player_speedmod")
        if ent then
            loading_save_file = true
        else
            SpawnEntityFromTableSynchronous("player_speedmod", nil)
        end

        if GetMapName() == "startup" then
            SendToConsole("sv_cheats 1")
            SendToConsole("hidehud 4")
            SendToConsole("mouse_disableinput 1")
            SendToConsole("bind MOUSE1 +use")
            if not loading_save_file then
                SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                SendToConsole("setpos 0 -6154 6.473839")
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
            SendToConsole("bind ctrl +duck")
            SendToConsole("hl2_sprintspeed 140")
            SendToConsole("hl2_normspeed 140")
            SendToConsole("hl2_walkspeed 140")
            SendToConsole("bind F5 \"save quick;play sounds/ui/beepclear.vsnd;ent_fire text_quicksave showmessage\"")
            SendToConsole("bind F9 \"load quick\"")
            SendToConsole("bind M \"map startup\"")
            SendToConsole("bind MOUSE1 +customattack")
            SendToConsole("bind MOUSE2 +customattack2")
            SendToConsole("bind MOUSE3 +customattack3")
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
            SendToConsole("sk_max_grenade 9999")
            SendToConsole("sk_auto_reload_time 9999")
            SendToConsole("sv_gravity 500")
            SendToConsole("alias -covermouth \"ent_fire !player suppresscough 0;ent_fire_output @player_proxy onplayeruncovermouth;ent_fire lefthand disable;viewmodel_offset_y 0\"")
            SendToConsole("alias +covermouth \"ent_fire !player suppresscough 1;ent_fire_output @player_proxy onplayercovermouth;ent_fire lefthand enable;viewmodel_offset_y -20\"")
            SendToConsole("mouse_disableinput 0")
            SendToConsole("-attack")
            SendToConsole("-attack2")
            ent = Entities:GetLocalPlayer()
            if ent then
                local angles = ent:GetAngles()
                SendToConsole("setang " .. angles.x .. " " .. angles.y .. " 0")
                ent:SetThink(function()
                    if Entities:GetLocalPlayer():GetBoundingMaxs().z == 36 then
                        SendToConsole("cl_forwardspeed 80;cl_backspeed 80;cl_sidespeed 80")
                    else
                        SendToConsole("cl_forwardspeed 46;cl_backspeed 46;cl_sidespeed 46")
                    end
                    return 0
                end, "FixCrouchSpeed", 0)
            end

            SendToConsole("ent_remove text_quicksave")
            SendToConsole("ent_create env_message { targetname text_quicksave message GAMESAVED }")

            SendToConsole("ent_remove text_resin")
            -- TODO: Change holdtime to 3 when there is a proper weapon upgrade selection UI
            SendToConsole("ent_create game_text { targetname text_resin effect 2 spawnflags 1 color \"255 220 0\" color2 \"92 107 192\" fadein 0 fadeout 0.15 fxtime 0.25 holdtime 15 x 0.02 y -0.11 }")

            if GetMapName() == "a1_intro_world" then
                if not loading_save_file then
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
                if not loading_save_file then
                    ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER1_TITLE"})
                    DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                    SendToConsole("ent_create env_message { targetname text_crouchjump message CROUCHJUMP }")
                    SendToConsole("ent_create env_message { targetname text_sprint message SPRINT }")
                end

                SendToConsole("give weapon_bugbait")
                SendToConsole("hidehud 96")
                SendToConsole("combine_grenade_timer 7")

                if not loading_save_file then
                    ent = Entities:FindByName(nil, "trigger_post_gate")
                    ent:RedirectOutput("OnTrigger", "ShowSprintTutorial", ent)
                end

                ent = Entities:FindByName(nil, "scavenge_trigger")
                ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

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
                Entities:GetLocalPlayer():Attribute_SetIntValue("gravity_gloves", 1)

                if GetMapName() == "a2_quarantine_entrance" then
                    if not loading_save_file then
                        ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/plastic_container_1.vmdl", ["origin"]="-2100.494 2792.368 200.265", ["angles"]="0 -37.1 0", ["parentname"]="puzzle_crate"})

                        ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER2_TITLE"})
                        DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                        SendToConsole("setpos 3215 2456 465")
                        SendToConsole("ent_fire traincar_border_trigger Disable")
                    end
                elseif GetMapName() == "a2_pistol" then
                    SendToConsole("ent_fire *_rebar EnablePickup")
                elseif GetMapName() == "a2_headcrabs_tunnel" then
                    if not loading_save_file then
                        ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER3_TITLE"})
                        DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                    end

                    ent = Entities:GetLocalPlayer()
                    if ent:Attribute_GetIntValue("has_flashlight", 0) == 1 then
                        SendToConsole("bind F inv_flashlight")
                    end
                elseif GetMapName() ~= "a2_hideout" then
                    SendToConsole("bind F inv_flashlight")
                    SendToConsole("give weapon_shotgun")

                    if GetMapName() == "a2_drainage" then
                        SendToConsole("ent_fire wheel2_socket setscale 4")
                    elseif GetMapName() == "a3_hotel_interior_rooftop" then
                        ent = Entities:FindByClassname(nil, "npc_headcrab_runner")
                        if not ent then
                            SendToConsole("ent_create npc_headcrab_runner { origin \"1657 -1949 710\" }")
                        end
                    elseif GetMapName() == "a3_station_street" then
                        if not loading_save_file then
                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER4_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                        end
                    elseif GetMapName() == "a3_hotel_lobby_basement" then
                        if not loading_save_file then
                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER5_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                        end
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

                        if not loading_save_file then
                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER6_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                        end

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
                    elseif GetMapName() == "a3_distillery" then
                        SendToConsole("bind h +covermouth")

                        if not loading_save_file then
                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER7_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                            end

                            ent = Entities:FindByName(nil, "11578_2547_relay_koolaid_setup")
                            ent:RedirectOutput("OnTrigger", "FixJeffBatteryPuzzle", ent)

                            -- Hand for covering mouth animation
                            local viewmodel = Entities:FindByClassname(nil, "viewmodel")
                            local viewmodel_pos = viewmodel:GetAbsOrigin()
                            local viewmodel_ang = viewmodel:GetAngles()
                            ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="lefthand", ["model"]="models/hands/alyx_glove_left.vmdl", ["origin"]= viewmodel_pos.x - 24 .. " " .. viewmodel_pos.y .. " " .. viewmodel_pos.z - 4, ["angles"]= viewmodel_ang.x .. " " .. viewmodel_ang.y - 90 .. " " .. viewmodel_ang.z })
                            DoEntFire("lefthand", "SetParent", "!activator", 0, viewmodel, nil)
                            DoEntFire("lefthand", "Disable", "", 0, nil, nil)
                        end
                    else
                        SendToConsole("bind h \"\"")

                        if GetMapName() == "a4_c17_zoo" then
                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER8_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                            end

                            ent = Entities:FindByName(nil, "relay_power_receive")
                            ent:RedirectOutput("OnTrigger", "MakeLeverUsable", ent)

                            ent = Entities:FindByClassnameNearest("trigger_multiple", Vector(5380, -1848, -117), 10)
                            ent:RedirectOutput("OnStartTouch", "CrouchThroughZooHole", ent)

                            SendToConsole("ent_fire port_health_trap Disable")
                            SendToConsole("ent_fire health_trap_locked_door Unlock")
                            SendToConsole("ent_fire 589_toner_port_5 Disable")
                            SendToConsole("@prop_phys_portaloo_door DisablePickup")
                        elseif GetMapName() == "a4_c17_tanker_yard" then
                            SendToConsole("ent_fire elev_hurt_player_* Kill")

                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER9_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                            end
                        elseif GetMapName() == "a4_c17_water_tower" then
                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER10_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                            end
                        elseif GetMapName() == "a4_c17_parking_garage" then
                            SendToConsole("ent_fire falling_cabinet_door DisablePickup")

                            ent = Entities:FindByName(nil, "relay_ufo_beam_surge")
                            ent:RedirectOutput("OnTrigger", "UnequipCombinGunMechanical", ent)

                            ent = Entities:FindByName(nil, "relay_enter_ufo_beam")
                            ent:RedirectOutput("OnTrigger", "EnterVaultBeam", ent)
                        elseif GetMapName() == "a5_vault" then
                            SendToConsole("ent_fire player_speedmod ModifySpeed 1")
                            SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2")
                            SendToConsole("r_drawviewmodel 0")

                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER11_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                                SendToConsole("ent_create env_message { targetname text_vortenergy message VORTENERGY }")
                            end

                            ent = Entities:FindByName(nil, "longcorridor_outerdoor1")
                            ent:RedirectOutput("OnFullyClosed", "GiveVortEnergy", ent)
                            ent:RedirectOutput("OnFullyClosed", "ShowVortEnergyTutorial", ent)

                            ent = Entities:FindByName(nil, "longcorridor_innerdoor")
                            ent:RedirectOutput("OnFullyClosed", "RemoveVortEnergy", ent)

                            ent = Entities:FindByName(nil, "longcorridor_energysource_01_activate_relay")
                            ent:RedirectOutput("OnTrigger", "GiveVortEnergy", ent)
                        elseif GetMapName() == "a5_ending" then
                            SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2")
                            SendToConsole("r_drawviewmodel 0")
                            SendToConsole("bind F \"\"")

                            ent = Entities:FindByName(nil, "relay_advisor_void")
                            ent:RedirectOutput("OnTrigger", "GiveAdvisorVortEnergy", ent)

                            ent = Entities:FindByName(nil, "relay_first_credits_start")
                            ent:RedirectOutput("OnTrigger", "StartCredits", ent)

                            ent = Entities:FindByName(nil, "vcd_ending_eli")
                            ent:RedirectOutput("OnTrigger3", "EndCredits", ent)
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
        ClimbLadderSound()
        SendToConsole("fadein 0.2")
        SendToConsole("setpos_exact -1296 576 80")
    end

    function ClimbCellarLadder(a, b)
        ClimbLadderSound()
        SendToConsole("ent_fire cellar_ladder SetCompletionValue 1")
        SendToConsole("fadein 0.2")
        SendToConsole("setpos_exact 1004 1775 546")
    end

    function ClimbLarryLadder(a, b)
        ClimbLadderSound()
        SendToConsole("ent_fire larry_ladder SetCompletionValue 1")
        SendToConsole("fadein 0.2")
        SendToConsole("ent_fire relay_debug_intro_trench trigger")
    end

    function ClimbGarageLadder(a, b)
        ClimbLadderSound()
        SendToConsole("ent_fire toner_sliding_ladder SetCompletionValue 1")
        SendToConsole("fadein 0.2")
        SendToConsole("setpos_exact -367 -416 150")
    end

    function OpenRussellWindow(a, b)
        SendToConsole("fadein 0.2")
        SendToConsole("ent_fire russell_entry_window SetCompletionValue 1")
        SendToConsole("setpos -1728 275 100")
    end

    function OpenRussellDoor(a, b)
        SendToConsole("ent_fire 621_6487_button_branch test")
    end

    function EquipGravityGloves(a, b)
        SendToConsole("ent_fire relay_give_gravity_gloves trigger")
        SendToConsole("hidehud 1")
        Entities:GetLocalPlayer():Attribute_SetIntValue("gravity_gloves", 1)
    end

    function RedirectPistol(a, b)
        ent = Entities:FindByName(nil, "weapon_pistol")
        ent:RedirectOutput("OnPlayerPickup", "EquipPistol", ent)
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

    function MakeLeverUsable(a, b)
        ent = Entities:FindByName(nil, "door_reset")
        ent:Attribute_SetIntValue("used", 0)
    end

    function CrouchThroughZooHole(a, b)
        SendToConsole("fadein 0.2")
        SendToConsole("setpos 5393 -1960 -125")
    end

    function ClimbLadderSound()
        local sounds = 0
        local player = Entities:GetLocalPlayer()
        player:SetThink(function()
            if sounds < 3 then
                SendToConsole("snd_sos_start_soundevent Step_Player.Ladder_Single")
                sounds = sounds + 1
                return 0.15
            end
        end, "LadderSound", 0)
    end

    function FixJeffBatteryPuzzle()
        SendToConsole("ent_fire @barnacle_battery kill")
        SendToConsole("ent_create item_hlvr_prop_battery { origin \"959 1970 427\" }")
        SendToConsole("ent_fire @crank_battery kill")
        SendToConsole("ent_create item_hlvr_prop_battery { origin \"1325 2245 435\" }")
        SendToConsole("ent_fire 11478_6233_math_count_wheel_installment SetHitMax 1")
    end

    function ShowSprintTutorial()
        SendToConsole("ent_fire text_sprint ShowMessage")
        SendToConsole("play play sounds/ui/beepclear.vsnd")
    end

    function ShowCrouchJumpTutorial()
        SendToConsole("ent_fire text_crouchjump ShowMessage")
        SendToConsole("play play sounds/ui/beepclear.vsnd")
    end

    function UnequipCombinGunMechanical()
        SendToConsole("ent_fire player_speedmod ModifySpeed 1")
        SendToConsole("ent_fire combine_gun_mechanical ClearParent")
        SendToConsole("bind MOUSE1 +customattack")
        local ent = Entities:FindByName(nil, "combine_gun_mechanical")
        SendToConsole("ent_setpos " .. ent:entindex() .. " 1479.722 385.634 964.917")
        SendToConsole("r_drawviewmodel 1")
    end

    function EnterVaultBeam()
        SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2;ent_remove weapon_frag")
        SendToConsole("r_drawviewmodel 0")
        SendToConsole("hidehud 4")
        SendToConsole("ent_fire player_speedmod ModifySpeed 0")
    end

    function ShowVortEnergyTutorial()
        SendToConsole("ent_fire text_vortenergy ShowMessage")
        SendToConsole("play play sounds/ui/beepclear.vsnd")
    end

    function GiveVortEnergy(a, b)
        SendToConsole("bind MOUSE1 shootvortenergy")
        SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2;ent_remove weapon_frag")
        SendToConsole("r_drawviewmodel 0")
    end

    function RemoveVortEnergy(a, b)
        SendToConsole("bind MOUSE1 +attack")
        SendToConsole("r_drawviewmodel 1")
        SendToConsole("give weapon_frag")
    end

    function GiveAdvisorVortEnergy(a, b)
        SendToConsole("bind MOUSE1 shootadvisorvortenergy")
    end

    function StartCredits(a, b)
        SendToConsole("mouse_disableinput 1")
    end

    function EndCredits(a, b)
        SendToConsole("mouse_disableinput 0")
    end
end
