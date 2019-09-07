
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod("Gilneas")
end

function mod:EnterZone()
	--SetupAssault(60, 275) -- Base cap time, uiMapID
	--NewEstimator()
end

function mod:ExitZone()
	
end

mod:RegisterZone(761)
