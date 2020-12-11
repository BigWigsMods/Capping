
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

function mod:EnterZone()
	self:StartFlagCaptures(60, 1576)
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(2245)
