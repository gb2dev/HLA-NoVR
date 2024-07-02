require "storage"
function Precache(context)
	print("[NoVR] Models precache attempt.") 
	PrecacheModel("models/props/choreo_office/gnome.vmdl", context)
	PrecacheModel("models/props/hazmat/respirator_01a.vmdl", context)
end
