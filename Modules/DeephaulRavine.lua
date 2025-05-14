
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

function mod:EnterZone()
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
end

mod:RegisterZone(2656)
