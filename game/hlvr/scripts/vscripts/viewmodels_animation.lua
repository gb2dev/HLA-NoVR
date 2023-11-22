
-- Play viewmodel animations by withoutaface

local smg_viewmodel_holo = "models/weapons/v_smg1_holo.vmdl"
local smg_viewmodel_holo_ads = "models/weapons/v_smg1_holo_ads.vmdl"
local pistol_viewmodel_shroud = "models/weapons/v_pistol_shroud.vmdl"
local pistol_viewmodel_shroud_ads = "models/weapons/v_pistol_shroud_ads.vmdl"
local pistol_viewmodel_shroud_stock = "models/weapons/v_pistol_shroud_stock.vmdl"
local pistol_viewmodel_shroud_stock_ads = "models/weapons/v_pistol_shroud_stock_ads.vmdl"

-- LevelChange is called in novr.lua
function ViewmodelAnimation_LevelChange()
    -- Reset animation after map load
    local player = Entities:GetLocalPlayer()
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")

    player:SetThink(function()
        --ViewmodelAnimation_Reset()
        viewmodel:ResetSequence("anim_prepare")
    end, "ViewmodelAnimationLevelChange", 1)

    player:SetThink(function()
        viewmodel:ResetSequence("idle")
    end, "ViewmodelAnimationLevelChangeIdle", 2)
end

function ViewmodelAnimation_ADSZoom()
    -- Prepare ads zoom objects
    local player = Entities:GetLocalPlayer()

    player:SetThink(function()
        SendToConsole("ent_remove ads_zoom")
        SendToConsole(string.format("ent_create env_zoom { targetname ads_zoom FOV %s rate 0.7 }", FOV_ADS_ZOOM))
    end, "ViewmodelAnimationADSZoom", 1)

    print("[ViewmodelAnimation] ads zoom preparation done")
end

local function ViewmodelAnimation_PrepareAnimation(viewmodel, player)
    -- Play a short animation so viewmodel will end it's cycle and has no active animation
    viewmodel:ResetSequence("anim_prepare")

    -- Sigh, without reset to idle animation the actual animation will not play. But why?
    player:SetThink(function()
        viewmodel:ResetSequence("idle")
    end, "ViewmodelIdlePrepareAnimation", 0.1)
    -- If below 0.1 animations may not play!
end

function ViewmodelAnimation_ResetAnimation()
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    if viewmodel then
        local viewmodel_name = viewmodel:GetModelName()
        print(string.format("Reset idle animation for viewmodel %s", viewmodel_name))

		viewmodel:ResetSequence("idle")
	end
end

function ViewmodelAnimation_PlayInspectAnimation()
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    local player = Entities:GetLocalPlayer()

    if viewmodel then
        local viewmodel_name = viewmodel:GetModelName()
		local viewmodel_sequence = viewmodel:GetSequence()

        if true then--string.match(viewmodel_name, "v_pistol") or string.match(viewmodel_name, "v_smg1") then
            print(string.format("Play inspect for viewmodel %s on sequence %s", viewmodel_name, viewmodel_sequence))
            
            -- Set animation play length per model
            animation_time = 1.0
            if string.match(viewmodel_name, "v_pistol") then 
                animation_time = 3.6
            end

            ViewmodelAnimation_PrepareAnimation(viewmodel, player)

            -- Inspect animation
            player:SetThink(function()
                viewmodel:ResetSequence("use")
            end, "ViewmodelInspectAnimation", 0.12)

            player:SetThink(function()
                viewmodel:ResetSequence("idle")
            end, "ViewmodelIdleAnimation", animation_time)
        end
	end
end

function ViewmodelAnimation_HIPtoADS()
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    local player = Entities:GetLocalPlayer()

    if viewmodel then        
        local viewmodel_name = viewmodel:GetModelName()
		local viewmodel_sequence = viewmodel:GetSequence()

        -- smg1 holo
        if string.match(viewmodel_name, smg_viewmodel_holo) then
            viewmodel:SetModel(smg_viewmodel_holo_ads)
        end

        -- pistol
        if string.match(viewmodel_name, pistol_viewmodel_shroud) then
            viewmodel:SetModel(pistol_viewmodel_shroud_ads)
        end
        if string.match(viewmodel_name, pistol_viewmodel_shroud_stock) then
            viewmodel:SetModel(pistol_viewmodel_shroud_stock_ads)
        end
        
        viewmodel_name = viewmodel:GetModelName()
		print(string.format("Play hip to ads for viewmodel %s on sequence %s", viewmodel_name, viewmodel_sequence))

		ViewmodelAnimation_PrepareAnimation(viewmodel, player)
        
        -- HIP_TO_ADS
        player:SetThink(function()
            viewmodel:ResetSequence("hip_to_ads")
        end, "ViewmodelHIPtoADSAnimation", 0.12)

	end
end

function ViewmodelAnimation_ADStoHIP()
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    local player = Entities:GetLocalPlayer()

    if viewmodel then
        local viewmodel_name = viewmodel:GetModelName()
		local viewmodel_sequence = viewmodel:GetSequence()

        -- smg1 holo
        if string.match(viewmodel_name, smg_viewmodel_holo_ads) then
            viewmodel:SetModel(smg_viewmodel_holo)
        end
        
        -- pistol
        if string.match(viewmodel_name, pistol_viewmodel_shroud_ads) then
            viewmodel:SetModel(pistol_viewmodel_shroud)
        end
        if string.match(viewmodel_name, pistol_viewmodel_shroud_stock_ads) then
            viewmodel:SetModel(pistol_viewmodel_shroud_stock)
        end
        
        viewmodel_name = viewmodel:GetModelName()
		print(string.format("Play ads to hip for viewmodel %s on sequence %s", viewmodel_name, viewmodel_sequence))

        -- ADS_TO_HIP
        viewmodel:ResetSequence("ads_to_hip")
        
        player:SetThink(function()
            ViewmodelAnimation_ResetAnimation()
        end, "ViewmodelADStoHIPAnimation", 0.4)
	end
end

function ViewmodelAnimation_Reset()
    ViewmodelAnimation_ResetAnimation()
    cvar_setf("fov_desired", FOV)
    cvar_setf("viewmodel_offset_x", 0)
    cvar_setf("viewmodel_offset_y", 0)
    cvar_setf("viewmodel_offset_z", 0)
end

Convars:RegisterCommand("viewmodel_inspect_animation" , function()
	ViewmodelAnimation_PlayInspectAnimation()
end, "ViewmodelInspectAnimation", 0)

Convars:RegisterCommand("viewmodel_reset" , function()
	ViewmodelAnimation_Reset()
end, "ViewmodelResetAnimation", 0)
