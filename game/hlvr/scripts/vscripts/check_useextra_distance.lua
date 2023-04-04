local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 82)
local class = thisEntity:GetClassname()
if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 and vlua.find(ents, thisEntity) then
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
elseif class == "prop_physics" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_grenade_frag" or class == "item_healthvial"  or class == "item_hlvr_prop_battery" then
    if VectorDistanceSq(Entities:GetLocalPlayer():EyePosition(), thisEntity:GetAbsOrigin()) > 9500 then
        local direction = Entities:GetLocalPlayer():EyePosition() - thisEntity:GetAbsOrigin()
        thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, Clamp(direction.z * 3.8, -400, 400)))
        StartSoundEventFromPosition("Grabbity.HoverPing", Entities:GetLocalPlayer():EyePosition())
        StartSoundEventFromPosition("Grabbity.Grab", Entities:GetLocalPlayer():EyePosition())
    end
end
