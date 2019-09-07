
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod("Twin Peaks")
end

do
	local icon = {136441}
	--[1]=0.21484375
	--[2]=0.28125
	--[3]=0.107421875
	--[4]=0.140625
	icon[2], icon[3], icon[4], icon[5] = GetPOITextureCoords(45)
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
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")

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
