if GlobalSys:CommandLineCheck("-novr") then
    require "storage"
    unstuck_table = {}
    unstuck_count = 0
    collidable_props = {
        "models/props_c17/oildrum001.vmdl",
        "models/props/plastic_container_1.vmdl",
        "models/industrial/industrial_board_01.vmdl",
        "models/industrial/industrial_board_02.vmdl",
        "models/industrial/industrial_board_03.vmdl",
        "models/industrial/industrial_board_04.vmdl",
        "models/industrial/industrial_board_05.vmdl",
        "models/industrial/industrial_board_06.vmdl",
        "models/industrial/industrial_board_07.vmdl",
        "models/industrial/industrial_chemical_barrel_02.vmdl",
        "models/props/barrel_plastic_1.vmdl",
        "models/props/barrel_plastic_1_open.vmdl",
        "models/props_c17/oildrum001_explosive.vmdl",
        "models/props_junk/wood_crate001a.vmdl",
        "models/props_junk/wood_crate002a.vmdl",
        "models/props_junk/wood_crate004.vmdl",
        "models/props/interior_furniture/interior_shelving_001_b.vmdl",
        "models/props/interior_chairs/interior_chair_001.vmdl",
    }

    DoIncludeScript("bindings.lua", nil)
    DoIncludeScript("flashlight.lua", nil)
    DoIncludeScript("jumpfix.lua", nil)
    DoIncludeScript("wristpockets.lua", nil)
    DoIncludeScript("viewmodels.lua", nil)
    DoIncludeScript("viewmodels_animation.lua", nil)
    DoIncludeScript("hudhearts.lua", nil)

    if player_hurt_ev ~= nil then
        StopListeningToGameEvent(player_hurt_ev)
    end

    player_hurt_ev = ListenToGameEvent('player_hurt', function(info)
        local player = Entities:GetLocalPlayer()

        -- Hack to stop pausing the game on death
        if info.health == 0 then
            PlayerDied()
            player:SetThink(function()
                PlayerDied()
            end, "UnpauseOnDeath1", 0)
            player:SetThink(function()
                PlayerDied()
            end, "UnpauseOnDeath2", 0.02)
        elseif player:Attribute_GetIntValue("syringe_tutorial_shown", 0) == 1 then
            SendToConsole("ent_fire text_syringe ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            player:Attribute_SetIntValue("syringe_tutorial_shown", 2)
        end

        -- Kill on fall damage
        if GetPhysVelocity(player).z < -450 then
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
        local player = Entities:GetLocalPlayer()
        local ent = EntIndexToHScript(info.entindex)
        if ent then
            local child = ent:GetChildren()[1]
            if child and child:GetClassname() == "prop_dynamic" then
                child:SetEntityName("held_prop_dynamic_override")
            end
            if ent:GetClassname() ~= "item_hlvr_grenade_frag" and ent:GetClassname() ~= "item_hlvr_combine_console_tank" then
                ent:Attribute_SetIntValue("picked_up", 1)
            end
            player:Attribute_SetIntValue("picked_up", 1)
            player:SetThink(function()
                player:Attribute_SetIntValue("picked_up", 0)
            end, "ResetPickedUp", 0.02)
            DoEntFireByInstanceHandle(ent, "AddOutput", "OnPhysgunDrop>!self>RunScriptCode>thisEntity:Attribute_SetIntValue(\"picked_up\", 0)>0.02>1", 0, nil, nil)
            DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
        end
    end, nil)

    if player_barnacle_grab_ev ~= nil then
        StopListeningToGameEvent(player_barnacle_grab_ev)
    end

    player_barnacle_grab_ev = ListenToGameEvent('player_grabbed_by_barnacle', function(info)
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("disable_unstuck", 1)
    end, nil)

    if player_barnacle_release_ev ~= nil then
        StopListeningToGameEvent(player_barnacle_release_ev)
    end

    player_barnacle_release_ev = ListenToGameEvent('player_released_by_barnacle', function(info)
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("disable_unstuck", 0)
    end, nil)

    Convars:RegisterCommand("usemultitool", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        local player = Entities:GetLocalPlayer()

        if viewmodel and string.match(viewmodel:GetModelName(), "v_multitool") then
            SendToConsole("-iv_attack")
            SendToConsole("alias -customattack \"alias -customattack -iv_attack\"")

            local startVector = player:EyePosition()
            local traceTable =
            {
                startpos = startVector;
                endpos = startVector + RotatePosition(Vector(0, 0, 0), player:GetAngles(), Vector(65, 0, 0));
                ignore = player;
                mask =  33636363
            }

            TraceLine(traceTable)

            if traceTable.hit then
                local ent = Entities:FindByClassnameNearest("info_hlvr_toner_junction", traceTable.pos, 10)
                if ent then
                    DoEntFireByInstanceHandle(ent, "RunScriptFile", "multitool", 0, nil, nil)
                end

                ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", traceTable.pos, 20)
                if ent then
                    local name = ent:GetName()
                    local parent = ent:GetMoveParent()
                    if ent:Attribute_GetIntValue("used", 0) == 0 and not (parent and (vlua.find(parent:GetModelName(), "power_stake"))) and name ~= "traincar_01_hackplug" and ent:GetGraphParameter("b_PlugDisabled") == false then
                        -- Combine Console
                        if parent and vlua.find(parent:GetName(), "Console") then
                            if GetMapName() == "a2_quarantine_entrance" then
                                local rack = Entities:FindByClassname(nil, "item_hlvr_combine_console_rack")
                                while rack do
                                    rack:RedirectOutput("OnCompletionA_Forward", "ShowHoldInteractTutorial", rack)
                                    rack = Entities:FindByClassname(rack, "item_hlvr_combine_console_rack")
                                end
                            end
                            local ents = Entities:FindAllByClassnameWithin("item_hlvr_combine_console_tank", parent:GetCenter(), 20)
                            for k, v in pairs(ents) do
                                DoEntFireByInstanceHandle(v, "DisablePickup", "", 0, player, nil)
                            end
                            SendToConsole("ent_fire 5325_3947_combine_console AddOutput OnTankAdded>item_hlvr_combine_console_tank>DisablePickup>>0>1")
                        end

                        if parent and parent:GetClassname() == "prop_hlvr_crafting_station_console" then
                            DoEntFireByInstanceHandle(parent, "RunScriptFile", "multitool", 0, nil, nil)
                        end

                        if parent and parent:GetName() == "254_16189_combine_locker" then
                            SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_2_40_92_white.vmdl", ["origin"]="-2018 -1828 216", ["angles"]="0 270 0", ["parentname"]="scanner_return_clip_door"})
                            SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_2_40_92_white.vmdl", ["origin"]="-1868 -1744 216", ["angles"]="0 180 0", ["parentname"]="scanner_return_clip", ["modelscale"]=10})
                        end

                        local ents = Entities:FindAllByClassnameWithin("baseanimating", ent:GetCenter(), 3)
                        for i = 1, #ents do
                            local ent = ents[i]
                            if ent:GetModelName() == "models/props_combine/combine_consoles/vr_combine_interface_01.vmdl" and ent:GetCycle() > 0 then
                                return
                            end
                        end

                        ent:Attribute_SetIntValue("used", 1)
                        DoEntFireByInstanceHandle(ent, "BeginHack", "", 0, nil, nil)
                        
                        if not vlua.find(name, "cshield") and not vlua.find(name, "switch_box") then
                            -- if parent:GetModelName() == "models/props_combine/combine_lockers/combine_locker_doors.vmdl" then
                            --     player:SetThink(function()
                            --         if GetMapName() == "a2_quarantine_entrance" then
                            --             SendToConsole("ent_fire text_hacking_puzzle_trace ShowMessage")
                            --             SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
                            --         end

                            --         ent = Entities:FindByClassname(nil, "prop_hlvr_holo_hacking_sphere_trace")
                            --         SendToConsole("fadein 0.2")
                            --         DoEntFireByInstanceHandle(ent, "Use", "", 0, player, player)
                            --         local angles = player:GetAngles()
                            --         player:SetAngles(angles.x, angles.y + 180, angles.z)
                            --         player:SetThink(function()
                            --             SendToConsole("+iv_use;-iv_use")
                            --         end, "HideOrb1", 0.02)
                            --         player:SetThink(function()
                            --             player:SetAngles(angles.x, angles.y, angles.z)
                            --         end, "HideOrb2", 0.04)
                            --         player:SetThink(function()
                            --             if player:GetVelocity().z == 0 then
                            --                 SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                            --                 return nil
                            --             end
                            --             return 0
                            --         end, "StopPlayerOnLand", 0)
                            --         print("[GameMenu] hacking_puzzle_trace")
                            --     end, "HackingPuzzleTrace", 2.5)
                            -- else
                            DoEntFireByInstanceHandle(ent, "EndHack", "", 1.8, nil, nil)
                            ent:FireOutput("OnHackSuccess", nil, nil, nil, 1.8)
                            ent:FireOutput("OnPuzzleSuccess", nil, nil, nil, 1.8)
                            -- end
                        end
                        return
                    end
                end

                local ent = Entities:FindByClassnameNearest("info_hlvr_toner_port", traceTable.pos, 20)
                if ent then
                    DoEntFireByInstanceHandle(ent, "RunScriptFile", "multitool", 0, nil, nil)
                    return
                end
            end
        end
    end, "", 0)

    Convars:RegisterCommand("toggle_noclip", function()
        local player = Entities:GetLocalPlayer()
        if player:Attribute_GetIntValue("noclip_tutorial_shown", 0) == 0 then
            player:Attribute_SetIntValue("noclip_tutorial_shown", 1)
            SendToConsole("ent_fire text_noclip ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        end

        SendToConsole("noclip")
    end, "", 0)

    Convars:RegisterCommand("novr_unequip_wearable", function()
        local ent = Entities:FindByName(nil, "hat_construction_viewmodel")
        if ent then
            local hat = SpawnEntityFromTableSynchronous("prop_physics", {["model"]="models/props/construction/hat_construction.vmdl"})
            hat:SetOrigin(Entities:GetLocalPlayer():EyePosition())
            local angles = Entities:GetLocalPlayer():EyeAngles()
            hat:SetAngles(angles.x, angles.y, angles.z)

            if ent:GetMaterialGroupHash() < 0 then
                hat:SetSkin(1)
                local color = ent:GetRenderColor()
                hat:SetRenderColor(color.x, color.y, color.z)
            end

            ent:Kill()

            Entities:GetLocalPlayer():SetThink(function()
                SendToConsole("ent_fire npc_barnacle SetRelationship \"player D_HT 99\"")
            end, "HostileBarnacles", 0.2)
        end
    end, "", 0)

    Convars:RegisterCommand("novr_cover_mouth", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        viewmodel:SetRenderAlpha(0)
        Entities:GetLocalPlayer():Attribute_SetIntValue("covering_mouth", 1)
    end, "", 0)

    Convars:RegisterCommand("novr_uncover_mouth", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        viewmodel:SetRenderAlpha(255)
        Entities:GetLocalPlayer():Attribute_SetIntValue("covering_mouth", 0)
    end, "", 0)

    Convars:RegisterCommand("novr_hacking_puzzle_failed", function()
        local ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", Entities:GetLocalPlayer():GetCenter(), 100)
        DoEntFireByInstanceHandle(ent, "EndHack", "", 0, nil, nil)
        ent:FireOutput("OnHackFailed", nil, nil, nil, 0)
        ent:FireOutput("OnPuzzleFailed", nil, nil, nil, 0)
        ent:Attribute_SetIntValue("used", 0)
        SendToConsole("ent_fire player_speedmod ModifySpeed 1")
    end, "", 0)

    Convars:RegisterCommand("novr_hacking_puzzle_success", function()
        local ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", Entities:GetLocalPlayer():GetCenter(), 100)
        DoEntFireByInstanceHandle(ent, "EndHack", "", 0, nil, nil)
        ent:FireOutput("OnHackSuccess", nil, nil, nil, 0)
        ent:FireOutput("OnPuzzleSuccess", nil, nil, nil, 0)
        SendToConsole("ent_fire player_speedmod ModifySpeed 1")
    end, "", 0)

    Convars:RegisterConvar("chosen_upgrade", "", "", 0)

    Convars:RegisterConvar("weapon_in_crafting_station", "", "", 0)

    Convars:RegisterCommand("unstuck", function()
        local player = Entities:GetLocalPlayer()
        if player ~= nil and player:Attribute_GetIntValue("disable_unstuck", 0) == 0 then
            if player:GetVelocity().x == 0 and player:GetVelocity().y == 0 and unstuck_table[1] then
                local startVector = player:GetOrigin()
                local minVector = player:GetBoundingMins()
                minVector.x = minVector.x + 0.01
                minVector.y = minVector.y + 0.01
                local maxVector = player:GetBoundingMaxs()
                maxVector.x = maxVector.x - 0.01
                maxVector.y = maxVector.y - 0.01
                local traceTable =
                {
                    startpos = startVector;
                    endpos = startVector;
                    ignore = player;
                    mask =  33636363;
                    min = minVector;
                    max = maxVector
                }

                TraceHull(traceTable)

                if traceTable.hit then
                    if traceTable.enthit:GetClassname() == "prop_ragdoll" then
                        return
                    end

                    if traceTable.enthit:GetClassname() == "prop_physics" then
                        if vlua.find(collidable_props, traceTable.enthit:GetModelName()) == nil then
                            return
                        end
                    end

                    if unstuck_count >= 1 then
                        player:SetOrigin(unstuck_table[1])
                        unstuck_count = 0
                    else
                        unstuck_count = unstuck_count + 1
                    end
                end
            end
        end
    end, "", 0)

    Convars:RegisterCommand("save_manual", function()
        SendToConsole("save manual;snd_sos_start_soundevent Instructor.StartLesson;ent_fire text_quicksave showmessage")
    end, "", 0)

    Convars:RegisterCommand("mouse_invert_y", function(name, value)
        if value == "true" or value == "1" then
            SendToConsole("bind MOUSE_Y !iv_pitch")
        else
            SendToConsole("bind MOUSE_Y iv_pitch")
        end
    end, "", 0)

    Convars:RegisterCommand("novr_energygun_grant_upgrade", function(name, value)
        -- Reflex Sight
        if value == "0" then
            Convars:SetStr("chosen_upgrade", "pistol_upgrade_aimdownsights")
        -- Burst Fire
        elseif value == "1" then
            Convars:SetStr("chosen_upgrade", "pistol_upgrade_burstfire")
        -- Bullet Reservoir
        elseif value == "2" then
            Convars:SetStr("chosen_upgrade", "pistol_upgrade_hopper")
        -- Laser Sight
        elseif value == "3" then
            Convars:SetStr("chosen_upgrade", "pistol_upgrade_lasersight")
        else
            return
        end

        SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
    end, "", 0)

    Convars:RegisterCommand("novr_shotgun_grant_upgrade", function(name, value)
        -- Laser Sight
        if value == "0" then
            Convars:SetStr("chosen_upgrade", "shotgun_upgrade_lasersight")
        -- Double Shot
        elseif value == "1" then
            Convars:SetStr("chosen_upgrade", "shotgun_upgrade_doubleshot")
        -- Autoloader
        elseif value == "2" then
            Convars:SetStr("chosen_upgrade", "shotgun_upgrade_hopper")
        -- Grenade Launcher
        elseif value == "3" then
            Convars:SetStr("chosen_upgrade", "shotgun_upgrade_grenadelauncher")
        else
            return
        end

        SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
    end, "", 0)

    Convars:RegisterCommand("novr_rapidfire_grant_upgrade", function(name, value)
        -- Reflex Sight
        if value == "0" then
            Convars:SetStr("chosen_upgrade", "smg_upgrade_aimdownsights")
        -- Laser Sight
        elseif value == "1" then
            Convars:SetStr("chosen_upgrade", "smg_upgrade_lasersight")
        -- Extended Magazine
        elseif value == "2" then
            Convars:SetStr("chosen_upgrade", "smg_upgrade_casing")
        else
            return
        end

        SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
    end, "", 0)

    Convars:RegisterCommand("novr_crafting_station_choose_upgrade", function(name, value)
        local t = {}
        Entities:GetLocalPlayer():GatherCriteria(t)

        if Convars:GetStr("weapon_in_crafting_station") == "pistol" then
            -- Reflex Sight
            if value == "1" and t.current_crafting_currency >= 10 then
                SendToConsole("novr_energygun_grant_upgrade 0")
                SendToConsole("hlvr_addresources 0 0 0 -10")
                return
            -- Burst Fire
            elseif value == "2" and t.current_crafting_currency >= 20 then
                SendToConsole("novr_energygun_grant_upgrade 1")
                SendToConsole("hlvr_addresources 0 0 0 -20")
                return
            -- Bullet Reservoir
            elseif value == "3" and t.current_crafting_currency >= 30 then
                SendToConsole("novr_energygun_grant_upgrade 2")
                SendToConsole("hlvr_addresources 0 0 0 -30")
                return
            -- Laser Sight
            elseif value == "4" and t.current_crafting_currency >= 35 then
                SendToConsole("novr_energygun_grant_upgrade 3")
                SendToConsole("hlvr_addresources 0 0 0 -35")
                return
            end
        elseif Convars:GetStr("weapon_in_crafting_station") == "shotgun" then
            -- Laser Sight
            if value == "1" and t.current_crafting_currency >= 10 then
                SendToConsole("novr_shotgun_grant_upgrade 0")
                SendToConsole("hlvr_addresources 0 0 0 -10")
                return
            -- Double Shot
            elseif value == "2" and t.current_crafting_currency >= 25 then
                SendToConsole("novr_shotgun_grant_upgrade 1")
                SendToConsole("hlvr_addresources 0 0 0 -25")
                return
            -- Autoloader
            elseif value == "3" and t.current_crafting_currency >= 30 then
                SendToConsole("novr_shotgun_grant_upgrade 2")
                SendToConsole("hlvr_addresources 0 0 0 -30")
                return
            -- Grenade Launcher
            elseif value == "4" and t.current_crafting_currency >= 40 then
                SendToConsole("novr_shotgun_grant_upgrade 3")
                SendToConsole("hlvr_addresources 0 0 0 -40")
                return
            end
        elseif Convars:GetStr("weapon_in_crafting_station") == "smg" then
            -- Reflex Sight
            if value == "1" and t.current_crafting_currency >= 15 then
                SendToConsole("novr_rapidfire_grant_upgrade 0")
                SendToConsole("hlvr_addresources 0 0 0 -15")
                return
            -- Extended Magazine
            elseif value == "2" and t.current_crafting_currency >= 25 then
                SendToConsole("novr_rapidfire_grant_upgrade 1")
                SendToConsole("hlvr_addresources 0 0 0 -25")
                return
            -- Laser Sight
            elseif value == "3" and t.current_crafting_currency >= 30 then
                SendToConsole("novr_rapidfire_grant_upgrade 2")
                SendToConsole("hlvr_addresources 0 0 0 -30")
                return
            end
        end

        SendToConsole("ent_fire text_resin SetText #HLVR_CraftingStation_NotEnoughResin")
        SendToConsole("ent_fire text_resin Display")
        SendToConsole("snd_sos_start_soundevent PlayerTeleport.Fail")
        SendToConsole("novr_crafting_station_cancel_upgrade")
    end, "", 0)

    Convars:RegisterCommand("novr_crafting_station_cancel_upgrade", function()
        Convars:SetStr("chosen_upgrade", "cancel")
        SendToConsole("ent_fire weapon_in_fabricator Kill")
        SendToConsole("ent_fire upgrade_ui kill")
        -- TODO: Give weapon back, but don't fill magazine
        if Convars:GetStr("weapon_in_crafting_station") == "pistol" then
            SendToConsole("give weapon_pistol")
        elseif Convars:GetStr("weapon_in_crafting_station") == "shotgun" then
            SendToConsole("give weapon_shotgun")
        elseif Convars:GetStr("weapon_in_crafting_station") == "smg" then
            SendToConsole("give weapon_ar2")
        end
        Convars:SetStr("weapon_in_crafting_station", "")
        SendToConsole("viewmodel_update")
        SendToConsole("ent_fire prop_hlvr_crafting_station_console RunScriptFile useextra")
    end, "", 0)

    Convars:RegisterCommand("throwgrenade", function(name, launcher)
        local player = Entities:GetLocalPlayer()
        local playerhasxengrenade = WristPockets_PlayerHasXenGrenade()
        if not WristPockets_PlayerHasGrenade() and not playerhasxengrenade then
            SendToConsole("snd_sos_start_soundevent PlayerTeleport.Fail")
            return
        end
        local pos = player:EyePosition()
        local class = "item_hlvr_grenade_frag"
        -- Remove xen grenade or frag grenade from wristpocket slots
        if playerhasxengrenade then
            class = "item_hlvr_grenade_xen"
            WristPockets_UseXenGrenade()
        else
            WristPockets_UseGrenade()
        end
        
        local ent = SpawnEntityFromTableSynchronous(class, {["targetname"]="player_grenade", ["origin"]=pos.x .. " " .. pos.y .. " " .. pos.z})
        ent:SetOwner(player)
        if class == "item_hlvr_grenade_frag" then
            local ent2 = Entities:FindByNameNearest("grenade_handle", ent:GetAbsOrigin(), 10)
            ent2:Kill()
        end
        if launcher then
            ent:ApplyAbsVelocityImpulse(player:GetForwardVector() * 1000)
            local velocity = GetPhysVelocity(ent)
            ent:SetThink(function()
                local new_velocity = GetPhysVelocity(ent)
                if (new_velocity:Length() - velocity:Length()) < -100 then
                    DoEntFireByInstanceHandle(ent, "SetTimer", "0", 0, nil, nil)
                    return nil
                end
                velocity = new_velocity
                return 0
            end, "ExplodeOnImpact", 0)
            StartSoundEventFromPosition("Shotgun.UpgradeLaunchGrenade", player:EyePosition()) -- play sound of shotgun launch upgrade
            SendToConsole("viewmodel_update") -- update of attached grenade
        else
            ent:ApplyAbsVelocityImpulse(player:GetForwardVector() * 500)
            SendToConsole("impulse 200")
            player:SetThink(function()
                SendToConsole("impulse 200")
            end, "FinishGrenadeThrow", 0.1)
        end
        DoEntFireByInstanceHandle(ent, "ArmGrenade", "", 0, nil, nil)
    end, "", 0)

    -- Register variable for ads zoom
    FOV_ADS_ZOOM = 40
    Convars:RegisterConvar("fov_ads_zoom", "", "", 0)
    cvar_setf("fov_ads_zoom", FOV)

    -- Custom attack 2
    Convars:RegisterCommand("+customattack2", function()
        local viewmodel = Entities:FindByClassname(nil, "viewmodel")
        local player = Entities:GetLocalPlayer()

        -- Reset viewmodel after auto weapon switch
        if viewmodel and cvar_getf("fov_ads_zoom") == FOV_ADS_ZOOM and not string.match(viewmodel:GetModelName(), "_ads.vmdl") then
            ViewmodelAnimation_ResetAnimation()
            cvar_setf("fov_ads_zoom", FOV)
            SendToConsole("ent_fire ads_zoom unzoom")
            cvar_setf("viewmodel_offset_x", 0)
            cvar_setf("viewmodel_offset_y", 0)
            cvar_setf("viewmodel_offset_z", 0)
            SendToConsole("hud_draw_fixed_reticle 1")
        end

        if viewmodel and not string.match(viewmodel:GetModelName(), "v_grenade") then
            if string.match(viewmodel:GetModelName(), "v_shotgun") then
                if player:Attribute_GetIntValue("shotgun_upgrade_doubleshot", 0) == 1 then
                    SendToConsole("+attack2")
                end
            elseif string.match(viewmodel:GetModelName(), "v_pistol") then
                if player:Attribute_GetIntValue("pistol_upgrade_aimdownsights", 0) == 1 then
                    if cvar_getf("fov_ads_zoom") > FOV_ADS_ZOOM then
                        cvar_setf("viewmodel_offset_y", 0)
                        cvar_setf("viewmodel_offset_z", -0.04)
                        SendToConsole("ent_fire ads_zoom zoom")
                        ViewmodelAnimation_HIPtoADS()
                        player:SetThink(function()
                            cvar_setf("fov_ads_zoom", FOV_ADS_ZOOM)
                            cvar_setf("viewmodel_offset_x", -0.005)
                        end, "ZoomActivate", 0.5)
                        SendToConsole("hud_draw_fixed_reticle 0")
                        SendToConsole("crosshair 0")
                    else
                        cvar_setf("fov_ads_zoom", FOV)
                        SendToConsole("ent_fire ads_zoom_out zoom")
                        cvar_setf("viewmodel_offset_x", 0)
                        cvar_setf("viewmodel_offset_y", 0)
                        cvar_setf("viewmodel_offset_z", 0)
                        ViewmodelAnimation_ADStoHIP()
                        if player:Attribute_GetIntValue("pistol_upgrade_lasersight", 0) == 0 then
                            SendToConsole("hud_draw_fixed_reticle 1")
                        else
                            SendToConsole("crosshair 1")
                        end
                        player:SetThink(function()
                            SendToConsole("ent_fire ads_zoom unzoom")
                            SendToConsole("ent_fire ads_zoom_out unzoom")
                        end, "ZoomDeactivate", 0.5)
                    end
                end
            elseif string.match(viewmodel:GetModelName(), "v_smg1") then
                if player:Attribute_GetIntValue("smg_upgrade_aimdownsights", 0) == 1 then
                    if cvar_getf("fov_ads_zoom") > FOV_ADS_ZOOM then
                        cvar_setf("viewmodel_offset_y", 0)
                        cvar_setf("viewmodel_offset_z", -0.045)
                        SendToConsole("ent_fire ads_zoom zoom")
                        ViewmodelAnimation_HIPtoADS()
                        player:SetThink(function()
                            cvar_setf("fov_ads_zoom", FOV_ADS_ZOOM)
                            cvar_setf("viewmodel_offset_x", 0.025)
                        end, "ZoomActivate", 0.5)
                        SendToConsole("hud_draw_fixed_reticle 0")
                        SendToConsole("crosshair 0")
                    else
                        cvar_setf("fov_ads_zoom", FOV)
                        SendToConsole("ent_fire ads_zoom_out zoom")
                        cvar_setf("viewmodel_offset_x", 0)
                        cvar_setf("viewmodel_offset_y", 0)
                        cvar_setf("viewmodel_offset_z", 0)
                        ViewmodelAnimation_ADStoHIP()
                        if player:Attribute_GetIntValue("smg_upgrade_lasersight", 0) == 0 then
                            SendToConsole("hud_draw_fixed_reticle 1")
                        else
                            SendToConsole("crosshair 1")
                        end
                        player:SetThink(function()
                            SendToConsole("ent_fire ads_zoom unzoom")
                            SendToConsole("ent_fire ads_zoom_out unzoom")
                        end, "ZoomDeactivate", 0.5)
                    end
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
            if string.match(viewmodel:GetModelName(), "v_shotgun") then
                if player:Attribute_GetIntValue("shotgun_upgrade_grenadelauncher", 0) == 1 then
                    SendToConsole("throwgrenade true")
                end
            elseif string.match(viewmodel:GetModelName(), "v_pistol") then
                if player:Attribute_GetIntValue("pistol_upgrade_burstfire", 0) == 1 then
                    SendToConsole("sk_plr_dmg_pistol 9")
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
                        SendToConsole("sk_plr_dmg_pistol 7")
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
        SendToConsole("bind " .. PRIMARY_ATTACK .. " \"\"")
        SendToConsole("ent_fire relay_advisor_dead Trigger")
    end, "", 0)

    Convars:RegisterCommand("shootvortenergy", function()
        local player = Entities:GetLocalPlayer()
        local startVector = player:EyePosition()
        local traceTable =
        {
            startpos = startVector;
            endpos = startVector + RotatePosition(Vector(0, 0, 0), player:GetAngles(), Vector(1000000, 0, 0));
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

        player:Attribute_SetIntValue("used_gravity_gloves", 0)
        player:Attribute_SetIntValue("use_released", 0)

        local startVector = player:EyePosition()
        local eyetrace =
        {
            startpos = startVector;
            endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(1000,0,0));
            ignore = player;
            mask =  33636363
        }
        TraceLine(eyetrace)
        if eyetrace.hit then
            local minDistanceEnt
            local minDistance
            for k, v in pairs(Entities:FindAllInSphere(eyetrace.pos, 10)) do
                local distance = VectorDistanceSq(eyetrace.pos, v:GetCenter())
                if minDistanceEnt == nil or distance < minDistance then
                    minDistance = distance
                    minDistanceEnt = v
                end
            end

            if minDistanceEnt then
                DoEntFireByInstanceHandle(minDistanceEnt, "RunScriptFile", "gravity_gloves", 0, nil, nil)
            end
        end

        DoEntFire("!picker", "RunScriptFile", "check_useextra_distance", 0, nil, nil)

        -- Ladders and position based interactions
        if GetMapName() == "a1_intro_world" then
            if vlua.find(Entities:FindAllInSphere(Vector(648, -1757, -141), 10), player) then
                ClimbLadder(-64)
            elseif vlua.find(Entities:FindAllInSphere(Vector(530, -2331, -84), 20), player) then
                ClimbLadderSound()
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact 574 -2328 -130")
            end
        elseif GetMapName() == "a1_intro_world_2" then
            if vlua.find(Entities:FindAllInSphere(Vector(-1268, 576, -63), 10), player) and Entities:FindByName(nil, "balcony_ladder"):GetSequence() == "idle_open" then
                ClimbLadder(80)
            elseif vlua.find(Entities:FindAllInSphere(Vector(-911, 922, -68), 10), player) then
                ClimbLadder(-22)
            end

            local startVector = player:EyePosition()
            local traceTable =
            {
                startpos = startVector;
                endpos = startVector + RotatePosition(Vector(0, 0, 0), player:GetAngles(), Vector(80, 0, 0));
                ignore = player;
                mask = 33636363
            }

            TraceLine(traceTable)

            if traceTable.hit then
                local ent = Entities:FindByNameNearest("621_6487_button_pusher_prop", traceTable.pos, 10)
                if ent then
                    DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
                end
            end
        elseif GetMapName() == "a2_pistol" then
            if vlua.find(Entities:FindAllInSphere(Vector(439, 896, 454), 10), player) then
                ClimbLadder(540)
            end
        elseif GetMapName() == "a2_hideout" then
            local startVector = player:EyePosition()
            local traceTable =
            {
                startpos = startVector;
                endpos = startVector + RotatePosition(Vector(0, 0, 0), player:GetAngles(), Vector(60, 0, 0));
                ignore = player;
                mask = 33636363
            }

            TraceLine(traceTable)

            if traceTable.hit then
                local ent = Entities:FindByClassnameNearest("func_physical_button", traceTable.pos, 5)
                if ent and ent:Attribute_GetIntValue("used", 0) == 0 then
                    ent:FireOutput("OnIn", nil, nil, nil, 0)
                    ent:Attribute_SetIntValue("used", 1)
                    StartSoundEventFromPosition("Button_Basic.Press", player:EyePosition())
                end
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-702, -1024, -238), 20), player) then
                local ent = Entities:FindByName(nil, "bell")
                DoEntFireByInstanceHandle(ent, "RunScriptFile", "useextra", 0, nil, nil)
            end
        elseif GetMapName() == "a2_headcrabs_tunnel" and vlua.find(Entities:FindAllInSphere(Vector(354, -251, -62), 18), player) then
            ClimbLadder(22)
        elseif GetMapName() == "a3_station_street" then
            if vlua.find(Entities:FindAllInSphere(Vector(934, 1883, -135), 20), player) then
                SendToConsole("ent_fire_output 2_8127_elev_button_floor_1_call OnIn")
            end
        elseif GetMapName() == "a3_hotel_lobby_basement" then
            if vlua.find(Entities:FindAllInSphere(Vector(1059, -1475, 200), 20), player) then
                if player:Attribute_GetIntValue("EnabledHotelLobbyPower", 0) == 1 then
                    SendToConsole("ent_fire_output elev_button_floor_1 OnIn")
                else
                    SendToConsole("ent_fire elev_button_floor_1 Press")
                end
            elseif vlua.find(Entities:FindAllInSphere(Vector(976, -1487, 208), 15), player) then
                ClimbLadder(272, Vector(0, 0.8, 0.8))
            end
        elseif GetMapName() == "a3_hotel_underground_pit" then
            if vlua.find(Entities:FindAllInSphere(Vector(2239, -1017, 528), 15), player) then
                ClimbLadder(570)
            end
        elseif GetMapName() == "a3_hotel_interior_rooftop" then
            if vlua.find(Entities:FindAllInSphere(Vector(2381, -1841, 448), 10), player) then
                ClimbLadder(560)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2335, -1832, 757), 20), player) then
                ClimbLadder(840, Vector(0, 0, 0))
            end
        elseif GetMapName() == "a3_c17_processing_plant" then
            local startVector = player:EyePosition()
            local traceTable =
            {
                startpos = startVector;
                endpos = startVector + RotatePosition(Vector(0, 0, 0), player:GetAngles(), Vector(60, 0, 0));
                ignore = player;
                mask = -1
            }

            TraceLine(traceTable)

            if traceTable.hit then
                local ent = Entities:FindByNameWithin(nil, "1517_3301_lift_button_attached_down_prop", traceTable.pos, 10)
                if ent then
                    player:Attribute_SetIntValue("activated_processing_plant_lift", 1)
                    SendToConsole("ent_fire_output lift_button_down onin")
                end
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-80, -2215, 760), 15), player) and Entities:FindByName(nil, "factory_int_up_barnacle_npc_1"):GetHealth() <= 0 then
                ClimbLadder(890)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-237,-2856,392), 15), player) then
                player:SetVelocity(Vector(player:GetForwardVector().x, player:GetForwardVector().y, 0):Normalized() * 150)
                player:SetThink(function()
                    ClimbLadder(440)
                end, "ClimbLadder", 0.1)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(414,-2459,328), 15), player) then
                player:SetVelocity(Vector(player:GetForwardVector().x, player:GetForwardVector().y, 0):Normalized() * 150)
                player:SetThink(function()
                    ClimbLadder(440)
                end, "ClimbLadder", 0.2)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(326, -3491, 312), 20), player) then
                ClimbLadder(400)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-1630, -2045, 111), 15), player) then
                ClimbLadder(180)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-1393, -2493, 113), 10), player) then
                ClimbLadder(425, Vector(0, 0, -1))
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-1420, -2482, 472), 30), player) then
                ClimbLadderSound()
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact -1392 -2471 53")
            end
        elseif GetMapName() == "a3_distillery" then
            if vlua.find(Entities:FindAllInSphere(Vector(20, -496, 211), 10), player) then
                ClimbLadder(462)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(-24, -151, 426), 5), player) then
                if player:Attribute_GetIntValue("pulled_larry_ladder", 0) == 0 then
                    DoEntFireByInstanceHandle(Entities:FindByName(nil, "larry_ladder"), "RunScriptFile", "useextra", 0, nil, nil)
                else
                    ClimbLadder(560)
                end
            end

            if vlua.find(Entities:FindAllInSphere(Vector(515, 1595, 578), 10), player) then
                ClimbLadder(690)
            end

            if vlua.find(Entities:FindAllInSphere(Vector(925, 1102, 578), 10), player) then
                SendToConsole("ent_fire_output 11578_2635_380_button_center_pusher OnIn")
            end
        elseif GetMapName() == "a4_c17_tanker_yard" then
            if vlua.find(Entities:FindAllInSphere(Vector(6980, 2591, 13), 10), player) then
                ClimbLadder(260)
            elseif vlua.find(Entities:FindAllInSphere(Vector(6618, 2938, 334), 10), player) then
                ClimbLadder(402)
            elseif vlua.find(Entities:FindAllInSphere(Vector(6069, 3902, 416), 10), player) then
                ClimbLadder(686)
            elseif vlua.find(Entities:FindAllInSphere(Vector(5456, 4876, 288), 10), player) then
                ClimbLadder(420)
            elseif vlua.find(Entities:FindAllInSphere(Vector(5434, 5755, 273), 10), player) then
                ClimbLadder(403, -player:GetRightVector())
            end
        elseif GetMapName() == "a4_c17_water_tower" then
            if vlua.find(Entities:FindAllInSphere(Vector(3314, 6048, 64), 10), player) then
                ClimbLadder(142)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2981, 5879, -303), 10), player) then
                ClimbLadder(-43)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2374, 6207, -177), 10), player) then
                ClimbLadder(-130)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2432, 6662, 160), 10), player) then
                ClimbLadder(330)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2848, 6130, 384), 10), player) then
                ClimbLadder(575)
            elseif vlua.find(Entities:FindAllInSphere(Vector(2848, 6162, 602), 10), player) then
                ClimbLadderSound()
                SendToConsole("fadein 0.2")
                SendToConsole("setpos_exact 2848 6130 360")
            end
        elseif GetMapName() == "a5_vault" then
            if vlua.find(Entities:FindAllInSphere(Vector(-445, 2900, -515), 10), player) then
                ClimbLadder(-450, Vector(0, 0, 1))
            end
        end
    end, "", 0)

    Convars:RegisterCommand("useextra_release", function()
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("use_released", 1)
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

        SendToConsole("mouse_pitchyaw_sensitivity " .. MOUSE_SENSITIVITY)
        SendToConsole("fov_desired " .. FOV)
        SendToConsole("snd_remove_soundevent HL2Player.UseDeny")

        DoIncludeScript("version.lua", nil)

        if GetMapName() == "startup" then
            SendToConsole("sv_cheats 1")
            SendToConsole("hidehud 96")
            SendToConsole("mouse_disableinput 1")
            SendToConsole("bind " .. PRIMARY_ATTACK .. " +use")
            SendToConsole("bind " .. INTERACT .. " +use")
            SendToConsole("bind " .. CROUCH .. " \"\"")
            if not loading_save_file then
                SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                SendToConsole("setpos 0 -6154 6.473839")

                if Convars:GetBool("vr_enable_fake_vr") then
                    SendToConsole("vr_fakemove_mlook_speed 0")
                    SendToConsole("vr_fakemove_speed 0")
                    ent = SpawnEntityFromTableSynchronous("info_hlvr_equip_player", {["energygun"]=true, ["pistol_upgrade_reflexsight"]=true})
                    DoEntFireByInstanceHandle(ent, "EquipNow", "", 0, nil, nil)
                    Entities:GetLocalPlayer():SetThink(function()
                        ent = Entities:FindByClassname(nil, "point_hmd_anchor")
                        ent:SetOrigin(Vector(0, -6154, 36.473839))
                    end, "", 0)
                end
            else
                GoToMainMenu()
            end
            ent = Entities:FindByName(nil, "startup_relay")
            ent:RedirectOutput("OnTrigger", "GoToMainMenu", ent)

        else
            SendToConsole("binddefaults")
            SendToConsole("unbind TAB")
            SendToConsole("bind PAUSE main_menu_exec")
            print("[GameMenu] pause_menu_mode")
            Entities:GetLocalPlayer():SetThink(function()
                SendToConsole("gameui_allowescape;gameui_preventescapetoshow;gameui_hide")
            end, "SetGameUIState", 0.1)
            SendToConsole("alias +forwardfixed +iv_forward")
            SendToConsole("alias -forwardfixed \"-iv_forward;unstuck\"")
            SendToConsole("alias +backfixed +iv_back")
            SendToConsole("alias -backfixed \"-iv_back;unstuck\"")
            SendToConsole("alias +leftfixed +iv_left")
            SendToConsole("alias -leftfixed \"-iv_left;unstuck\"")
            SendToConsole("alias +rightfixed +iv_right")
            SendToConsole("alias -rightfixed \"-iv_right;unstuck\"")
            SendToConsole("alias +useextra \"+use;useextra\"")
            SendToConsole("alias -useextra \"-use;useextra_release\"")
            SendToConsole("bind " .. INTERACT .. " +useextra")
            SendToConsole("bind " .. JUMP .. " jumpfixed")
            SendToConsole("bind " .. NOCLIP .. " toggle_noclip")
            SendToConsole("bind " .. QUICK_SAVE .. " \"save quick;snd_sos_start_soundevent Instructor.StartLesson;ent_fire text_quicksave showmessage\"")
            SendToConsole("bind " .. QUICK_LOAD .. " \"vr_enable_fake_vr 0;vr_enable_fake_vr 0;load quick\"")
            SendToConsole("bind " .. MAIN_MENU .. " \"map startup\"")
            SendToConsole("bind " .. PRIMARY_ATTACK .. " \"+customattack;viewmodel_update\"")
            SendToConsole("bind " .. SECONDARY_ATTACK .. " +customattack2")
            SendToConsole("bind " .. TERTIARY_ATTACK .. " +customattack3")
            SendToConsole("bind " .. GRENADE .. " throwgrenade")
            SendToConsole("bind " .. RELOAD .. " +reload")
            SendToConsole("bind " .. QUICK_SWAP .. " \"lastinv;viewmodel_update\"")
            SendToConsole("bind " .. COVER_MOUTH .. " +covermouth")
            SendToConsole("bind " .. MOVE_FORWARD .. " +forwardfixed")
            SendToConsole("bind " .. MOVE_BACK .. " +backfixed")
            SendToConsole("bind " .. MOVE_LEFT .. " +leftfixed")
            SendToConsole("bind " .. MOVE_RIGHT .. " +rightfixed")
            SendToConsole("bind " .. CROUCH .. " +iv_duck")
            SendToConsole("bind " .. SPRINT .. " +iv_sprint")
            SendToConsole("bind " .. PAUSE .. " pause")
            SendToConsole("bind " .. VIEWM_INSPECT .. " viewmodel_inspect_animation")
            SendToConsole("bind " .. ZOOM .. " +zoom")
            SendToConsole("bind " .. UNEQUIP_WEARABLE .. " novr_unequip_wearable")
            -- NOTE: Put additional custom bindings under here. Example:
            -- SendToConsole("bind X quit")
            SendToConsole("sv_noclipaccelerate 1")
            SendToConsole("hl2_sprintspeed 140")
            SendToConsole("hl2_normspeed 140")
            SendToConsole("r_drawviewmodel 0")
            SendToConsole("sv_infinite_aux_power 1")
            SendToConsole("cc_spectator_only 1")
            SendToConsole("sv_gameinstructor_disable 1")
            SendToConsole("hud_draw_fixed_reticle 0")
            SendToConsole("r_drawvgui 1")
            SendToConsole("ent_fire *_locker_door_* DisablePickup")
            SendToConsole("ent_fire *_hazmat_crate_lid DisablePickup")
            SendToConsole("ent_fire *electrical_panel_*_door* DisablePickup")
            SendToConsole("ent_fire *cabinet_door* DisablePickup")
            SendToConsole("ent_fire *panel_door* DisablePickup")
            SendToConsole("ent_fire *_washing_machine_door DisablePickup")
            SendToConsole("ent_fire *_washing_machine_loader DisablePickup")
            SendToConsole("ent_fire *_fridge_door_* DisablePickup")
            SendToConsole("ent_fire *_mailbox_*_door_* DisablePickup")
            SendToConsole("ent_fire *_dumpster_lid DisablePickup")
            SendToConsole("ent_fire *_portaloo_seat DisablePickup")
            SendToConsole("ent_fire *_drawer* DisablePickup")
            SendToConsole("ent_fire *_firebox_door DisablePickup")
            SendToConsole("ent_fire *_trashbin02_lid DisablePickup")
            SendToConsole("ent_fire *_car_door_rear DisablePickup")
            SendToConsole("ent_fire *_antenna_* DisablePickup")
            SendToConsole("ent_fire ticktacktoe_* DisablePickup")
            SendToConsole("ent_fire *_antique_globe DisablePickup")
            SendToConsole("ent_fire *_door1 DisablePickup")
            SendToConsole("ent_fire *_door2 DisablePickup")
            SendToConsole("ent_fire *_van_door_* DisablePickup")
            SendToConsole("ent_fire *_cage_door_* DisablePickup")
            SendToConsole("ent_fire firedoor DisablePickup")
            SendToConsole("ent_remove player_flashlight")
            SendToConsole("hl_headcrab_deliberate_miss_chance 0")
            SendToConsole("combine_grenade_timer 4")
            SendToConsole("sk_auto_reload_time 9999")
            SendToConsole("sv_gravity 500")
            SendToConsole("alias -covermouth \"ent_fire !player suppresscough 0;ent_fire_output @player_proxy OnPlayerUncoverMouth;ent_fire lefthand Disable;novr_uncover_mouth\"")
            SendToConsole("alias +covermouth \"ent_fire !player suppresscough 1;ent_fire_output @player_proxy OnPlayerCoverMouth;ent_fire lefthand Enable;novr_cover_mouth\"")
            SendToConsole("alias -customattack -iv_attack")
            SendToConsole("alias +customattack \"+iv_attack;usemultitool\"")
            SendToConsole("mouse_disableinput 0")
            SendToConsole("-attack")
            SendToConsole("-attack2")
            SendToConsole("-covermouth")
            SendToConsole("sk_headcrab_runner_health 69")
            SendToConsole("sk_antlion_worker_spit_interval_max 2")
            SendToConsole("sk_antlion_worker_spit_interval_min 1")
            SendToConsole("sk_antlion_worker_spit_speed 1200")
            SendToConsole("sk_plr_dmg_pistol 7")
            SendToConsole("sk_plr_dmg_ar2 9")
            SendToConsole("sk_plr_dmg_smg1 5")
            SendToConsole("hlvr_physcannon_forward_offset -5")
            SendToConsole("physcannon_tracelength 0")
            -- TODO: Lower this when picking up very low mass objects
            SendToConsole("player_throwforce 500")
            -- Add locked door handle animation
            ent = Entities:FindByClassname(nil, "prop_door_rotating_physics")
            while ent do
                ent:RedirectOutput("OnLockedUse", "PlayLockedDoorHandleAnimation", ent)
                ent = Entities:FindByClassname(ent, "prop_door_rotating_physics")
            end
            -- Disable func_tracktrain user control
            ent = Entities:FindByClassname(nil, "func_tracktrain")
            while ent do
                local name = ent:GetName()
                if name == "" then
                    name = "" .. thisEntity:GetEntityIndex()
                    ent:SetEntityName(name)
                end
                local traincontrols = SpawnEntityFromTableSynchronous("func_traincontrols", {["target"]=name})
                ent = Entities:FindByClassname(ent, "func_tracktrain")
            end
            -- Set crosshair
            SendToConsole("hud_draw_fixed_reticle 1")
            SendToConsole("crosshair 0")
            -- More pistol accuracy with laser sight
            if Entities:GetLocalPlayer():Attribute_GetIntValue("pistol_upgrade_lasersight", 0) == 1 then
                SendToConsole("pistol_use_new_accuracy 1")
            else
                SendToConsole("pistol_use_new_accuracy 0")
            end

            if Entities:FindByClassname(nil, "prop_hmd_avatar") then
                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="VR_SAVE_NOT_SUPPORTED"})
                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            end

            if not loading_save_file then
                if is_on_map_or_later("a2_quarantine_entrance") then
                    SendToConsole("give weapon_pistol")

                    if is_on_map_or_later("a2_pistol") then
                        SendToConsole("give weapon_physcannon")

                        if is_on_map_or_later("a2_drainage") then
                            SendToConsole("give weapon_shotgun")

                            if is_on_map_or_later("a3_hotel_street") then
                                SendToConsole("give weapon_ar2")
                            end
                        end
                    end
                end

                SendToConsole("ent_fire npc_barnacle AddOutput \"OnGrab>held_prop_dynamic_override>DisableCollision>>0>-1\"")
                SendToConsole("ent_fire npc_barnacle AddOutput \"OnRelease>held_prop_dynamic_override>EnableCollision>>0>-1\"")

                AddCollisionToPhysicsProps("prop_physics")
                AddCollisionToPhysicsProps("prop_physics_override")
            else
                if is_on_map_or_later("a2_pistol") then
                    SendToConsole("give weapon_physcannon")
                end

                ent = Entities:FindByClassname(nil, "info_hlvr_toner_port")
                while ent do
                    if ent:Attribute_GetIntValue("used", 0) == 1 then
                        ent:Attribute_SetIntValue("redraw_toner", 1)
                        DoEntFireByInstanceHandle(ent, "RunScriptFile", "multitool", 0, nil, nil)
                    end
                    ent = Entities:FindByClassname(ent, "info_hlvr_toner_port")
                end
            end

            -- Hand for covering mouth animation
            ent = Entities:FindByName(nil, "lefthand")
            local viewmodel = Entities:FindByClassname(nil, "viewmodel")
            if not ent then
                ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="lefthand", ["model"]="models/hands/alyx_glove_left.vmdl", ["disableshadows"]=true })
                ent:SetParent(viewmodel, "")
                DoEntFireByInstanceHandle(ent, "Disable", "", 0, nil, nil)
            end
            ent:SetAbsOrigin(viewmodel:GetOrigin() + RotatePosition(Vector(0, 0, 0), Entities:GetLocalPlayer():GetAngles(), Vector(4, 0, -3.5)))
            ent:SetLocalAngles(0, -90, 0)

            ent = Entities:GetLocalPlayer()
            if ent then
                ent:SetContextNum("headcrab_struggle_long", 1, 0)
                ent:SetContextNum("headcrab_post_struggle_long", 1, 0)

                local angles = ent:GetAngles()
                ent:SetThink(function()
                    Entities:GetLocalPlayer():SetOrigin(Entities:GetLocalPlayer():GetOrigin())
                end, "FixTiltedView", 1)
                local look_delta = QAngle(0, 0, 0)
                local move_delta = Vector(0, 0, 0)

                ent:SetThink(function()
                    if Convars:GetStr("weapon_in_crafting_station") ~= "" and Convars:GetStr("chosen_upgrade") == "" and Entities:FindByClassnameNearest("prop_hlvr_crafting_station", Entities:GetLocalPlayer():GetAbsOrigin(), 200) == nil then
                        SendToConsole("novr_crafting_station_cancel_upgrade")
                    end
                    return 1
                end, "ReturnFabricatorWeapon", 0)

                ent:SetThink(function()
                    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
                    local player = Entities:GetLocalPlayer()

                    if GetMapName() == "a3_c17_processing_plant" and player:Attribute_GetIntValue("activated_processing_plant_lift", 0) == 0 and player:GetAbsOrigin().z < 600 then
                        SendToConsole("snd_sos_start_soundevent Player.FallDamage")
                        SendToConsole("ent_fire !player SetHealth 0")
                        return nil
                    elseif GetMapName() == "a3_distillery" and Entities:FindByName(nil, "coughtalk_trigger") and player:GetAbsOrigin().y > 0 and player:GetAbsOrigin().z < 500 then
                        SendToConsole("snd_sos_start_soundevent Player.FallDamage")
                        SendToConsole("ent_fire !player SetHealth 0")
                        return nil
                    end

                    local barnacle_tounge = Entities:FindByClassnameNearest("npc_barnacle_tongue_tip", player:GetOrigin(), 28)
                    if barnacle_tounge then
                        SendToConsole("novr_unequip_wearable")
                    end

                    cvar_setf("player_use_radius", min(2200/abs(player:GetAngles().x),60))

                    if VectorDistanceSq(Vector(0, 0, 0), move_delta) > 100 then
                        table.insert(unstuck_table, player:GetOrigin())
                        if #unstuck_table > 100 then
                            table.remove(unstuck_table, 1)
                        end
                    end

                    local view_bob_x = sin(Time() * 8 % 6.28318530718) * move_delta.y * 0.0025
                    local view_bob_y = sin(Time() * 8 % 6.28318530718) * move_delta.x * 0.0025
                    local angle = player:GetAngles()
                    angle = QAngle(0, -angle.y, 0)
                    move_delta = RotatePosition(Vector(0, 0, 0), angle, player:GetVelocity())

                    local weapon_sway_x = RotationDelta(look_delta, viewmodel:GetAngles()).y * 0.07
                    local weapon_sway_y = RotationDelta(look_delta, viewmodel:GetAngles()).x * 0.07

                    look_delta = viewmodel:GetAngles()

                    -- Set weapon sway and view bob if zoom is not active
                    if cvar_getf("fov_ads_zoom") > FOV_ADS_ZOOM then
                        cvar_setf("viewmodel_offset_x", Lerp(0.06, cvar_getf("viewmodel_offset_x"), view_bob_x + weapon_sway_x))
                        cvar_setf("viewmodel_offset_y", Lerp(0.06, cvar_getf("viewmodel_offset_y"), view_bob_y + weapon_sway_y))
                    end

                    local shard = Entities:FindByClassnameNearest("shatterglass_shard", player:GetCenter(), 30)
                    if shard then
                        if not (GetMapName() == "a3_c17_processing_plant" and #Entities:FindAllByClassnameWithin("shatterglass_shard", player:GetCenter(), 100) == 1) then
                            DoEntFireByInstanceHandle(shard, "Break", "", 0, nil, nil)
                        end
                    end

                    if Entities:GetLocalPlayer():GetBoundingMaxs().z == 36 then
                        SendToConsole("cl_forwardspeed 86;cl_backspeed 86;cl_sidespeed 86")
                    else
                        SendToConsole("cl_forwardspeed 46;cl_backspeed 46;cl_sidespeed 46")
                    end
                    return 0
                end, "FixCrouchSpeed", 0)
            end

            SendToConsole("ent_remove text_quicksave")
            SendToConsole("ent_create env_message { targetname text_quicksave message GAMESAVED }")

            SendToConsole("ent_remove text_pistol_upgrade_aimdownsights")
            SendToConsole("ent_create env_message { targetname text_pistol_upgrade_aimdownsights message PISTOL_UPGRADE_AIMDOWNSIGHTS }")

            SendToConsole("ent_remove text_pistol_upgrade_burstfire")
            SendToConsole("ent_create env_message { targetname text_pistol_upgrade_burstfire message PISTOL_UPGRADE_BURSTFIRE }")

            SendToConsole("ent_remove text_shotgun_upgrade_doubleshot")
            SendToConsole("ent_create env_message { targetname text_shotgun_upgrade_doubleshot message SHOTGUN_UPGRADE_DOUBLESHOT }")

            SendToConsole("ent_remove text_shotgun_upgrade_grenadelauncher")
            SendToConsole("ent_create env_message { targetname text_shotgun_upgrade_grenadelauncher message SHOTGUN_UPGRADE_GRENADELAUNCHER }")

            SendToConsole("ent_remove text_smg_upgrade_aimdownsights")
            SendToConsole("ent_create env_message { targetname text_smg_upgrade_aimdownsights message SMG_UPGRADE_AIMDOWNSIGHTS }")

            SendToConsole("ent_remove text_resin")
            SendToConsole("ent_create game_text { targetname text_resin effect 2 spawnflags 1 color \"255 220 0\" holdtime 0.11 x 0.027 y -0.15 }")

            SendToConsole("ent_remove text_grenade")
            SendToConsole("ent_create env_message { targetname text_grenade message GRENADE }")

            SendToConsole("ent_remove text_syringe")
            SendToConsole("ent_create env_message { targetname text_syringe message SYRINGE }")

            SendToConsole("ent_remove text_wristpockets")
            SendToConsole("ent_create env_message { targetname text_wristpockets message WRISTPOCKETS }")

            SendToConsole("ent_remove text_crouchjump")
            SendToConsole("ent_create env_message { targetname text_crouchjump message CROUCHJUMP }")

            SendToConsole("ent_remove text_noclip")
            SendToConsole("ent_create env_message { targetname text_noclip message NOCLIP }")

            SendToConsole("ent_remove text_wearable")
            SendToConsole("ent_create env_message { targetname text_wearable message WEARABLE }")

            WristPockets_StartupPreparations()
            WristPockets_CheckPocketItemsOnLoading(Entities:GetLocalPlayer(), loading_save_file)
            Viewmodels_Init()
            if not loading_save_file then
                ViewmodelAnimation_LevelChange()
            end
            --HUDHearts_StartupPreparations()
            ViewmodelAnimation_ADSZoom()

            if is_on_map_or_later("a2_quarantine_entrance") then
                ent = Entities:GetLocalPlayer()
                --HUDHearts_StartUpdateLoop()
                WristPockets_StartUpdateLoop()

                -- Resin hud
                local player = Entities:GetLocalPlayer()
                player:SetThink(function()
                    local textEntity = Entities:FindByName(nil, "text_resin")
                    local t = {}
                    player:GatherCriteria(t)
                    DoEntFireByInstanceHandle(textEntity, "SetText", "Resin: " .. t.current_crafting_currency, 0, nil, nil)
                    DoEntFireByInstanceHandle(textEntity, "Display", "", 0.1, nil, nil)
                    return 0.1
                end, "Resin_UpdateLoop", 0)
            end

            if GetMapName() == "a1_intro_world" then
                if not loading_save_file then
                    SendToConsole("ent_fire player_speedmod ModifySpeed 0")
                    SendToConsole("mouse_disableinput 1")
                    SendToConsole("give weapon_bugbait")
                    SendToConsole("hidehud 4")
                    SendToConsole("bind " .. COVER_MOUTH .. " \"\"")
                    SendToConsole("ent_fire tv_apartment_decoy_door DisableCollision")

                    ent = Entities:FindByName(nil, "relay_start_intro_text")
                    ent:RedirectOutput("OnTrigger", "DisableUICursor", ent)
                    ent = Entities:FindByName(nil, "relay_start_dossier")
                    ent:RedirectOutput("OnTrigger", "DisableUICursor", ent)

                    ent = Entities:FindByName(nil, "relay_teleported_to_refuge")
                    ent:RedirectOutput("OnTrigger", "MoveFreely", ent)

                    SendToConsole("ent_create env_message { targetname text_quicksave_tutorial message QUICKSAVE }")
                    ent = Entities:FindByClassnameNearest("trigger_once", Vector(-240, 1688, 208), 20)
                    ent:RedirectOutput("OnTrigger", "ShowQuickSaveTutorial", ent)

                    ent = Entities:FindByName(nil, "prop_dogfood")
                    local angles = ent:GetAngles()
                    ent:SetAngles(180,angles.y,angles.z)
                    ent:SetOrigin(ent:GetOrigin() + Vector(0,0,10))

                    ent = Entities:FindByName(nil, "relay_heist_monitors_callincoming")
                    ent:RedirectOutput("OnTrigger", "ShowInteractTutorial", ent)

                    SendToConsole("ent_create env_message { targetname text_ladder message LADDER }")
                    ent = Entities:FindByName(nil, "51_ladder_hint_trigger")
                    ent:RedirectOutput("OnTrigger", "ShowLadderTutorial", ent)

                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="light_switch_1", ["solid"]=6, ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="-541.6 1770.1 133.4", ["angles"]="0 0 0", ["modelscale"]=2})
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="light_switch_2", ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="-903.2 1691.6 111", ["angles"]="0 0 0", ["modelscale"]=2})

                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="washing_machine_button_1", ["solid"]=6, ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="1473.99 -853.165 -347.75", ["angles"]="0 0 0", ["modelscale"]=2})
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="washing_machine_button_2", ["solid"]=6, ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="1393.17 -923.015 -347.75", ["angles"]="0 0 0", ["modelscale"]=2})
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="washing_machine_button_3", ["solid"]=6, ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="1393.17 -952.015 -347.75", ["angles"]="0 0 0", ["modelscale"]=2})
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["targetname"]="washing_machine_button_4", ["solid"]=6, ["renderamt"]=0, ["model"]="models/props/lightswitch_2_switch.vmdl", ["origin"]="1396.98 -982.97 -347.75", ["angles"]="0 0 0", ["modelscale"]=2})

                    SendToConsole("ent_fire 563_vent_door DisablePickup")
                    SendToConsole("ent_fire 563_vent_phys_hinge SetOffset 0.1")

                    -- TODO: Remove when Map Edits are done
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="640 -1770 -210", ["angles"]="0 -10 0", ["modelscale"]=0.75})
                    ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="-233 1772 182", ["angles"]="90 0 0"})
                else
                    MoveFreely()
                end
            elseif GetMapName() == "a1_intro_world_2" then
                if not loading_save_file then
                    ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER1_TITLE"})
                    DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                    SendToConsole("ent_create env_message { targetname text_sprint message SPRINT }")
                    SendToConsole("ent_create env_message { targetname text_crouch message CROUCH }")
                    SendToConsole("ent_create env_message { targetname text_pick_up message PICK_UP }")
                    SendToConsole("ent_create env_message { targetname text_gg message GRAVITYGLOVES }")
                    SendToConsole("ent_create env_message { targetname text_shoot message SHOOT }")

                    SendToConsole("ent_fire russell_entry_window SetCompletionValue 0.4")

                    SendToConsole("ent_fire car_door_rear DisablePickup")
                end

                ent = Entities:GetLocalPlayer()
                if ent:Attribute_GetIntValue("pistol", 0) == 0 then
                    if ent:Attribute_GetIntValue("gravity_gloves", 0) == 0 then
                        SendToConsole("hidehud 96")
                    else
                        SendToConsole("hidehud 0")
                        ent:SetThink(function()
                            SendToConsole("hidehud 1")
                        end, "", 0)
                    end
                    SendToConsole("give weapon_bugbait")
                else
                    SendToConsole("hidehud 64")
                    SendToConsole("r_drawviewmodel 1")
                end

                -- Show hud hearts if player picked up the gravity gloves
                if ent:Attribute_GetIntValue("gravity_gloves", 0) ~= 0 then
                    --HUDHearts_StartUpdateLoop()
                    WristPockets_StartUpdateLoop()
                end

                SendToConsole("combine_grenade_timer 7")

                if not loading_save_file then
                    ent = Entities:FindByName(nil, "trigger_post_gate")
                    ent:RedirectOutput("OnTrigger", "ShowSprintTutorial", ent)

                    ent = Entities:FindByName(nil, "@hint_crouch_locker_trigger")
                    ent:RedirectOutput("OnStartTouch", "ShowCrouchTutorial", ent)

                    ent = Entities:FindByName(nil, "timer_figure_nag")
                    ent:RedirectOutput("OnTimer", "ShowPickUpTutorial", ent)

                    ent = Entities:FindByName(nil, "gg_training_start_trigger")
                    ent:RedirectOutput("OnTrigger", "ShowGravityGlovesTutorial", ent)

                    ent = Entities:FindByName(nil, "gate_ammo_trigger")
                    local origin = ent:GetOrigin()
                    local angles = ent:GetAngles()
                    ent = SpawnEntityFromTableSynchronous("trigger_detect_bullet_fire", {["model"]="maps/a1_intro_world_2/entities/gate_ammo_trigger_621_2249_345.vmdl", ["origin"]= origin.x .. " " .. origin.y .. " " .. origin.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z})
                    ent:RedirectOutput("OnDetectedBulletFire", "CheckTutorialPistolEmpty", ent)

                    ent = Entities:FindByName(nil, "hint_crouch_trigger")
                    ent:RedirectOutput("OnStartTouch", "GetOutOfCrashedVan", ent)

                    ent = Entities:FindByName(nil, "relay_weapon_pistol_fakefire")
                    ent:RedirectOutput("OnTrigger", "RedirectPistol", ent)
                end
            else
                SendToConsole("hidehud 64")
                SendToConsole("r_drawviewmodel 1")
                Entities:GetLocalPlayer():Attribute_SetIntValue("gravity_gloves", 1)

                if GetMapName() == "a2_quarantine_entrance" then
                    if not loading_save_file then
                        -- Default Junction Rotations
                        Entities:FindByName(nil, "toner_junction_1"):Attribute_SetIntValue("junction_rotation", 1)
                        Entities:FindByName(nil, "toner_junction_2"):Attribute_SetIntValue("junction_rotation", 1)
                        Entities:FindByName(nil, "toner_junction_3"):Attribute_SetIntValue("junction_rotation", 1)

                        ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="-1298 2480 280", ["angles"]="0 22 0", ["modelscale"]=10})
                        ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="-1100 2180 280", ["angles"]="0 22 0", ["modelscale"]=10})
                        ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="-1312 2504 280", ["angles"]="0 -67 0", ["modelscale"]=2})

                        ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER2_TITLE"})
                        DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                        ent = Entities:FindByName(nil, "28677_hint_mantle_delay")
                        ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

                        ent = Entities:FindByName(nil, "toner_trigger")
                        ent:RedirectOutput("OnTrigger", "ShowMultiToolTutorial", ent)

                        SendToConsole("ent_create env_message { targetname text_holdinteract message HOLD_INTERACT }")
                        SendToConsole("ent_create env_message { targetname text_multitool_equip message MULTITOOL_EQUIP }")
                        SendToConsole("ent_create env_message { targetname text_multitool_use message MULTITOOL_USE }")
                        SendToConsole("ent_create env_message { targetname text_hacking_puzzle_trace message HACKING_PUZZLE_TRACE }")

                        SendToConsole("setpos 3215 2456 465")
                        SendToConsole("ent_fire traincar_border_trigger Disable")
                    end
                elseif GetMapName() == "a2_pistol" then
                    if not loading_save_file then
                        ent = Entities:FindByName(nil, "trigger_if_player_navs_over_boards")
                        ent:RedirectOutput("OnTrigger", "ShowBreakBoardsTutorial", ent)

                        SendToConsole("ent_create env_message { targetname text_break_boards message BREAK_BOARDS }")

                        SendToConsole("ent_fire *_rebar EnablePickup")
                    end
                elseif GetMapName() == "a2_headcrabs_tunnel" then
                    if not loading_save_file then
                        -- Default Junction Rotations
                        Entities:FindByName(nil, "toner_junction_1"):Attribute_SetIntValue("junction_rotation", 1)
                        Entities:FindByName(nil, "toner_junction_2"):Attribute_SetIntValue("junction_rotation", 1)

                        ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER3_TITLE"})
                        DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                        ent = Entities:FindByName(nil, "13988_wooden_board")
                        DoEntFireByInstanceHandle(ent, "Break", "", 0, nil, nil)
                        ent = Entities:FindByName(nil, "13989_wooden_board")
                        DoEntFireByInstanceHandle(ent, "Break", "", 0, nil, nil)
                        ent = Entities:FindByName(nil, "13990_wooden_board")
                        DoEntFireByInstanceHandle(ent, "Break", "", 0, nil, nil)

                        ent = SpawnEntityFromTableSynchronous("prop_physics_override", {["targetname"]="shotgun_pickup_blocker", ["parentname"]="12712_intro_shotgun", ["CollisionGroupOverride"]=5, ["renderamt"]=0, ["model"]="models/hacking/holo_hacking_sphere_prop.vmdl", ["modelscale"]=2})
                        ent:SetLocalOrigin(Vector(0, 0, 0))
                        DoEntFireByInstanceHandle(ent, "DisablePickup", "", 0, nil, nil)

                        Entities:FindByName(nil, "12712_shotgun_wheel"):Attribute_SetIntValue("used", 1)
                        ent = Entities:FindByName(nil, "12712_293_relay_zombies_hitting_wall")
                        ent:RedirectOutput("OnTrigger", "EnableShotgunWheel", ent)

                        ent = Entities:FindByName(nil, "15493_hint_mantle_delay")
                        ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

                        ent = Entities:FindByClassnameNearest("trigger_once", Vector(-746, -943, -92), 10)
                        ent:Kill()
                    end

                    ent = Entities:GetLocalPlayer()
                    if ent:Attribute_GetIntValue("has_flashlight", 0) == 1 then
                        SendToConsole("bind " .. FLASHLIGHT .. " inv_flashlight")
                    end
                elseif GetMapName() == "a2_hideout" then
                    if not loading_save_file then
                        ent = Entities:FindByName(nil, "8271_button_counter")
                        ent:RedirectOutput("OnHitMax", "DisableHideoutPuzzleButtons", ent)

                        ent = Entities:FindByName(nil, "8271_relay_reset_buttons")
                        ent:RedirectOutput("OnTrigger", "ResetHideoutPuzzleButtons", ent)

                        ent = Entities:FindByName(nil, "2861_4065_hint_mantle_delay")
                        ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

                        ent = Entities:FindByName(nil, "13987_hint_mantle_delay")
                        ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

                        ent = Entities:FindByName(nil, "relay_open_gate")
                        ent:RedirectOutput("OnTrigger", "OpenHideoutGate", ent)

                        ent = Entities:FindByName(nil, "exit_barrier")
                        local angles = ent:GetAngles()
                        local pos = ent:GetAbsOrigin()
                        local child = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["targetname"]="hideout_gate_prop", ["CollisionGroupOverride"]=5, ["solid"]=6, ["DefaultAnim"]="vort_barrier_start_idle", ["renderamt"]=0, ["model"]=ent:GetModelName(), ["origin"]= pos.x .. " " .. pos.y .. " " .. pos.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z - 20})
                        child:SetParent(ent, "")
                    end
                else
                    SendToConsole("bind " .. FLASHLIGHT .. " inv_flashlight")

                    if GetMapName() == "a2_drainage" then
                        if not loading_save_file then
                            SendToConsole("ent_fire math_count_wheel2_installment AddOutput \"OnChangedFromMin>relay_install_wheel2>Trigger>>0>1\"")
                            SendToConsole("ent_fire math_count_wheel_installment AddOutput \"OnChangedFromMin>relay_install_wheel>Trigger>>0>1\"")
                            SendToConsole("ent_fire wheel_physics DisablePickup")
                            ent = Entities:FindByClassnameNearest("npc_barnacle", Vector(941, -1666, 255), 10)
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnRelease>wheel_physics>EnablePickup>>0>1", 0, nil, nil)

                            -- Detect shooting so Russell warns you
                            ent = SpawnEntityFromTableSynchronous("trigger_detect_bullet_fire", {["targetname"]="bullet_trigger", ["StartDisabled"]=true, ["modelscale"]=1000, ["model"]="models/hacking/holo_hacking_sphere_prop.vmdl"})
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnDetectedBulletFire>player_speak>SpeakConcept>speech:gunshot_warning>0>1", 0, nil, nil)
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnDetectedBulletFire>!self>Kill>>0>1", 0, nil, nil)

                            ent = Entities:FindByName(nil, "trigger_gunshot_listener")
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnTrigger>bullet_trigger>Enable>>0>1", 0, nil, nil)

                            ent = Entities:FindByName(nil, "trigger_disable_listener")
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnTrigger>bullet_trigger>Kill>>0>1", 0, nil, nil)
                        end
                    elseif GetMapName() == "a2_train_yard" then
                        ent = Entities:FindByName(nil, "relay_train_will_crash")
                        ent:RedirectOutput("OnTrigger", "DisableTrainLever", ent)

                        ent = Entities:FindByName(nil, "mission_fail_relay")
                        ent:RedirectOutput("OnTrigger", "FailMission", ent)

                        ent = Entities:FindByName(nil, "eli_rescue_3")
                        ent:RedirectOutput("OnCompletion", "ReachForEli", ent)

                        if not loading_save_file then
                            -- Default Junction Rotations
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_0_0"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_0_1"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_0_2"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_1_0"):Attribute_SetIntValue("junction_rotation", 2)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_1_2"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_2_1"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "5325_4704_train_gate_junction_2_2"):Attribute_SetIntValue("junction_rotation", 1)

                            ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/industrial_door_1_40_92_white_temp.vmdl", ["origin"]="-1080 3200 -350", ["angles"]="0 12 0", ["modelscale"]=5, ["targetname"]="elipreventfall"})
                            ent = Entities:FindByName(nil, "eli_rescue_3_relay")
                            ent:RedirectOutput("OnTrigger", "RemoveEliPreventFall", ent)
                        end
                    elseif GetMapName() == "a3_hotel_interior_rooftop" then
                        if not loading_save_file then
                            ent = SpawnEntityFromTableSynchronous("item_hlvr_prop_battery", {["origin"]="2045 -1717 886"})

                            -- TODO: Remove when Map Edits are done
                            ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["solid"]=6, ["renderamt"]=0, ["model"]="models/architecture/metal_siding/metal_siding_32_a.vmdl", ["origin"]="2320 -1854 834", ["angles"]="0 0 0", ["modelscale"]=0.5})
                        end
                    elseif GetMapName() == "a3_station_street" then
                        if not loading_save_file then
                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER4_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                            ent = Entities:FindByName(nil, "door")
                            DoEntFireByInstanceHandle(ent, "SetOpenDirection", "" .. 2, 0, nil, nil)
                        end
                    elseif GetMapName() == "a3_hotel_lobby_basement" then
                        Entities:FindByName(nil, "power_stake_2_start"):Attribute_SetIntValue("used", 1)

                        if not loading_save_file then
                            -- Default Junction Rotations
                            Entities:FindByName(nil, "junction_2"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "junction_2_panel"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "junction_3"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "toner_junction_4"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "junction_5"):Attribute_SetIntValue("junction_rotation", 2)
                            Entities:FindByName(nil, "junction_6"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "junction_7"):Attribute_SetIntValue("junction_rotation", 1)

                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER5_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                            ent = Entities:FindByName(nil, "power_stake_1_start")
                            ent:Attribute_SetIntValue("used", 1)

                            ent = Entities:FindByName(nil, "417_149_powerunit_relay_battery_inserted")
                            ent:RedirectOutput("OnTrigger", "EnableHotelLobbyPower", ent)

                            ent = Entities:FindByName(nil, "base_dropdown_template_1")
                            ent:RedirectOutput("OnEntitySpawned", "DisableBarnacleAmmoPickup", ent)
                        end
                    elseif GetMapName() == "a3_hotel_underground_pit" then
                        ent = Entities:FindByClassnameNearest("prop_door_rotating_physics", Vector(2012, -1571, 408), 10)
                        DoEntFireByInstanceHandle(ent, "SetOpenDirection", "1", 0, nil, nil)
                    elseif GetMapName() == "a3_hotel_street" then
                        if not loading_save_file then
                            -- Default Junction Rotations
                            Entities:FindByName(nil, "junction_1"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "junction_4"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "junction_5"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "junction_7"):Attribute_SetIntValue("junction_rotation", 2)

                            Entities:FindByName(nil, "elev_anim_door"):Attribute_SetIntValue("toggle", 1)

                            ent = Entities:FindByName(nil, "elev_anim_door")
                            ent:Attribute_SetIntValue("used", 1)
                            ent = Entities:FindByName(nil, "ss_elevator_move")
                            ent:RedirectOutput("OnEndSequence", "EnableStreetElevatorDoor", ent)

                            ent = Entities:FindByName(nil, "167_18945_hint_multitool_on_tripmine_trigger_1")
                            ent:RedirectOutput("OnTrigger", "ShowCrouchJumpTutorial", ent)

                            ent = Entities:FindByClassnameNearest("prop_door_rotating_physics", Vector(780, 1614, 336), 10)
                            ent:RedirectOutput("OnOpen", "ExplodeFirstDoorMine", ent)

                            ent = Entities:FindByName(nil, "167_18697_tripmine_trap_door_1")
                            DoEntFireByInstanceHandle(ent, "SetOpenDirection", "" .. 2, 0, nil, nil)
                        end

                        SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")

                        ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(775, 1677, 248), 10)
                        if ent then
                            ent:Kill()
                        end
                        ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(1440, 1306, 331), 10)
                        if ent then
                            ent:Kill()
                        end
                        ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(1657.083, 595.287, 426), 10)
                        if ent then
                            ent:SetOrigin(Vector(1657.083, 595.287, 400))
                        end
                    elseif GetMapName() == "a3_c17_processing_plant" then
                        SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")

                        if not loading_save_file then
                            -- Default Junction Rotations
                            Entities:FindByName(nil, "shack_path_3_junction_1"):Attribute_SetIntValue("junction_rotation", 3)
                            Entities:FindByName(nil, "shack_path_6_junction_2"):Attribute_SetIntValue("junction_rotation", 2)
                            Entities:FindByName(nil, "shack_path_11_junction_1"):Attribute_SetIntValue("junction_rotation", 1)

                            ent = SpawnEntityFromTableSynchronous("prop_dynamic", {["solid"]=6, ["renderamt"]=0, ["model"]="models/props/construction/construction_yard_lift.vmdl", ["origin"]="-1984 -2456 154", ["angles"]="0 270 0", ["parentname"]="pallet_crane_platform"})

                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER6_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                            SendToConsole("ent_fire vent_door DisablePickup")

                            ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-896, -3768, 348), 10)
                            if ent then
                                ent:Kill()
                            end

                            ent = Entities:FindByClassnameNearest("trigger_once", Vector(-1456, -3960, 224), 10)
                            ent:RedirectOutput("OnTrigger", "SetupMineRoom", ent)

                            ent = Entities:FindByName(nil, "shack_path_6_port_1_enable")
                            ent:RedirectOutput("OnTrigger", "EnableShackToner", ent)
                            Entities:FindByName(nil, "shack_path_6_port_1"):Attribute_SetIntValue("used", 1)
                            Entities:FindByName(nil, "shack_path_1_port_1"):Attribute_SetIntValue("used", 1)

                            SendToConsole("ent_fire pallet_move_linear SetMoveDistanceFromStart 115")
                        end
                    elseif GetMapName() == "a3_distillery" then
                        ent = Entities:FindByName(nil, "exit_counter")
                        ent:RedirectOutput("OnHitMax", "EnablePlugLever1", ent)

                        ent = Entities:FindByName(nil, "11578_2420_181_relay_unlock_controls")
                        ent:RedirectOutput("OnTrigger", "EnablePlugLever2", ent)

                        ent = Entities:FindByName(nil, "11578_2420_183_relay_unlock_controls")
                        ent:RedirectOutput("OnTrigger", "EnablePlugLever3", ent)

                        ent = Entities:FindByName(nil, "@branch_bz_locked_up")
                        ent:RedirectOutput("OnTrue", "EnablePlugLever4", ent)

                        ent = Entities:FindByName(nil, "11578_2420_183_relay_control_reset")
                        ent:RedirectOutput("OnTrigger", "EnablePlugLever1", ent)

                        if not loading_save_file then
                            -- Default Junction Rotations
                            Entities:FindByName(nil, "freezer_toner_junction_1"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "freezer_toner_junction_2"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "freezer_toner_junction_5"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "freezer_toner_junction_5a"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "freezer_toner_junction_6"):Attribute_SetIntValue("junction_rotation", 1)
                            Entities:FindByName(nil, "freezer_toner_junction_7"):Attribute_SetIntValue("junction_rotation", 1)

                            Entities:FindByName(nil, "freezer_toner_junction_2"):SetOrigin(Vector(460.1, 444.5, 302))

                            ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER7_TITLE"})
                            DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                            ent = Entities:FindByName(nil, "11478_6250_locked_door_relay_break_lock")
                            ent:RedirectOutput("OnTrigger", "FixJeffBatteryPuzzle", ent)

                            SendToConsole("ent_create env_message { targetname text_covermouth message COVERMOUTH }")
                            ent = Entities:FindByName(nil, "11632_223_cough_volume")
                            ent:RedirectOutput("OnStartTouch", "ShowCoverMouthTutorial", ent)

                            SendToConsole("ent_fire timer_gun_equipped Kill")
                            SendToConsole("ent_fire timer_gun_equipped_b Kill")
                            ent = Entities:FindByName(nil, "vcd_larry_talk_01")
                            ent:RedirectOutput("OnCompletion", "LarrySeesGun", ent)

                            ent = Entities:FindByName(nil, "spawner_larry_hat_sound_target")
                            ent:RedirectOutput("OnEntitySpawned", "LarrySeesWearable", ent)

                            ent = Entities:FindByName(nil, "freezer_toner_outlet_1")
                            ent:Attribute_SetIntValue("disabled", 1)
                            ent:Attribute_SetIntValue("used", 1)

                            ent = Entities:FindByName(nil, "11479_elevator_busted_doors_relay")
                            ent:RedirectOutput("OnTrigger", "EnableJeffElevatorDoorToner", ent)

                            ent = Entities:FindByClassnameNearest("prop_handpose", Vector(925, 1102, 578), 50)
                            if ent then
                                DoEntFireByInstanceHandle(ent, "Kill", "", 0, nil, nil)
                            end

                            -- TODO: Fix error model for this plank
                            -- ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["solid"]=6, ["modelscale"]=0.9, ["model"]="models/rural/barn_loose_boards_03.vmdl", ["origin"]="196 40 546.5", ["angles"]="3 0 0"})

                            -- Detect shooting so Jeff hears it
                            ent = SpawnEntityFromTableSynchronous("trigger_detect_bullet_fire", {["targetname"]="bullet_trigger", ["modelscale"]=1000, ["model"]="models/hacking/holo_hacking_sphere_prop.vmdl"})
                            DoEntFireByInstanceHandle(ent, "AddOutput", "OnDetectedBulletFire>!player>GenerateBlindZombieSound>>0>-1", 0, nil, nil)
                        end
                    else
                        if GetMapName() == "a4_c17_zoo" then
                            if not loading_save_file then
                                -- Default Junction Rotations
                                Entities:FindByName(nil, "health_trap_static_t2"):Attribute_SetIntValue("junction_rotation", 2)
                                Entities:FindByName(nil, "junction_health_trap_3"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "junction_health_trap_split"):Attribute_SetIntValue("junction_rotation", 3)
                                Entities:FindByName(nil, "589_junction_1"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "589_junction_3"):Attribute_SetIntValue("junction_rotation", 2)
                                Entities:FindByName(nil, "589_junction_4"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "589_junction_7"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "589_junction_bc"):Attribute_SetIntValue("junction_rotation", 1)

                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER8_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                                ent = Entities:FindByClassnameNearest("npc_barnacle", Vector(5126, -1957, 64), 10)
                                DoEntFireByInstanceHandle(ent, "AddOutput", "OnRelease>tiger_mask>EnablePickup>>0>1", 0, nil, nil)
                            end

                            ent = Entities:FindByName(nil, "relay_power_receive")
                            ent:RedirectOutput("OnTrigger", "MakeLeverUsable", ent)

                            ent = Entities:FindByClassnameNearest("trigger_multiple", Vector(5380, -1848, -117), 10)
                            ent:RedirectOutput("OnStartTouch", "CrouchThroughZooHole", ent)

                            SendToConsole("ent_fire port_health_trap Disable")
                            SendToConsole("ent_fire health_trap_locked_door Unlock")
                            SendToConsole("ent_fire 589_toner_port_5 Disable")
                            SendToConsole("ent_fire @prop_phys_portaloo_door DisablePickup")

                            SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")
                        elseif GetMapName() == "a4_c17_tanker_yard" then
                            SendToConsole("ent_fire elev_hurt_player_* Kill")

                            if Entities:GetLocalPlayer():Attribute_GetIntValue("eavesdropping", 0) == 1 then
                                SendToConsole("bind " .. PRIMARY_ATTACK .. " \"\"")
                                SendToConsole("bind " .. SECONDARY_ATTACK .. " \"\"")
                                SendToConsole("bind " .. TERTIARY_ATTACK .. " \"\"")
                                SendToConsole("bind " .. FLASHLIGHT .. " \"\"")
                                SendToConsole("hidehud 4")
                            end

                            if not loading_save_file then
                                -- Default Junction Rotations
                                Entities:FindByName(nil, "1489_4074_junction_demux_1_1"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "1489_4074_junction_demux_2_1"):Attribute_SetIntValue("junction_rotation", 1)
                                Entities:FindByName(nil, "1489_4074_junction_demux_2_2"):Attribute_SetIntValue("junction_rotation", 1)

                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER9_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                                ent = Entities:FindByClassnameNearest("trigger_once", Vector(6243, 4212, 612), 20)
                                ent:RedirectOutput("OnTrigger", "StartRevealEavesdrop", ent)

                                ent = Entities:FindByName(nil, "eavesdrop_mystery")
                                ent:RedirectOutput("OnTrigger2", "StopRevealEavesdrop", ent)

                                ent = Entities:FindByName(nil, "elevator_path_1")
                                ent:RedirectOutput("OnPass", "EnableToiletElevatorLever", ent)

                                ent = Entities:FindByName(nil, "elev_trigger_player_inside")
                                ent:SetOrigin(ent:GetOrigin() + Vector(0,0,50))
                                ent = Entities:FindByName(nil, "elev_trigger_player_inside_outer_trigger")
                                ent:SetOrigin(ent:GetOrigin() + Vector(0,0,50))

                                ent = Entities:FindByName(nil, "waste_vial_template_1")
                                ent:RedirectOutput("OnEntitySpawned", "DisableBarnacleHealthVialPickup", ent)

                                ent = Entities:FindByName(nil, "antlion_tanker_spitter_01")
                                ent:SetAbsOrigin(Vector(3310.622, 6371.935, 100))

                                SendToConsole("ent_fire @prop_phys_portaloo_door DisablePickup")
                                SendToConsole("ent_fire elev_exit_teleport_clip Kill")
                            end
                        elseif GetMapName() == "a4_c17_water_tower" then
                            if not loading_save_file then
                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER10_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
                            end
                        elseif GetMapName() == "a4_c17_parking_garage" then
                            if loading_save_file then
                                SendToConsole("novr_leavecombinegun") -- avoid softlock
                            else
                                ent = Entities:FindByName(nil, "falling_cabinet_door")
                                DoEntFireByInstanceHandle(ent, "DisablePickup", "", 0, nil, nil)

                                SendToConsole("ent_fire func_physbox DisableMotion")

                                ent = Entities:FindByName(nil, "relay_enter_ufo_beam")
                                ent:RedirectOutput("OnTrigger", "EnterVaultBeam", ent)

                                SendToConsole("ent_fire combine_gun_grab_handle ClearParent aim_gun")
                                SendToConsole("ent_fire combine_gun_grab_handle SetParent combine_gun_mechanical") -- attach one of gun handles to the main model

                                ent = Entities:FindByName(nil, "relay_shoot_gun")
                                ent:RedirectOutput("OnTrigger", "CombineGunHandleAnim", ent)
                            end
                            Convars:RegisterCommand("novr_shootcombinegun", function()
                                ent = Entities:FindByName(nil, "combine_gun_interact")
                                if ent:Attribute_GetIntValue("ready", 0) == 1 then
                                    SendToConsole("ent_fire relay_shoot_gun trigger")
                                    ent:Attribute_SetIntValue("ready", 0)
                                end
                            end, "", 0)
                            Convars:RegisterCommand("novr_leavecombinegun", function()
                                ent = Entities:FindByName(nil, "combine_gun_interact")
                                if ent:Attribute_GetIntValue("active", 0) == 1 then
                                    ent:StopThink("UsingCombineGun")
                                    ent:FireOutput("OnInteractStop", nil, nil, nil, 0)
                                    local gunAngle = ent:LoadQAngle("OrigAngle")
                                    ent:SetAngles(gunAngle.x,gunAngle.y,gunAngle.z)
                                    ent:Attribute_SetIntValue("active", 0)
                                    SendToConsole("ent_fire combine_gun_mechanical enablecollision")
                                    SendToConsole("ent_fire player_speedmod ModifySpeed 1")
                                    SendToConsole("bind " .. PRIMARY_ATTACK .. " \"+customattack;viewmodel_update\"")
                                    SendToConsole("r_drawviewmodel 1")
                                    SendToConsole("unbind J")
                                end
                            end, "", 0)
                        elseif GetMapName() == "a5_vault" then
                            SendToConsole("ent_fire player_speedmod ModifySpeed 1")
                            SendToConsole("use weapon_bugbait")
                            SendToConsole("r_drawviewmodel 0")
                            ent:SetThink(function()
                                SendToConsole("hidehud 67")
                            end, "", 0)

                            if not loading_save_file then
                                Entities:GetLocalPlayer():Attribute_SetIntValue("grenade", 0)
                                Entities:GetLocalPlayer():Attribute_SetIntValue("pistol_upgrade_aimdownsights", 0)

                                ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="CHAPTER11_TITLE"})
                                DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)

                                SendToConsole("ent_create env_message { targetname text_vortenergy message VORTENERGY }")

                                SendToConsole("ent_fire upsidedownroom_closetdoor* DisablePickup")

                                SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2;ent_remove weapon_smg1;ent_remove weapon_physcannon")
                                SendToConsole("give weapon_bugbait")

                                ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["CollisionGroupOverride"]=5, ["solid"]=6, ["model"]="models/architecture/doors_1/door_1b_40_92.vmdl", ["origin"]="-835 160 -539", ["angles"]="76 110 10"})
                                ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["renderamt"]=0, ["CollisionGroupOverride"]=5, ["solid"]=6, ["model"]="models/architecture/doors_1/door_1b_40_92.vmdl", ["origin"]="70 2881 -549", ["angles"]="90 90 0"})

                                ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["CollisionGroupOverride"]=5, ["solid"]=6, ["model"]="models/props/oldstyle_table_2.vmdl", ["origin"]="-345 2881 -695", ["angles"]="45 0 -90"})
                                ent = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["CollisionGroupOverride"]=5, ["solid"]=6, ["model"]="models/props/oldstyle_table_2.vmdl", ["origin"]="-260 2881 -640", ["angles"]="45 0 -90"})

                                ent = Entities:FindByName(nil, "longcorridor_outerdoor1")
                                ent:RedirectOutput("OnFullyClosed", "GiveVortEnergy", ent)
                                ent:RedirectOutput("OnFullyClosed", "ShowVortEnergyTutorial", ent)

                                ent = Entities:FindByName(nil, "longcorridor_innerdoor")
                                ent:RedirectOutput("OnFullyClosed", "RemoveVortEnergy", ent)

                                ent = Entities:FindByName(nil, "longcorridor_energysource_01_activate_relay")
                                ent:RedirectOutput("OnTrigger", "GiveVortEnergy", ent)
                            else
                                if Entities:GetLocalPlayer():Attribute_GetIntValue("vort_energy", 0) == 1 then
                                    GiveVortEnergy()
                                end
                            end
                        elseif GetMapName() == "a5_ending" then
                            SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2;ent_remove weapon_smg1;ent_remove weapon_frag;ent_remove weapon_physcannon")
                            SendToConsole("use weapon_bugbait")
                            SendToConsole("r_drawviewmodel 0")
                            ent:SetThink(function()
                                SendToConsole("hidehud 67")
                            end, "", 0)
                            SendToConsole("bind " .. FLASHLIGHT .. " \"\"")
                            SendToConsole("bind " .. COVER_MOUTH .. " \"\"")
                            Entities:GetLocalPlayer():Attribute_SetIntValue("grenade", 0)

                            ent = Entities:FindByName(nil, "timer_briefcase")
                            DoEntFireByInstanceHandle(ent, "RefireTime", "5", 0, nil, nil)

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

        SendToConsole("mouse_invert_y " .. tostring(INVERT_MOUSE_Y))

        SendToConsole("bind " .. CONSOLE .. " +toggleconsole")
    end, nil)

    function PlayerDied()
        SendToServerConsole("unpause")
        --HUDHearts_StopUpdateLoop()
        WristPockets_StopUpdateLoop()
        SendToConsole("disable_flashlight")
    end

    function GoToMainMenu(a, b)
        if Convars:GetBool("vr_enable_fake_vr") then
            SendToConsole("vr_enable_fake_vr 0;vr_enable_fake_vr 0")
            SendToConsole("setpos_exact 817 -80 6")
        else
            SendToConsole("setpos_exact 817 -80 -26")
        end
        SendToConsole("setang_exact 0.4 0 0")
        SendToConsole("mouse_disableinput 0")
        SendToConsole("hidehud 96")
    end

    function MoveFreely(a, b)
        SendToConsole("mouse_disableinput 0")
        SendToConsole("ent_fire player_speedmod ModifySpeed 1")
        SendToConsole("hidehud 96")
        SendToConsole("bind " .. COVER_MOUTH .. " +covermouth")
    end

    function DisableUICursor(a, b)
        SendToConsole("ent_fire point_clientui_world_panel IgnoreUserInput")
    end

    function GetOutOfCrashedVan(a, b)
        SendToConsole("fadein 0.2")
        SendToConsole("setpos_exact -1408 2307 -114")
        SendToConsole("ent_fire 4962_car_door_left_front open")
    end

    function RedirectPistol(a, b)
        ent = Entities:FindByName(nil, "weapon_pistol")
        ent:RedirectOutput("OnPlayerPickup", "EquipPistol", ent)
    end

    function GivePistol(a, b)
        SendToConsole("ent_fire pistol_give_relay trigger")
    end

    function EquipPistol(a, b)
        SendToConsole("ent_fire_output weapon_equip_listener OnEventFired")
        SendToConsole("hidehud 64")
        SendToConsole("r_drawviewmodel 1")
        SendToConsole("ent_fire item_hlvr_weapon_energygun kill")
        Entities:GetLocalPlayer():Attribute_SetIntValue("pistol", 1)
    end

    function DisableHideoutPuzzleButtons(a, b)
        ent = Entities:FindByClassname(nil, "func_physical_button")
        while ent do
            ent:Attribute_SetIntValue("used", 1)
            ent = Entities:FindByClassname(ent, "func_physical_button")
        end
    end

    function ResetHideoutPuzzleButtons(a, b)
        ent = Entities:FindByClassname(nil, "func_physical_button")
        ent:SetThink(function()
            while ent do
                ent:Attribute_SetIntValue("used", 0)
                ent = Entities:FindByClassname(ent, "func_physical_button")
            end
        end, "", 3)
    end

    function EnableShotgunWheel(a, b)
        Entities:FindByName(nil, "12712_shotgun_wheel"):Attribute_SetIntValue("used", 0)
    end

    function DisableTrainLever(a, b)
        Entities:GetLocalPlayer():Attribute_SetIntValue("released_train_lever_once", 1)
    end

    function FailMission()
        SendToConsole("ent_fire player_speedmod ModifySpeed 0")
        SendToConsole("mouse_disableinput 1")
        SendToConsole("impulse 200")
        SendToConsole("bind " .. PRIMARY_ATTACK .. " \"\"")
        SendToConsole("bind " .. FLASHLIGHT .. " \"\"")
        SendToConsole("disable_flashlight")
        SendToConsole("hidehud 4")
    end

    function RemoveEliPreventFall(a, b)
        ent = Entities:FindByName(nil, "elipreventfall")
        ent:Kill()
    end

    function ReachForEli()
        SendToConsole("ent_fire eli_fall_relay Trigger")
    end

    function EnableHotelLobbyPower(a, b)
        ent = Entities:FindByName(nil, "power_stake_1_start")
        ent:Attribute_SetIntValue("used", 0)
    end

    function ExplodeFirstDoorMine()
        local ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(606, 1640, 410), 10)
        if ent then
            ent:FireOutput("OnExplode", nil, nil, nil, 0)
        end
    end

    function MakeLeverUsable(a, b)
        ent = Entities:FindByName(nil, "door_reset")
        ent:Attribute_SetIntValue("used", 0)
    end

    function CrouchThroughZooHole(a, b)
        SendToConsole("fadein 0.2")
        SendToConsole("setpos 5393 -1960 -125")

        local ent = Entities:FindByClassnameNearest("prop_physics", Vector(5126, -1957, -53), 10)
        DoEntFireByInstanceHandle(ent, "DisablePickup", "", 0, nil, nil)
        ent:SetEntityName("tiger_mask")
    end

    function PlayLockedDoorHandleAnimation(a, b)
        local ents = Entities:FindAllByClassnameWithin("prop_animinteractable", a:GetCenter(), 20)
        for k, v in pairs(ents) do
            if vlua.find(v:GetModelName(), "doorhandle") then
                DoEntFireByInstanceHandle(v, "PlayAnimation", "doorhandle_locked_anim", 0, nil, nil)
            end
        end
    end

    function ClimbLadder(height, push_direction)
        local ent = Entities:GetLocalPlayer()
        if ent:Attribute_GetIntValue("disable_unstuck", 0) == 1 then
            return
        end
        ent:Attribute_SetIntValue("disable_unstuck", 1)
        local ticks = 0
        ent:SetThink(function()
            if ent:GetOrigin().z > height then
                if push_direction == nil then
                    ent:SetVelocity(Vector(ent:GetForwardVector().x, ent:GetForwardVector().y, 0):Normalized() * 150)
                else
                    ent:SetVelocity(Vector(push_direction.z, push_direction.y, push_direction.z) * 150)
                end
                SendToConsole("+iv_duck;-iv_duck")
                ent:Attribute_SetIntValue("disable_unstuck", 0)
            else
                ent:SetVelocity(Vector(0, 0, 0))
                ent:SetOrigin(ent:GetOrigin() + Vector(0, 0, 2.1))
                ticks = ticks + 1
                if ticks == 25 then
                    SendToConsole("snd_sos_start_soundevent Step_Player.Ladder_Single")
                    ticks = 0
                end
                return 0
            end
        end, "ClimbUp", 0)
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
        SendToConsole("ent_fire @relay_installcrank Trigger")
    end

    function ShowInteractTutorial()
        local ent = SpawnEntityFromTableSynchronous("env_message", {["message"]="INTERACT"})
        DoEntFireByInstanceHandle(ent, "ShowMessage", "", 0, nil, nil)
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function ShowLadderTutorial()
        SendToConsole("ent_fire text_ladder ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function CheckTutorialPistolEmpty()
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("pistol_magazine_ammo", player:Attribute_GetIntValue("pistol_magazine_ammo", 0) - 1)
        if player:Attribute_GetIntValue("pistol_magazine_ammo", 0) == 0 then
            SendToConsole("ent_fire_output pistol_chambered_listener OnEventFired")
        end
    end

    function ShowSprintTutorial()
        SendToConsole("ent_fire text_sprint ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function ShowCrouchTutorial()
        SendToConsole("ent_fire text_crouch ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function ShowPickUpTutorial()
        SendToConsole("ent_fire text_pick_up ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function ShowGravityGlovesTutorial()
        local player = Entities:GetLocalPlayer()
        player:SetThink(function()
            SendToConsole("ent_fire text_gg ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            return 10
        end, "GGTutorial", 0)
    end

    function ShowCrouchJumpTutorial()
        SendToConsole("ent_fire 28677_hint_mantle_delay Disable")
        SendToConsole("ent_fire 15493_hint_mantle_delay Disable")
        SendToConsole("ent_fire 13987_hint_mantle_delay Disable")
        SendToConsole("ent_fire 2861_4065_hint_mantle_delay Disable")
        SendToConsole("ent_fire text_crouchjump ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function ShowMultiToolTutorial()
        SendToConsole("give weapon_physcannon")
        SendToConsole("use weapon_pistol")
        SendToConsole("ent_fire text_multitool_equip ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        Entities:GetLocalPlayer():SetThink(function()
            SendToConsole("ent_fire text_multitool_use ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        end, "MultiToolTutorial", 5)
    end

    function ShowBreakBoardsTutorial()
        local player = Entities:GetLocalPlayer()
        if player:Attribute_GetIntValue("break_boards_tutorial_shown", 0) == 0 then
            SendToConsole("ent_fire text_break_boards ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        end
    end

    function ShowHoldInteractTutorial()
        local player = Entities:GetLocalPlayer()
        if player:Attribute_GetIntValue("hold_interact_tutorial_shown", 0) == 0 then
            player:Attribute_SetIntValue("hold_interact_tutorial_shown", 1)
            SendToConsole("ent_fire text_holdinteract ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        end
    end

    function ShowCoverMouthTutorial()
        if Entities:GetLocalPlayer():Attribute_GetIntValue("covering_mouth", 0) == 0 then
            SendToConsole("ent_fire text_covermouth ShowMessage")
            SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
        end
    end

    function ShowQuickSaveTutorial()
        SendToConsole("ent_fire text_quicksave_tutorial ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function OpenHideoutGate()
        SendToConsole("ent_fire hideout_gate_prop Kill")
    end

    function DisableBarnacleAmmoPickup()
        local ent = Entities:FindByClassnameNearest("npc_barnacle", Vector(1349, -1748, 239), 10)
        DoEntFireByInstanceHandle(ent, "AddOutput", "OnRelease>base_dropdown_barnacle_2_ammo>EnablePickup>>0>1", 0, nil, nil)
        DoEntFireByInstanceHandle(ent, "AddOutput", "OnRelease>base_dropdown_barnacle_2_ammo>RunScriptCode>thisEntity:Attribute_SetIntValue(\"used\", 0)>0>1", 0, nil, nil)

        ent = Entities:FindByName(nil, "base_dropdown_barnacle_2_ammo")
        ent:Attribute_SetIntValue("used", 1)
        SendToConsole("ent_fire base_dropdown_barnacle_2_ammo DisablePickup")
    end

    function EnableStreetElevatorDoor()
        local ent = Entities:FindByName(nil, "elev_anim_door")
        ent:SetThink(function()
            ent:Attribute_SetIntValue("used", 0)
        end, "EnableStreetElevatorDoor", 10)
    end

    function SetupMineRoom()
        local ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-1165, -3770, 158), 10)
        if ent then
            ent:Kill()
        end

        SendToConsole("ent_fire collidable_physics_prop Kill")

        Entities:GetLocalPlayer():SetThink(function()
            ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-1165, -3770, 158), 10)
            if ent then
                ent:SetAbsAngles(90, -166, 0)
                ent:SetAbsOrigin(Vector(-1175, -3770, 135))
            end


            ent = Entities:FindByClassnameNearest("item_hlvr_weapon_tripmine", Vector(-1105.788, -4058.940, 164.177), 10)
            if ent then
                ent:SetAbsOrigin(Vector(-1105.788, -4058.940, 140))
            end

            ent = SpawnEntityFromTableSynchronous("prop_physics", {["model"]="models/props_c17/oildrum001_explosive.vmdl", ["origin"]="-1121 -3814 105"})

            AddCollisionToPhysicsProps("prop_physics")
            AddCollisionToPhysicsProps("prop_physics_override")

            SendToConsole("ent_fire item_hlvr_weapon_tripmine OnHackSuccessAnimationComplete")
        end, "SetupMineRoom", 0.1)
    end

    function EnableShackToner()
        Entities:FindByName(nil, "shack_path_6_port_1"):Attribute_SetIntValue("used", 0)
    end

    function LarrySeesGun()
        SendToConsole("ent_fire_output @player_proxy OnWeaponActive")
    end

    function LarrySeesWearable()
        local ent = Entities:FindByName(nil, "hat_construction_viewmodel")
        if ent then
            SendToConsole("ent_fire_output @player_proxy OutPlayerIsWearingHat " .. ent:GetModelName())
        end

        ent = Entities:FindByName(nil, "respirator_viewmodel")
        if ent then
            SendToConsole("ent_fire_output @player_proxy OutPlayerIsWearingHat " .. ent:GetModelName())
        end
    end

    function EnableJeffElevatorDoorToner()
        local ent = Entities:FindByName(nil, "freezer_toner_outlet_1")
        ent:Attribute_SetIntValue("used", 0)
    end

    function EnablePlugLever1()
        Entities:GetLocalPlayer():Attribute_SetIntValue("plug_lever", 1)
    end

    function EnablePlugLever2()
        Entities:GetLocalPlayer():Attribute_SetIntValue("plug_lever", 2)
    end

    function EnablePlugLever3()
        Entities:GetLocalPlayer():Attribute_SetIntValue("plug_lever", 3)
    end

    function EnablePlugLever4()
        Entities:GetLocalPlayer():Attribute_SetIntValue("plug_lever", 4)
    end

    function StartRevealEavesdrop()
        SendToConsole("impulse 200")
        SendToConsole("bind " .. PRIMARY_ATTACK .. " \"\"")
        SendToConsole("bind " .. SECONDARY_ATTACK .. " \"\"")
        SendToConsole("bind " .. TERTIARY_ATTACK .. " \"\"")
        SendToConsole("bind " .. FLASHLIGHT .. " \"\"")
        SendToConsole("hidehud 4")
        SendToConsole("disable_flashlight")
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("eavesdropping", 1)

        -- Detect shooting so Combine hear it
        local pos = player:GetAbsOrigin()
        local ent = SpawnEntityFromTableSynchronous("trigger_detect_bullet_fire", {["targetname"]="bullet_trigger", ["modelscale"]=100, ["model"]="models/hacking/holo_hacking_sphere_prop.vmdl", ["origin"]="" .. pos.x .. " " .. pos.y .. " " .. pos.z})
        DoEntFireByInstanceHandle(ent, "AddOutput", "OnDetectedBulletFire>relay_start_combat_early>Trigger>>0>1", 0, nil, nil)
    end

    function StopRevealEavesdrop()
        SendToConsole("bind " .. PRIMARY_ATTACK .. " \"+customattack;viewmodel_update\"")
        SendToConsole("bind " .. SECONDARY_ATTACK .. " +customattack2")
        SendToConsole("bind " .. TERTIARY_ATTACK .. " +customattack3")
        SendToConsole("bind " .. FLASHLIGHT .. " inv_flashlight")
        SendToConsole("impulse 200")
        SendToConsole("hidehud 64")
        Entities:GetLocalPlayer():Attribute_SetIntValue("eavesdropping", 0)
    end

    function EnableToiletElevatorLever()
        local ent = Entities:FindByName(nil, "plug_console_starter_lever")
        ent:Attribute_SetIntValue("used", 0)
        DoEntFireByInstanceHandle(ent, "SetCompletionValue", "0", 0, nil, nil)
    end

    function DisableBarnacleHealthVialPickup()
        ent = Entities:FindByClassnameNearest("npc_barnacle", Vector(4733, 5708, 383), 10)
        DoEntFireByInstanceHandle(ent, "AddOutput", "OnRelease>waste_vial_item_1>EnablePickup>>0>1", 0, nil, nil)

        SendToConsole("ent_fire waste_vial_item_1 DisablePickup")
    end

    function EquipCombineGunMechanical(player)
        SendToConsole("setpos 1510.57 386.48 944;setang -11.64 177.98 0")
        SendToConsole("ent_fire player_speedmod ModifySpeed 0")
        SendToConsole("bind " .. PRIMARY_ATTACK .. " novr_shootcombinegun")
        SendToConsole("r_drawviewmodel 0")

        local ent = Entities:FindByName(nil, "combine_gun_interact") -- Take interaction gun entity instead of base model
        ent:Attribute_SetIntValue("active", 1)
        ent:FireOutput("OnCompletionB_Forward", nil, nil, nil, 0) -- ammo charge sound
        ent:FireOutput("OnInteractStart", nil, nil, nil, 0)
        ent:SetThink(function()
            ent:SetAngles(player:EyeAngles().x * -1,player:EyeAngles().y - 180,0)
            return 0.05
        end, "UsingCombineGun", 0)
    end

    function CombineGunHandleAnim(a, b)
        local ent = Entities:FindByName(nil, "combine_gun_interact")
        ent:FireOutput("OnCompletionD_Forward", nil, nil, nil, 0) -- charge sounds
        local handleState = 0
        ent:SetThink(function()
            if handleState < 1 then
                handleState = handleState + 0.05
                DoEntFireByInstanceHandle(ent, "SetCompletionValue", "" .. handleState, 0, nil, nil)
                return 0.05
            else
                ent:FireOutput("OnCompletionC_Forward", nil, nil, nil, 0) -- charge sounds
                ent:Attribute_SetIntValue("ready", 1) -- ready to shoot
                return nil
            end
        end, "UsingCombineGunHandle", 0)
    end

    function EnterVaultBeam()
        SendToConsole("ent_remove weapon_pistol;ent_remove weapon_shotgun;ent_remove weapon_ar2;ent_remove weapon_smg1;ent_remove weapon_frag;ent_remove weapon_physcannon")
        SendToConsole("r_drawviewmodel 0")
        SendToConsole("ent_fire player_speedmod ModifySpeed 0")
        SendToConsole("phys_pushscale 1")
        SendToConsole("ent_remove hat_construction_viewmodel")
    end

    function ShowVortEnergyTutorial()
        SendToConsole("ent_fire text_vortenergy ShowMessage")
        SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
    end

    function GiveVortEnergy(a, b)
        SendToConsole("bind " .. PRIMARY_ATTACK .. " shootvortenergy")
        local player = Entities:GetLocalPlayer()
        player:Attribute_SetIntValue("vort_energy", 1)
    end

    function RemoveVortEnergy(a, b)
        SendToConsole("bind " .. PRIMARY_ATTACK .. " \"+customattack;viewmodel_update\"")
        Entities:GetLocalPlayer():Attribute_SetIntValue("vort_energy", 0)
    end

    function GiveAdvisorVortEnergy(a, b)
        SendToConsole("bind " .. PRIMARY_ATTACK .. " shootadvisorvortenergy")
    end

    function StartCredits(a, b)
        SendToConsole("mouse_disableinput 1")
    end

    function EndCredits(a, b)
        SendToConsole("mouse_disableinput 0")
        SendToConsole("use weapon_bugbait")
        SendToConsole("hidehud 32")
    end

    function AddCollisionToPhysicsProps(class)
        ent = Entities:FindByClassname(nil, class)
        while ent do
            local model = ent:GetModelName()
            local name = ent:GetName()
            if vlua.find(collidable_props, model) ~= nil and name ~= "6391_prop_physics_oildrum" and name ~= "6391_prop_physics_oildrum" then
                local angles = ent:GetAngles()
                local pos = ent:GetAbsOrigin()
                local child = SpawnEntityFromTableSynchronous("prop_dynamic_override", {["targetname"]="collidable_physics_prop", ["CollisionGroupOverride"]=5, ["solid"]=6, ["modelscale"]=ent:GetModelScale() - 0.02, ["renderamt"]=0, ["model"]=model, ["origin"]= pos.x .. " " .. pos.y .. " " .. pos.z, ["angles"]= angles.x .. " " .. angles.y .. " " .. angles.z})
                child:SetParent(ent, "")
            end
            ent = Entities:FindByClassname(ent, class)
        end
    end

    function is_on_map_or_later(compare_map)
        local current_map = GetMapName()

        local maps = {
            -- Official Campaign
            {
                "a1_intro_world",
                "a1_intro_world_2",
                "a2_quarantine_entrance",
                "a2_pistol",
                "a2_hideout",
                "a2_headcrabs_tunnel",
                "a2_drainage",
                "a2_train_yard",
                "a3_station_street",
                "a3_hotel_lobby_basement",
                "a3_hotel_underground_pit",
                "a3_hotel_interior_rooftop",
                "a3_hotel_street",
                "a3_c17_processing_plant",
                "a3_distillery",
                "a4_c17_zoo",
                "a4_c17_tanker_yard",
                "a4_c17_water_tower",
                "a4_c17_parking_garage",
                "a5_vault",
                "a5_ending",
            },
        }

        -- Check each campaign
        for i = 1, #maps do
            local current_map_index = vlua.find(maps[i], current_map)
            local compare_map_index = vlua.find(maps[i], compare_map)

            if current_map_index and current_map_index < compare_map_index then
                return false
            end
        end

        return true
    end

    function sin(x)
        local result = 0
        local sign = 1
        local term = x

        for i = 1, 10 do -- increase the number of iterations for more accuracy
          result = result + sign * term
          sign = -sign
          term = term * x * x / ((2 * i) * (2 * i + 1))
        end

        return result
    end

    function dump(o)
        if type(o) == 'table' then
           local s = '{ '
           for k, v in pairs(o) do
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. dump(v) .. ','
           end
           return s .. '} '
        else
           return tostring(o)
        end
    end
end
