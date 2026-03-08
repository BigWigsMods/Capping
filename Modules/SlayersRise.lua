
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

do
	local colors = {
		["capPts-refinery-assaulted-alliance"] = "colorAlliance",
		["capPts-stadium-assaulted-alliance"] = "colorAlliance",
		["capPts-refinery-assaulted-horde"] = "colorHorde",
		["capPts-stadium-assaulted-horde"] = "colorHorde",
	}
	function mod:EnterZone()
		self:StartFlagCaptures(60, colors)
	end
end

function mod:ExitZone()
	self:StopFlagCaptures()
end

mod:RegisterZone(2799)
