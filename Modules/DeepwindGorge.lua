
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	local colors = {
		["dg_capPts-leftIcon2-state1"] = "colorAlliance",
		["dg_capPts-leftIcon3-state1"] = "colorAlliance",
		["dg_capPts-leftIcon4-state1"] = "colorAlliance",
		["dg_capPts-rightIcon2-state1"] = "colorHorde",
		["dg_capPts-rightIcon3-state1"] = "colorHorde",
		["dg_capPts-rightIcon4-state1"] = "colorHorde",
	}
	function mod:EnterZone()
		self:StartFlagCaptures(61, 519, colors)
		self:StartScoreEstimator()
	end
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(1105)
