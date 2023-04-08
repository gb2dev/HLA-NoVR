Convars:RegisterCommand("inv_flashlight", function()
	if Entities:GetLocalPlayer():Attribute_GetIntValue("flashlight", 0) == 0 then
		Entities:GetLocalPlayer():Attribute_SetIntValue("flashlight", 1)
		SendToConsole("ent_fire player_flashlight enable")
	else
		Entities:GetLocalPlayer():Attribute_SetIntValue("flashlight", 0)
		SendToConsole("ent_fire player_flashlight disable")
	end 
end, "Toggles the flashlight", 0)
