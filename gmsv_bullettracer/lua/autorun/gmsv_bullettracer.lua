require("gmsv")

local color_red = Color(255, 0, 0, 255)
local color_blue = Color(0, 0, 255, 255)
local color_white = Color(255, 255, 255, 255)

if SERVER then
	util.AddNetworkString("gmsv_BulletTracer")
end

gmsv.StartModule("BulletTracer")
do
	if SERVER then
		function EntityFireBullets(Entity, Data)
			local HullSize = Data.HullSize or 0
			local Hull = Vector(HullSize, HullSize, HullSize)

			local Trace = util.TraceHull({
				start = Data.Src,
				endpos = Data.Src + (Data.Dir * Data.Distance),
				mins = -Hull,
				maxs = Hull,
				filter = Entity
			})

			net.Start("gmsv_BulletTracer")
				net.WriteBool(true)
				net.WriteVector(Trace.StartPos)
				net.WriteVector(Trace.HitPos)
			net.Broadcast()
		end
	elseif CLIENT then
		net.Receive("gmsv_BulletTracer", function()
			if not self:GetEnabled() then return end

			local IsOrigin = net.ReadBool()
			local StartPos = net.ReadVector()
			local EndPos = net.ReadVector()

			debugoverlay.Line(StartPos, EndPos, 3, IsOrigin and color_white or color_blue)
		end)
	end

	function PostEntityFireBullets(Entity, Data)
		if SERVER then
			net.Start("gmsv_BulletTracer")
				net.WriteBool(false)
				net.WriteVector(Data.Trace.StartPos)
				net.WriteVector(Data.Trace.HitPos)
			net.Broadcast()
		elseif CLIENT then
			debugoverlay.Line(Data.Trace.StartPos, Data.Trace.HitPos, 3, color_red)
		end
	end

	function OnEnabled(self)
		if SERVER then
			hook.Add("EntityFireBullets", self:GetName(), self.EntityFireBullets)
		end

		hook.Add("PostEntityFireBullets", self:GetName(), self.PostEntityFireBullets)
	end

	function OnDisabled(self)
		if SERVER then
			hook.Remove("EntityFireBullets", self:GetName())
		end

		hook.Remove("PostEntityFireBullets", self:GetName())
	end
end
gmsv.EndModule()
