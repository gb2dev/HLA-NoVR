local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 82)
local class = thisEntity:GetClassname()
if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 and vlua.find(ents, thisEntity) then
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
elseif class == "prop_physics" or class == "item_hlvr_grenade_frag" or class == "item_item_crate" or class == "item_healthvial" or class == "item_hlvr_crafting_currency_large" or class == "item_hlvr_crafting_currency_small" or class == "item_hlvr_clip_shotgun_single" or class == "item_hlvr_clip_shotgun_multiple" or class == "item_hlvr_clip_rapidfire" or class == "item_hlvr_clip_energygun_multiple" or class == "item_hlvr_clip_energygun" or class == "item_hlvr_prop_battery" then
    if CalcDistanceBetweenEntityOBB(Entities:GetLocalPlayer(), thisEntity) < 70 or CalcDistanceBetweenEntityOBB(Entities:GetLocalPlayer(), thisEntity) > 400 then return false end
local eyetrace =
{
	startpos = Entities:GetLocalPlayer():EyePosition();
	endpos = thisEntity:GetOrigin(), Vector(0,0,10);
	ignore = Entities:GetLocalPlayer();
	mask =  33636363
}
TraceLine(eyetrace)
if eyetrace.hit and eyetrace.enthit == thisEntity == false then print("failed!") return false end
    local direction = Entities:GetLocalPlayer():EyePosition() - thisEntity:GetAbsOrigin()
    thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, Clamp(direction.z * 3.9, -400, 400)))
    StartSoundEventFromPosition("Grabbity.HoverPing", Entities:GetLocalPlayer():EyePosition())
    StartSoundEventFromPosition("Grabbity.Grab", Entities:GetLocalPlayer():EyePosition())
end
