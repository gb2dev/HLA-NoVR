-- Flashlight Script made by JJL772: https://github.com/JJL772/half-life-alyx-scripts

-- Convars for the flashlight 
Convars:RegisterConvar("sv_flashlight_color", "255 255 255 255", "Color of the flashlight", FCVAR_REPLICATED)
Convars:RegisterConvar("sv_flashlight_brightness", "2", "Brightness of the flashlight", FCVAR_REPLICATED)
Convars:RegisterConvar("sv_flashlight_shadowtex_size", "128", "The X and Y size of the shadow texture", FCVAR_REPLICATED)
Convars:RegisterConvar("sv_flashlight_range", "700", "max range of the flashlight", FCVAR_REPLICATED)

local function destroy_flashlight()
	if flashlight_ent ~= nil and not flashlight_ent:IsNull() then
		flashlight_ent:Destroy()
		flashlight_ent = nil
	end 
	-- Fix if the flashlight was deleted but not set to nil
	if not flashlight_ent == nil and flashlight_ent:IsNull() then
		flashlight_ent = nil
	end
	EmitSoundOnClient("HL2Player.FlashLightOff",player)
end 

local function create_flashlight()
	local player = Entities:GetLocalPlayer()

	local ang = player:EyeAngles()
	local rot = player:GetAngles():Forward() 
	local size = Convars:GetStr("sv_flashlight_shadowtex_size")
	
	local lighttbl = {
		targetname = "player_flashlight",
		origin = player:EyePosition(),
		angles = ang,
		enabled = "1",
		color = Convars:GetStr("sv_flashlight_color"),
 		brightness = Convars:GetStr("sv_flashlight_brightness"),
 		range = Convars:GetStr("sv_flashlight_range"),
 		castshadows = "1",
 		shadowtexturewidth = size,
 		shadowtextureheight = size,
 		style = "0",
 		fademindist = "0",
 		fademaxdist = "6000",
 		bouncescale = "1.0",
 		renderdiffuse = "1",
 		renderspecular = "1",
 		directlight = "2",
 		indirectlight = "0",
 		attenuation1 = "0.0",
 		attenuation2 = "1.0",	
 		innerconeangle = "20",
		outerconeangle = "32",
		lightcookie = "flashlight" 
	}

	flashlight_ent = SpawnEntityFromTableSynchronous("light_spot", lighttbl)

	if flashlight_ent == nil then
		print("Failed to spawn flashlight")
		return 
	end
	flashlight_ent:SetParent(player, "flashlight")
	
	-- Apparently the flashlight wont follow the player's view properly when parented to the player
	-- so for now ill just not parent it and do it the wrong way
	flashlight_ent:SetThink(function()
		if flashlight_ent == nil then return end 
		local player = Entities:GetLocalPlayer() 
		local ang = player:EyeAngles()
		-- TODO: Why does EyePosition break things sometimes?
		flashlight_ent:SetLocalOrigin(player:EyePosition() - player:GetOrigin()) 
		flashlight_ent:SetLocalAngles(ang.x, 0, 0)
		return FrameTime()
	end, "flashlight_think", 0)
	EmitSoundOnClient("HL2Player.FlashLightOn",player)
end 

Convars:RegisterCommand("inv_flashlight", function()
	if flashlight_ent ~= nil then
		destroy_flashlight()
	else
		create_flashlight()
	end 
end, "Toggles the flashlight", 0)
