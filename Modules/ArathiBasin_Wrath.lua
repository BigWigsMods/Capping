
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

local instanceIdToMapId = {
	[529] = 1461, -- Arathi Basin Classic
	--[2107] = 93, -- Arathi Basin
	--[1681] = 837, -- Arathi Basin Snowy PvP Brawl
	--[2177] = 1383, -- Arathi Basin Brawl Vs AI
}

function mod:EnterZone(id)
	self:StartFlagCaptures(65, instanceIdToMapId[id])
	self:StartScoreEstimatorAB()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

for k in next, instanceIdToMapId do
	mod:RegisterZone(k)
end
