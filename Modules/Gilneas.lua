
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

function mod:EnterZone()
	self:StartFlagCaptures(60, 275) -- Base cap time, uiMapID
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(761)
