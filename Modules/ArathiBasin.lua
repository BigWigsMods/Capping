
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

function mod:EnterZone()
	self:StartFlagCaptures(60)
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(2107) -- Arathi Basin
mod:RegisterZone(529) -- Arathi Basin Classic
mod:RegisterZone(1681) -- Arathi Basin Snowy PvP Brawl
mod:RegisterZone(2177) -- Arathi Basin Brawl Vs AI
