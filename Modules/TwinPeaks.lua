
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	-- GetPOITextureCoords(45)
	local icon = {136441, 0.21484375, 0.28125, 0.107421875, 0.140625}
	function mod:CHAT_MSG(msg)
		if strmatch(msg, L.capturedTheTrigger) then -- flag was captured
			self:StartBar(L.flagRespawns, 12, icon, "colorOther") -- White flag
		end
	end
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber, gsub = tonumber, string.gsub
	local function GetTimeRemaining(self)
		local tbl = GetIconAndTextWidgetVisualizationInfo(630)
		if tbl and tbl.state == 1 then
			local minutes, seconds = strmatch(tbl.text, "(%d+):(%d+)")
			minutes = tonumber(minutes)
			seconds = tonumber(seconds)
			if minutes and seconds then
				local remaining = seconds + (minutes*60) + 1
				local text = gsub(TIME_REMAINING, ":", "")
				local bar = self:GetBar(text)
				if remaining > 3 and (not bar or bar.remaining > remaining+5 or bar.remaining < remaining-5) then -- Don't restart bars for subtle changes +/- 5s
					self:StartBar(text, remaining, 134420, "colorOther") -- Interface/Icons/INV_Misc_Rune_07
				end
			end
		end
	end

	function mod:EnterZone()
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")

		local func = function() GetTimeRemaining(self) end
		self:Timer(5, func)
		self:Timer(30, func)
		self:Timer(60, func)
		self:Timer(130, func)
		self:Timer(240, func)
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
end

mod:RegisterZone(726)
