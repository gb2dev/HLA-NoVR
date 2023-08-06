
function HUDHearts_StartupPreparations()
	if not Entities:FindByName(nil, "text_hearts") then
		SendToConsole("ent_create game_text { targetname text_hearts effect 0 spawnflags 1 color \"236 193 39\" color2 \"0 0 0\" fadein 0 fadeout 0 channel 3 fxtime 0 holdtime 9999 x 0.02745 y -0.046 }")	
	end

	local player = Entities:GetLocalPlayer()
	player:SetThink(function()
		HUDHearts_UpdateHealth()
	end, "HUDHearts_MapChange", 1)

	print("[HUDHearts] Start up done")
end

function HUDHearts_UpdateHealth()
	local player = Entities:GetLocalPlayer()
	local textEntity = Entities:FindByName(nil, "text_hearts")
	
	local health = player:GetHealth()
	local heart_icons = "000"

	if health >= 96 then
		heart_icons = "000"
	elseif health >= 88 then
		heart_icons = "001"
	elseif health >= 77 then
		heart_icons = "002"
	elseif health > 66 then
		heart_icons = "003"
	elseif health >= 63 then
		heart_icons = "00"
	elseif health >= 55 then
		heart_icons = "01"
	elseif health >= 44 then
		heart_icons = "02"
	elseif health > 33 then
		heart_icons = "03"
	elseif health >= 30 then
		heart_icons = "0"
	elseif health >= 22 then
		heart_icons = "1"
	elseif health >= 11 then
		heart_icons = "2"
	else
		heart_icons = "3"
	end 

	--DoEntFireByInstanceHandle(textEntity, "SetText", " ", 0, nil, nil)
	DoEntFireByInstanceHandle(textEntity, "Display", "", 0, nil, nil)

	DoEntFireByInstanceHandle(textEntity, "SetText", "" .. heart_icons ..  "", 0, nil, nil)
	--ShowEmptyText() -- avoid text antialiasing bug, display empty message and normal one after
	DoEntFireByInstanceHandle(textEntity, "Display", "", 0.1, nil, nil)
end

Convars:RegisterCommand("hudhearts_updatehealth" , function()
	HUDHearts_UpdateHealth()
end, "Lua code test", 0)

Convars:RegisterCommand("hudhearts_debug_set_health_40" , function()
	local player = Entities:GetLocalPlayer()
	player:SetHealth(40)
	HUDHearts_UpdateHealth()
end, "Lua code test", 0)