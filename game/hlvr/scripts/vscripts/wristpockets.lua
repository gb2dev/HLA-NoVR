require "storage"
-- Fake Wrist Pockets, by Hypercycle
-- Note: all pocket grenades mechanics is currently disabled

-- bindings
WPOCKETS_USE_HEALTHPEN = "Z"
--WPOCKETS_USE_GRENADE   = "X"
WPOCKETS_DROPITEM      = "X"

-- starts from 1
local itemsClasses = { "item_healthvial", "item_hlvr_grenade_frag", "item_hlvr_prop_battery", "prop_physics", "item_hlvr_health_station_vial", "prop_reviver_heart" } 

--local itemsStrings = { "[z] He", "[x] Gr", "[c] Ba", "[c] It", "[c] Vi", "[c] Rv"  }
local itemsStrings = { "$", "^", "*", "<", "'", "|" }
-- font:
-- $ - Health Pen
-- ^ - Grenade
-- * - Battery, 
-- < - Item (prop_physics) (Is bottle icon correct?)
-- ' - Health Station Vial
-- | - Reviver's Heart

--local itemsUniqueStrings = { "[c] Vo", "[c] Ca"  }
local itemsUniqueStrings = { "<", ">"  }
-- < - Bottle
-- > - Keycard

-- pocketslots_slot1-2 values: 
-- 0 - Empty, 1 - Health Pen, 2 - Grenade, 3 - Battery, 4 - Item (prop_physics), 5 - Health Station Vial, 6 - Reviver's Heart

function WristPockets_StartupPreparations()
	local text = Entities:FindByName(nil, "text_pocketslots")
	if not text then
		SendToConsole("ent_create game_text { targetname text_pocketslots effect 0 spawnflags 1 color \"236 193 39\" color2 \"0 0 0\" fadein 0 fadeout 0 channel 4 fxtime 0 holdtime 9999 x 0.1497 y -0.031 }")
	end
	local textEmpty = Entities:FindByName(nil, "text_pocketslots_empty")
	if not textEmpty then
		SendToConsole("ent_create game_text { targetname text_pocketslots_empty effect 0 spawnflags 1 color \"236 193 39\" color2 \"92 107 192\" fadein 0 fadeout 0 channel 4 fxtime 0 holdtime 0 x 0.1497 y -0.031 }")
	end -- game cannot display newly recreated game_text on map bootup, so keep it
	-- and fade-in fx stops working, so disable it too

	--SendToConsole("sk_max_grenade 1") -- force only 1 grenade on hands
	SendToConsole("bind " .. WPOCKETS_USE_HEALTHPEN .. " pocketslots_healthpen") -- use health pen
	--SendToConsole("bind " .. WPOCKETS_USE_GRENADE .. " pocketslots_grenade") -- add HL2 grenade as a weapon
	SendToConsole("bind " .. WPOCKETS_DROPITEM .. " pocketslots_dropitem") -- drop item from one of slots
end

-- show empty fake slots
local function ShowEmptyText()
	local ent = Entities:FindByName(nil, "text_pocketslots_empty")
	DoEntFireByInstanceHandle(ent, "SetText", " ", 0, nil, nil)
	DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
end

-- set item message for each slot
local function SetSlotItemMsg(slotItemId, slotId)
	local pocketSlotMsg = " "
	if slotItemId == 4 then -- various icons for prop_physics objects
		local objModel = Storage:LoadString("pocketslots_slot" .. slotId .. "_objmodel")
		if objModel == "models/props/distillery/bottle_vodka.vmdl" then
			pocketSlotMsg = itemsUniqueStrings[1]
		elseif objModel == "models/props/misc/keycard_001.vmdl" then
			pocketSlotMsg = itemsUniqueStrings[2]
		end
	elseif slotItemId ~= 0 then
		pocketSlotMsg = itemsStrings[slotItemId]
	end
	return pocketSlotMsg
end

-- update wrist pockets slots on HUD
-- 1st slot is displayed as bottom one
function WristPockets_UpdateHUD()
	local player = Entities:GetLocalPlayer()
	local textEntity = Entities:FindByName(nil, "text_pocketslots")
	local pocketSlot1Msg = SetSlotItemMsg(player:Attribute_GetIntValue("pocketslots_slot1", 0), 1)
	local pocketSlot2Msg = SetSlotItemMsg(player:Attribute_GetIntValue("pocketslots_slot2", 0), 2)
	
	DoEntFireByInstanceHandle(textEntity, "SetText", "" .. pocketSlot2Msg .. "\n" .. pocketSlot1Msg .. "", 0, nil, nil)
	ShowEmptyText() -- avoid text antialiasing bug, display empty message and normal one after
	DoEntFireByInstanceHandle(textEntity, "Display", "", 0.1, nil, nil)
end

local function GetFreePocketSlot(playerEnt)
	if playerEnt:Attribute_GetIntValue("pocketslots_slot1", 0) == 0 then
		return 1
	elseif playerEnt:Attribute_GetIntValue("pocketslots_slot2", 0) == 0 then
		return 2
	end
	return 0 -- no free slots
end

local function ErasePocketSlot(playerEnt, itemSlot)
	if not Storage:LoadBoolean("pocketslots_slot" .. itemSlot .. "_keepacrossmaps") then
		playerEnt:Attribute_SetIntValue("pocketslots_slot" .. itemSlot .. "", 0)
		Storage:SaveString("pocketslots_slot" .. itemSlot .. "_objname", "")
		Storage:SaveString("pocketslots_slot" .. itemSlot .. "_objmodel", "")
		Storage:SaveBoolean("pocketslots_slot" .. itemSlot .. "_keepacrossmaps", false)
		print("[WristPockets] Item in slot #" .. itemSlot .. " cannot be carried across maps, removed.")
	end 
end

local function PrecacheModels()
    local ent_table = { -- used solution by SoMNst & Epic
        targetname = "novr_precachemodels",
		vscripts = "wristpockets_precache.lua"
    }
	SpawnEntityFromTableAsynchronous("logic_script", ent_table, nil, nil);
end

function WristPockets_CheckPocketItemsOnLoading(playerEnt, saveLoading)
	if playerEnt:Attribute_GetIntValue("pocketslots_slot1", 0) ~= 0 or playerEnt:Attribute_GetIntValue("pocketslots_slot2", 0) ~= 0 then
		if not saveLoading then -- erase teleported items on level change
			ErasePocketSlot(playerEnt, 1)
			ErasePocketSlot(playerEnt, 2)
		end
		WristPockets_UpdateHUD()
	end -- on first appear, icons can be too bold because of antialiasing bug
	PrecacheModels()
end

-- use slot 2 first, it comes as upper slot on HUD
local function GetPocketSlotToUse(slot1ItemId, slot2ItemId, targetItemId)
	if slot2ItemId == targetItemId then
		return 2 
	elseif slot1ItemId == targetItemId then
		return 1
	end
	return 0
end

local function GetNonEmptyPocketSlotToUse(slot1ItemId, slot2ItemId)
	if slot2ItemId ~= 0 then
		return 2 
	elseif slot1ItemId ~= 0 then
		return 1
	end
	return 0
end

-- item actions
function WristPockets_PickUpHealthPen(playerEnt, itemEnt)
	local pocketSlotId = GetFreePocketSlot(playerEnt)
	if pocketSlotId ~= 0 then
		StartSoundEventFromPosition("Inventory.WristPocketGrabItem", playerEnt:EyePosition())
		itemEnt:Kill()
		playerEnt:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "", 1)
		Storage:SaveBoolean("pocketslots_slot" .. pocketSlotId .. "_keepacrossmaps", true)
		print("[WristPockets] Health pen acquired on slot #" .. pocketSlotId .. ".")
		WristPockets_UpdateHUD() -- TODO fails to display on map change
	end
end

-- player can hold 2 grenades on pockets, and one in hand
function WristPockets_PickUpGrenade(playerEnt, itemEnt)
	local pocketSlotId = GetFreePocketSlot(playerEnt)
	if pocketSlotId ~= 0 then
		StartSoundEventFromPosition("Inventory.WristPocketGrabItem", playerEnt:EyePosition())
		itemEnt:Kill()
		playerEnt:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "", 2)
		Storage:SaveBoolean("pocketslots_slot" .. pocketSlotId .. "_keepacrossmaps", true)
		print("[WristPockets] Grenade acquired on slot #" .. pocketSlotId .. ".")
		WristPockets_UpdateHUD()
		
		hudHint = SpawnEntityFromTableSynchronous("env_hudhint", { ["targetname"]="pocketslots_hudhint", ["message"]="#HLVR_MainMenu_PhotoMode" })
        DoEntFireByInstanceHandle(hudHint, "ShowHudHint", "", 0, nil, nil)
	end
end

function WristPockets_PickUpValuableItem(playerEnt, itemEnt)
	local itemClass = itemEnt:GetClassname()
	local itemModel = itemEnt:GetModelName()
	if itemClass == "item_hlvr_prop_battery" or itemModel == "models/props/misc/keycard_001.vmdl" or itemModel == "models/props/distillery/bottle_vodka.vmdl" or itemClass == "item_hlvr_health_station_vial" or itemClass == "prop_reviver_heart" then
		local itemId = 0
		if itemClass == "item_hlvr_prop_battery" then
			itemId = 3
		elseif itemClass == "prop_physics" then -- generic quest item
			itemId = 4
		elseif itemClass == "item_hlvr_health_station_vial" then
			itemId = 5 -- valuable item, but usually without ent name
		elseif itemClass == "prop_reviver_heart" then
			itemId = 6 -- valuable item, but usually without ent name
		end
		local pocketSlotId = GetFreePocketSlot(playerEnt)
		
		if pocketSlotId ~= 0 and itemId ~= 0 then
			local keepItemInstance = true
			local keepAcrossMaps = false -- save item for later maps, always new instance
			if itemEnt:GetName() == "" then
				keepItemInstance = false -- can't do much with no-name entities
			end
			if itemModel == "models/props/distillery/bottle_vodka.vmdl" then
				keepItemInstance = false
				keepAcrossMaps = true
			end
			
			playerEnt:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "", itemId)
			Storage:SaveString("pocketslots_slot" .. pocketSlotId .. "_objname", itemEnt:GetName())
			Storage:SaveString("pocketslots_slot" .. pocketSlotId .. "_objmodel", itemModel)
			if keepItemInstance then
				itemEnt:DisableMotion() -- put valuable original item very far away, solution by FrostEpex
				itemEnt:SetOrigin(Vector(-15000,-15000,-15000))		
			else
				itemEnt:Kill() -- destroy original instance
			end
			Storage:SaveBoolean("pocketslots_slot" .. pocketSlotId .. "_keepacrossmaps", keepAcrossMaps)
			
			StartSoundEventFromPosition("Inventory.WristPocketGrabItem", playerEnt:EyePosition())
			print("[WristPockets] Item ID " .. itemId .. " acquired on slot #" .. pocketSlotId .. ".")
			WristPockets_UpdateHUD()
			return true
		end
	end
	return false
end

-- console commands for binds
Convars:RegisterCommand("pocketslots_healthpen", function()
	local player = Entities:GetLocalPlayer()
	local slot1ItemId = player:Attribute_GetIntValue("pocketslots_slot1", 0)
	local slot2ItemId = player:Attribute_GetIntValue("pocketslots_slot2", 0)
	if slot1ItemId == 0 and slot2ItemId == 0 then
		print("[WristPockets] Player don't have any health pens on inventory.")
	else 
		local pocketSlotId = GetPocketSlotToUse(slot1ItemId, slot2ItemId, 1)
		if pocketSlotId ~= 0 then
			if player:GetHealth() ~= player:GetMaxHealth() then
				player:SetHealth(min(player:GetHealth() + cvar_getf("hlvr_health_vial_amount"), player:GetMaxHealth()))
				StartSoundEventFromPosition("HealthPen.Stab", player:EyePosition())
				StartSoundEventFromPosition("HealthPen.Success01", player:EyePosition())
				player:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "" , 0)
				print("[WristPockets] Health pen has been used from slot #" .. pocketSlotId .. ".")
				WristPockets_UpdateHUD()
			else
				StartSoundEventFromPosition("HealthStation.Deny", player:EyePosition())
				print("[WristPockets] Player already is on full health.")
			end
		end 
	end
end, "Toggles the inventory health pen, if exists", 0)		

Convars:RegisterCommand("pocketslots_grenade", function()
	local player = Entities:GetLocalPlayer()
	local slot1ItemId = player:Attribute_GetIntValue("pocketslots_slot1", 0)
	local slot2ItemId = player:Attribute_GetIntValue("pocketslots_slot2", 0)
	if slot1ItemId == 0 and slot2ItemId == 0 then
		print("[WristPockets] Player don't have any grenades on inventory.")
	else 
		local pocketSlotId = GetPocketSlotToUse(slot1ItemId, slot2ItemId, 2)
		if pocketSlotId ~= 0 then -- TODO player can take out grenade even if one already on hands, it goes nowhere!
			player:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "" , 0)
			SendToConsole("give weapon_frag") -- give real grenade weapon
			local viewmodel = Entities:FindByClassname(nil, "viewmodel")
			viewmodel:RemoveEffects(32)
			StartSoundEventFromPosition("Inventory.DepositItem", player:EyePosition())
			SendToConsole("use weapon_frag") -- pick it on hands
			print("[WristPockets] Grenade has been armed from slot #" .. pocketSlotId .. ".")
			WristPockets_UpdateHUD()
		end 
	end
end, "Take the grenade in hands, if any exists on pockets", 0)		

Convars:RegisterCommand("pocketslots_dropitem", function()
	local player = Entities:GetLocalPlayer()
	local slot1ItemId = player:Attribute_GetIntValue("pocketslots_slot1", 0)
	local slot2ItemId = player:Attribute_GetIntValue("pocketslots_slot2", 0)
	if slot1ItemId == 0 and slot2ItemId == 0 then
		print("[WristPockets] Player don't have any items to drop.")
	else 
		local pocketSlotId = GetNonEmptyPocketSlotToUse(slot1ItemId, slot2ItemId)
		if pocketSlotId ~= 0 then
			local itemTypeId = player:Attribute_GetIntValue("pocketslots_slot" .. pocketSlotId .. "", 0)
			local player_ang = player:EyeAngles()
			local startVector = player:EyePosition()
			local traceTable =
			{
				startpos = startVector;
				endpos = startVector + RotatePosition(Vector(0,0,0), player_ang, Vector(40, 0, 0));
				ignore = player;
				mask = 33636363
			}
			TraceLine(traceTable)

			if traceTable.hit then -- TODO under certain angle you still can drop item into wall
				StartSoundEventFromPosition("HealthStation.Deny", player:EyePosition())
				print("[WristPockets] Cannot drop item - too close to obstacle.")
			else
				if itemTypeId == 3 or itemTypeId == 4 or itemTypeId == 5 or itemTypeId == 6 then
					local entName = Storage:LoadString("pocketslots_slot" .. pocketSlotId .. "_objname")
					if entName ~= "" and not Storage:LoadBoolean("pocketslots_slot" .. pocketSlotId .. "_keepacrossmaps") then
						ent = Entities:FindByName(nil, entName)
						ent:EnableMotion() -- put item back from void, solution by FrostEpex
						ent:SetOrigin(traceTable.pos)
						ent:SetAngles(0,player_ang.y,0)
						ent:ApplyAbsVelocityImpulse(-GetPhysVelocity(ent))
					else
						ent = SpawnEntityFromTableSynchronous(itemsClasses[itemTypeId], { ["origin"]= traceTable.pos.x .. " " .. traceTable.pos.y .. " " .. traceTable.pos.z, ["angles"]= player_ang, ["targetname"]= Storage:LoadString("pocketslots_slot" .. pocketSlotId .. "_objname"), ["model"]= Storage:LoadString("pocketslots_slot" .. pocketSlotId .. "_objmodel") })
					end
					Storage:SaveString("pocketslots_slot" .. pocketSlotId .. "_objname", "")
					Storage:SaveString("pocketslots_slot" .. pocketSlotId .. "_objmodel", "")
					Storage:SaveBoolean("pocketslots_slot" .. pocketSlotId .. "_keepacrossmaps", false)
					--Storage:SaveVector("pocketslots_slot" .. pocketSlotId .. "_objrendercolor", Vector(0,0,0))
					DoEntFireByInstanceHandle(ent, "Use", "", 0, player, player) -- pickup quest item
				else -- generic object
					ent = SpawnEntityFromTableSynchronous(itemsClasses[itemTypeId], {["origin"]= traceTable.pos.x .. " " .. traceTable.pos.y .. " " .. traceTable.pos.z, ["angles"]= player_ang })
				end
			
				player:Attribute_SetIntValue("pocketslots_slot" .. pocketSlotId .. "" , 0)
				print("[WristPockets] Player has dropped item (Type " .. itemTypeId .. ") from slot #" .. pocketSlotId .. ".")
				WristPockets_UpdateHUD()
			end
		end 
	end
end, "Drop one item from pockets, if any exists", 0)
