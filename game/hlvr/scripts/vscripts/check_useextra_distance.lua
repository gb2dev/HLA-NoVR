local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 82)
if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 and vlua.find(ents, thisEntity) then
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
elif thisEntity:GetClassname() == "prop_physics" then
    local direction = Entities:GetLocalPlayer():EyePosition() - thisEntity:GetAbsOrigin()
    thisEntity:ApplyAbsVelocityImpulse(Vector(direction.x * 2, direction.y * 2, Clamp(direction.z * 3.8, -400, 400)))
    StartSoundEventFromPosition("Grabbity.HoverPing", Entities:GetLocalPlayer():EyePosition())
    StartSoundEventFromPosition("Grabbity.Grab", Entities:GetLocalPlayer():EyePosition())
    DoEntFireByInstanceHandle(thisEntity, "use", "", 0.3, Entities:GetLocalPlayer(), nil)
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0.3, Entities:GetLocalPlayer(), nil)
end
