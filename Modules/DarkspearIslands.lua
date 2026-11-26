
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	local strmatch = string.match
	local icon = {136441, C_Minimap.GetPOITextureCoords(45)}
	function mod:CHAT_MSG(msg)
		if strmatch(msg, L.capturedTheTrigger) then -- flag was captured
			self:StartBar(L.flagRespawns, 23, icon, "colorOther") -- White flag
		end
	end
end

function mod:EnterZone()
	self:StartFlagCaptures(60)
	self:StartScoreEstimator()
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(2997) -- Darkspear Islands
