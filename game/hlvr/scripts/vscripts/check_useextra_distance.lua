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
    if eyetrace.enthit then
        if eyetrace.enthit:GetClassname() == "worldent" and class ~= "item_combine_tank_locker" and not vlua.find(class, "hlvr_piano") then
            DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "gravity_gloves", 0, nil, nil)
            return
        elseif class == "prop_hlvr_crafting_station_console" then
            local ent = Entities:FindByNameWithin(nil, "weapon_in_fabricator_idle", eyetrace.pos, 15)
            if ent then
                SendToConsole("novr_crafting_station_cancel_upgrade")
            end
        end
    end
    if eyetrace.enthit and eyetrace.enthit:GetClassname() == "func_brush" then
        local door = Entities:FindByClassnameNearest("prop_door_rotating_physics", eyetrace.enthit:GetOrigin(), 1)
        if door then
            DoEntFireByInstanceHandle(door, "Use", "", 0, player, player)

            door:SetThink(function()
                local angles = door:GetAngles()
                eyetrace.enthit:SetAngles(angles.x, angles.y, angles.z)
                return 0
            end, "RotateDoorBrush", 0)
        end
    end

    -- TODO: There's gotta be a better way than to exclude some things from here
    if eyetrace.enthit == thisEntity or vlua.find(class, "hlvr_piano") or name == "russell_entry_window" or class == "item_combine_tank_locker" or eyetrace.enthit:GetClassname() == "func_physical_button" or vlua.find(name, "socket") or vlua.find(name, "traincar_01") then
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
                DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "gravity_gloves", 0, nil, nil)
            end
        end, "GravityGlovePull", 0.02)
    elseif useRoutine == 0 and (eyetrace.enthit == thisEntity or vlua.find(name, "door_hack")) and IsValidEntity(thisEntity) then
		DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
    end
else
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "gravity_gloves", 0, nil, nil)
end
