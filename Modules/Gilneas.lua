
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

function mod:EnterZone()
	-- C_PvP.IsSoloRBG doesn't exist on Cata/Mists
	self:StartFlagCaptures(C_PvP.IsSoloRBG and C_PvP.IsSoloRBG() and 30 or 60) -- 30 sec when solo RBG, 60 otherwise
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(761)
