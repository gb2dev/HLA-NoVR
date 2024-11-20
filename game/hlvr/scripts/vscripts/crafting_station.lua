local player = Entities:GetLocalPlayer()
if thisEntity:GetClassname() == "prop_hlvr_crafting_station_console" then
    local function AnimTagListener(sTagName, nStatus)
        if sTagName == 'Bootup Done' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("crafting_station_ready", 1)
        elseif sTagName == 'Crafting Done' and nStatus == 2 then
            if Convars:GetStr("novr_chosen_weapon_upgrade") == "pistol_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("pistol_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_aimdownsights ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "pistol_upgrade_burstfire" then
                player:Attribute_SetIntValue("pistol_upgrade_burstfire", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_burstfire ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "pistol_upgrade_hopper" then
                player:Attribute_SetIntValue("pistol_upgrade_hopper", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade animation and remove message
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "pistol_upgrade_lasersight" then
                player:Attribute_SetIntValue("pistol_upgrade_lasersight", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("pistol_use_new_accuracy 1")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "shotgun_upgrade_grenadelauncher" then
                player:Attribute_SetIntValue("shotgun_upgrade_grenadelauncher", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_grenadelauncher ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "shotgun_upgrade_doubleshot" then
                player:Attribute_SetIntValue("shotgun_upgrade_doubleshot", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_doubleshot ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "shotgun_upgrade_lasersight" then
                player:Attribute_SetIntValue("shotgun_upgrade_lasersight", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "shotgun_upgrade_hopper" then
                player:Attribute_SetIntValue("shotgun_upgrade_hopper", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade animation and remove message
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "smg_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("smg_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_smg_upgrade_aimdownsights ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "smg_upgrade_lasersight" then
                player:Attribute_SetIntValue("smg_upgrade_lasersight", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("novr_chosen_weapon_upgrade") == "smg_upgrade_casing" then
                player:Attribute_SetIntValue("smg_upgrade_casing", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade animation and remove message
            end

            SendToConsole("ent_fire point_clientui_world_panel Enable")
            SendToConsole("ent_fire weapon_in_fabricator Kill")
            thisEntity:SetGraphParameterBool("bCrafting", false)
            Convars:SetStr("novr_chosen_weapon_upgrade", "")
            Convars:SetStr("novr_weapon_in_crafting_station", "")
        elseif sTagName == 'Trays Retracted' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("cancel_cooldown_done", 1)
        end
    end

    thisEntity:RegisterAnimTagListener(AnimTagListener)
end
