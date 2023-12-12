require "storage"
function Precache(context)
	print("[WristPockets] Common models precache attempt.") 
	-- can't read player storage on that stage, so precache all possible variants
	PrecacheModel("models/weapons/vr_alyxhealth/vr_health_pen.vmdl", context)
	PrecacheModel("models/weapons/vr_alyxhealth/vr_health_pen_capsule.vmdl", context)
	PrecacheModel("models/weapons/vr_grenade/grenade_handle.vmdl", context)
	PrecacheModel("models/props/distillery/bottle_vodka.vmdl", context)
	PrecacheModel("models/weapons/vr_xen_grenade/vr_xen_grenade.vmdl", context)
end
