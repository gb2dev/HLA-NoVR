Convars:RegisterConvar("sv_jump_force", "150", "The force applied to the player when jumping", 0)

Convars:RegisterCommand("jumpfixed", function()
	local player = Entities:GetLocalPlayer()
	if player:GetVelocity().z == 0 then 
		player:ApplyAbsVelocityImpulse(Vector(0,0,300))
		player:SetThink(normalizeJump, self, 0.02)
	end
end, "Jump, but fixed!", 0)

function normalizeJump(player)
	local vel = player:GetVelocity()
	player:SetVelocity(Vector(vel.x, vel.y, Convars:GetFloat("sv_jump_force")))
end