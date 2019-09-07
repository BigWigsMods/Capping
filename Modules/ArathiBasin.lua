
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod("Arathi Basin")
end

local instanceIdToMapId = {
	[2107] = 93, -- Arathi Basin
	[1681] = 837, -- Arathi Basin Snowy PvP Brawl
	[2177] = 1383, -- Arathi Basin Brawl Vs AI
}

function mod:EnterZone(id)
	--SetupAssault(60, instanceIdToMapId[id])
	--NewEstimator()
end

function mod:ExitZone()
	
end

for k in next, instanceIdToMapId do
	mod:RegisterZone(k)
end
