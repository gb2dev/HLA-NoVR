
-- Display hud heart icons by withoutaface

function HUDHearts_StartupPreparations()
	SendToConsole("ent_remove text_hearts_background")
	SendToConsole("ent_create game_text { targetname text_hearts_background effect 0 spawnflags 1 color \"121 97 11\" color2 \"0 0 0\" fadein 0 fadeout 0 channel 2 fxtime 0 holdtime 0.11 x 0.0277 y -0.0357 }")	

	SendToConsole("ent_remove text_hearts")
	SendToConsole("ent_create game_text { targetname text_hearts effect 0 spawnflags 1 color \"236 193 39\" color2 \"0 0 0\" fadein 0 fadeout 0 channel 3 fxtime 0 holdtime 0.11 x 0.0277 y -0.0357 }")	

	-- Define heart icons if health is below 20
	SendToConsole("ent_remove text_hearts_red")
	SendToConsole("ent_create game_text { targetname text_hearts_red effect 0 spawnflags 1 color \"180 0 0\" color2 \"0 0 0\" fadein 0 fadeout 0 channel 3 fxtime 0 holdtime 0.11 x 0.0277 y -0.0357 }")	

	-- Trigger initial hearts update
	if GetMapName() ~= "a1_intro_world" and GetMapName() ~= "a1_intro_world_2" then
		local player = Entities:GetLocalPlayer()
		player:SetThink(function()
			HUDHearts_UpdateHealth()
		end, "HUDHearts_MapChange", 1)
	end

	print("[HUDHearts] Start up done")
end

function HUDHearts_UpdateHealth()
	local player = Entities:GetLocalPlayer()
	local textEntity = Entities:FindByName(nil, "text_hearts")
	local textEntityRed = Entities:FindByName(nil, "text_hearts_red")
	local textEntityBackground = Entities:FindByName(nil, "text_hearts_background")
	
	local health = player:GetHealth()
	local heart_icons = ""
	local heart_icons_background = "{ { {"

	if health >= 96 then
		heart_icons = "{ { {"
		heart_icons_background = ""
	elseif health >= 88 then
		heart_icons = "{ { }"
		heart_icons_background = "´ ´ `"
	elseif health >= 77 then
		heart_icons = "{ { §"
		heart_icons_background = "´ ´ ³"
	elseif health > 66 then
		heart_icons = "{ { °"
		heart_icons_background = "´ ´ ²"
	elseif health >= 63 then
		heart_icons = "{ {"
		heart_icons_background = "´ ´ {"
	elseif health >= 55 then
		heart_icons = "{ }"
		heart_icons_background = "´ ` {"
	elseif health >= 44 then
		heart_icons = "{ §"
		heart_icons_background = "´ ³ {"
	elseif health > 33 then
		heart_icons = "{ °"
		heart_icons_background = "´ ² {"
	elseif health >= 30 then
		heart_icons = "{"
		heart_icons_background = "´ { {"
	elseif health >= 22 then
		heart_icons = "}"
		heart_icons_background = "` { {"
	elseif health >= 11 then
		heart_icons = "§"
		heart_icons_background = "³ { {"
	else
		heart_icons = "°"
		heart_icons_background = "² { {"
	end

	-- Show background hearts
	DoEntFireByInstanceHandle(textEntityBackground, "Display", "", 0, nil, nil)
	DoEntFireByInstanceHandle(textEntityBackground, "SetText", "" .. heart_icons_background ..  "", 0, nil, nil)
	DoEntFireByInstanceHandle(textEntityBackground, "Display", "", 0.1, nil, nil)
	-- Switch to red color if health is below 20
	if health < 20 then
		DoEntFireByInstanceHandle(textEntity, "Display", "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntityRed, "Display", "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntityRed, "SetText", "" .. heart_icons ..  "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntityRed, "Display", "", 0.1, nil, nil)
	else
		DoEntFireByInstanceHandle(textEntityRed, "Display", "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntity, "Display", "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntity, "SetText", "" .. heart_icons ..  "", 0, nil, nil)
		DoEntFireByInstanceHandle(textEntity, "Display", "", 0.1, nil, nil)
	end

	--print(string.format("[HUDHearts] Set heart icons to %s health", health))
end

function HUDHearts_StartUpdateLoop()
	-- Update hud hearts
	local player = Entities:GetLocalPlayer()
	player:SetThink(function()
		HUDHearts_UpdateHealth()
		return 0.1
	end, "HUDHearts_UpdateLoop", 0)
	print("[HUDHearts] Start hud hearts update loop")
end

function HUDHearts_StopUpdateLoop()
	-- Stop hud hearts update
	local player = Entities:GetLocalPlayer()
	player:StopThink("HUDHearts_UpdateLoop")
	print("[HUDHearts] Stop hud hearts update loop")
end

Convars:RegisterCommand("hudhearts_recreate" , function()
	SendToConsole("ent_remove text_hearts_background")
	SendToConsole("ent_remove text_hearts_red")
	SendToConsole("ent_remove text_hearts")
	HUDHearts_StartupPreparations()
end, "Recreate hud heart icons", 0)

Convars:RegisterCommand("hudhearts_startupdateloop" , function()
	HUDHearts_StartUpdateLoop()
end, "Start hud heart update loop", 0)

Convars:RegisterCommand("hudhearts_stopupdateloop" , function()
	HUDHearts_StopUpdateLoop()
end, "Stop hud heart update loop", 0)
