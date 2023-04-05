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
    elseif class == "prop_physics" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_prop_battery" then
        local direction = startVector - thisEntity:GetAbsOrigin()
        thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, Clamp(direction.z * 3.8, -400, 400)))
        StartSoundEventFromPosition("Grabbity.HoverPing", startVector)
        StartSoundEventFromPosition("Grabbity.Grab", startVector)
        thisEntity:SetThink(function()
            local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 100)
            if vlua.find(ents, thisEntity) then
                DoEntFireByInstanceHandle(thisEntity, "Use", "", 0, player, nil)
            end
        end, nil, 0.3)
    end
end
