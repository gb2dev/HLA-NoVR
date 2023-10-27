
function Precache(context)
	print("[Viewmodels] precache upgraded weapon models.")
	-- Precache pistol models
	PrecacheModel("models/weapons/v_pistol_shroud.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_shroud_ads.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_shroud_stock.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_shroud_stock_ads.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_stock.vmdl", context)
	-- Precache shotgun models
	PrecacheModel("models/weapons/v_shotgun_burst_grenade.vmdl", context)
    PrecacheModel("models/weapons/v_shotgun_burst.vmdl", context)
    PrecacheModel("models/weapons/v_shotgun_grenade.vmdl", context)
	-- Precache smg1 models
	PrecacheModel("models/weapons/v_smg1_holo.vmdl", context)
	PrecacheModel("models/weapons/v_smg1_holo_ads.vmdl", context)
	PrecacheModel("models/weapons/v_smg1_powerpack.vmdl", context)
	-- Precache fabricator models. Fix for error model - "WARNING: RESOURCE_TYPE_MODEL resource .. requested but is not in the system."
	PrecacheModel("models/weapons/vr_ipistol/vr_ipistol.vmdl", context)
	PrecacheModel("models/weapons/vr_shotgun/vr_flip_shotgun_body.vmdl", context)
	PrecacheModel("models/weapons/vr_shotgun/vr_flip_shotgun_magazine_tube.vmdl", context)
	PrecacheModel("models/weapons/vr_shotgun/vr_flip_shotgun_slider.vmdl", context)
	PrecacheModel("models/weapons/v_grenade_novr.vmdl", context)
end