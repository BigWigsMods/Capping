
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

do
	local poiEnglishNames = {
		-- Darkspear Islands (map 2997)
		[8768] = "Camp",
		[8771] = "Ruins",
		[8772] = "Abandoned Tower",
		[8773] = "Shipwreck Cove",
	}
	function mod:EnterZone()
		self:StartFlagCaptures(60, nil, poiEnglishNames)
		self:StartScoreEstimator()
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(2997) -- Darkspear Islands
