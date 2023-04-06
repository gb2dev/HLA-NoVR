local class = thisEntity:GetClassname()
local player = Entities:GetLocalPlayer()
local startVector = player:EyePosition()
local eyetrace =
{
    startpos = startVector;
    endpos = startVector + RotatePosition(Vector(0,0,0), player:GetAngles(), Vector(82,0,0));
    ignore = player;
    mask =  33636363
}
TraceLine(eyetrace)

if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 then
    if eyetrace.hit then
        DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
    elseif player:Attribute_GetIntValue("gravity_gloves", 0) == 1 and (class == "prop_physics" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_prop_battery") and thisEntity:GetMass() <= 10 then
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
                DoEntFireByInstanceHandle(thisEntity, "Use", "", 0, player, nil)
                DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, player, nil)
            end
        end, nil, delay)
    end
end
