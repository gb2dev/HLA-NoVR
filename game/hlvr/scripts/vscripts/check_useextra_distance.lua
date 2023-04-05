local ents = Entities:FindAllInSphere(Entities:GetLocalPlayer():EyePosition(), 82)
if thisEntity:Attribute_GetIntValue("picked_up", 0) == 0 and vlua.find(ents, thisEntity) then
    DoEntFireByInstanceHandle(thisEntity, "RunScriptFile", "useextra", 0, nil, nil)
end
