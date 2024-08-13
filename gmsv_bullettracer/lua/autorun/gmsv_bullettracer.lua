require("gmsv")

local color_red = Color(255, 0, 0, 255)
local color_blue = Color(0, 0, 255, 255)
local color_white = Color(255, 255, 255, 255)

if SERVER then
	util.AddNetworkString("gmsv_BulletTracer")
end

gmsv.StartModule("BulletTracer")
do
	if CLIENT then
		local BoxMins = Vector(-2, -2, -2)
		local BoxMaxs = Vector(2, 2, 2)

		function DisplayTracer(self, StartPos, EndPos, Color)
			debugoverlay.Line(StartPos, EndPos, 3, Color)

			if Color ~= color_white then
				debugoverlay.Box(EndPos, BoxMins, BoxMaxs, 3, Color)
			end
		end

		net.Receive("gmsv_BulletTracer", function()
			if not self:GetEnabled() then return end

			local StartPos = net.ReadVector()
			local EndPos = net.ReadVector()

			self:DisplayTracer(StartPos, EndPos, color_blue)
		end)
	end

	function PostEntityFireBullets(Entity, Data)
		if SERVER then
			net.Start("gmsv_BulletTracer")
				net.WriteVector(Data.Trace.StartPos)
				net.WriteVector(Data.Trace.HitPos)
			net.Broadcast()
		elseif CLIENT then
			self:DisplayTracer(Data.Trace.StartPos, Data.Trace.HitPos, color_red)
		end
	end

	function OnEnabled(self)
		hook.Add("PostEntityFireBullets", self:GetName(), self.PostEntityFireBullets)
	end

	function OnDisabled(self)
		hook.Remove("PostEntityFireBullets", self:GetName())
	end
end
gmsv.EndModule()
