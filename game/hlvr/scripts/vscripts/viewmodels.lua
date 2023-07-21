
-- Display upgraded weapon viewmodels by withoutaface

local function PrecacheViewModels()
    local ent_table = { -- used solution by SoMNst & Epic
        targetname = "novr_precacheviewmodels",
		vscripts = "viewmodels_precache.lua"
    }
	SpawnEntityFromTableAsynchronous("logic_script", ent_table, nil, nil);
end

-- Init is called in novr.lua
function Viewmodels_Init()
    -- Precache the viewmodels
    PrecacheViewModels()
    -- Set model after map load
    local player = Entities:GetLocalPlayer()
    player:SetThink(function()
        Viewmodels_UpgradeModel()
    end, "ViewmodelUpgradeInit", 1)
end

-- Check for weapon upgrades and set the correct viewmodel
function Viewmodels_UpgradeModel()
    local player = Entities:GetLocalPlayer()

    -- Fetch pistol upgrades
    local pistol_aimdownsights = player:Attribute_GetIntValue("pistol_upgrade_aimdownsights", 0)
    local pistol_burstfire = player:Attribute_GetIntValue("pistol_upgrade_burstfire", 0)

    -- List of pistol viewmodels
    local pistol_search_str = "v_pistol"
    local pistol_viewmodel_shroud_stock = "models/weapons/v_pistol_shroud_stock.vmdl"
    local pistol_viewmodel_stock = "models/weapons/v_pistol_stock.vmdl"
    local pistol_viewmodel_shroud = "models/weapons/v_pistol_shroud.vmdl"
    local pistol_viewmodel_base = "models/weapons/v_pistol.vmdl"

    -- Update weapon viewmodel
    local viewmodel = Entities:FindByClassname(nil, "viewmodel")
    if viewmodel then
        local viewmodel_name = viewmodel:GetModelName()
        --print(string.format("found viewmodel %s", viewmodel_name))
        
        -- Set upgraded pistol viewmodels
        if string.match(viewmodel_name, pistol_search_str) then
            -- shroud and stock
            if pistol_aimdownsights == 1 and pistol_burstfire == 1 then
                if string.match(viewmodel_name, pistol_viewmodel_shroud_stock) then
                    return
                else
                    viewmodel:SetModel(pistol_viewmodel_shroud_stock)
                    print(string.format("Viewmodels - pistol: %s (aimdownsights %s, burstfire %s)", pistol_viewmodel_shroud_stock, pistol_aimdownsights, pistol_burstfire))
                    return
                end
            -- shroud
            elseif pistol_aimdownsights == 1 and pistol_burstfire == 0 then
                if string.match(viewmodel_name, pistol_viewmodel_shroud) then
                    return
                else
                    viewmodel:SetModel(pistol_viewmodel_shroud)
                    print(string.format("Viewmodels - pistol: %s (aimdownsights %s, burstfire %s)", pistol_viewmodel_shroud_stock, pistol_aimdownsights, pistol_burstfire))
                    return
                end
            -- stock
            elseif pistol_aimdownsights == 0 and pistol_burstfire == 1 then
                if string.match(viewmodel_name, pistol_viewmodel_stock) then
                    return
                else
                    viewmodel:SetModel(pistol_viewmodel_stock)
                    print(string.format("Viewmodels - pistol: %s (aimdownsights %s, burstfire %s)", pistol_viewmodel_shroud_stock, pistol_aimdownsights, pistol_burstfire))
                    return
                end
            end
        end
    end
end

-- Function to call after weapon switch
Convars:RegisterCommand("viewmodel_update" , function()
    local player = Entities:GetLocalPlayer()
    player:SetThink(function()
        Viewmodels_UpgradeModel()
    end, "ViewmodelUpdate", 0)
end, "function viewmodel_update", 0)
