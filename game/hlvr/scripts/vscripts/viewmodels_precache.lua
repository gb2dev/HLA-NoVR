
function Precache(context)
	print("[Viewmodels] precache upgraded weapon models.")
	-- Precache pistol models
	PrecacheModel("models/weapons/v_pistol_shroud.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_shroud_stock.vmdl", context)
	PrecacheModel("models/weapons/v_pistol_stock.vmdl", context)
end