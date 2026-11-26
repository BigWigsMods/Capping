
local mod, L, isRetail, isForever
do
	local _, core = ...
	mod, L = core:NewMod()
	isRetail = core.isRetail
	isForever = core.isForever
end

local strmatch = string.match
do
	local icon = (isRetail or isForever) and {136441, C_Minimap.GetPOITextureCoords(45)} or 134420 -- White flag, or inv_misc_rune_07 (WSG rune)
	function mod:CHAT_MSG(msg)
		if strmatch(msg, L.capturedTheTrigger) then -- flag was captured
			self:StartBar(L.flagRespawns, 12, icon, "colorOther")
		end
	end
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber = tonumber
	local NewTimer = C_Timer.NewTimer
	local timers = nil
	local prevMinutes = nil
	local function GetTimeRemaining()
		-- 6: WSG & TP, 630: TP old versions (changed at some point prior to 11.1.5)
		local tbl = GetIconAndTextWidgetVisualizationInfo(6) or GetIconAndTextWidgetVisualizationInfo(630)
		if tbl and tbl.text and tbl.state == 1 then
			local minutes, seconds = strmatch(tbl.text, "(%d+)[^%d]+(%d+)")
			minutes = tonumber(minutes)
			seconds = tonumber(seconds)
			if minutes and seconds then
				local remaining = seconds + (minutes*60) + 1
				local bar = mod:GetBar(L.timeRemaining)
				if remaining > 3 and (not bar or bar:GetRemainingTime() > remaining+5 or bar:GetRemainingTime() < remaining-5) then -- Don't restart bars for subtle changes +/- 5s
					mod:StartBar(L.timeRemaining, remaining, 134420, "colorOther") -- Interface/Icons/INV_Misc_Rune_07
				end
			end
		end
	end

	function mod:WSGTimeLeft(widgetInfo)
		if widgetInfo and widgetInfo.widgetID == 4330 then -- Wrath, not sure about Vanilla/TBC/Cata/Mists
			local tbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
			if tbl and tbl.text and tbl.state == 1 then
				local minutes = strmatch(tbl.text, "(%d+)")
				minutes = tonumber(minutes)
				if minutes and minutes > 0 and minutes < 16 and minutes ~= prevMinutes then -- Starts at 25min, wait until 15min is left
					prevMinutes = minutes
					local remaining = minutes * 60
					self:StartBar(L.timeRemaining, remaining, 134420, "colorOther", nil, minutes > 5 and 900 or 300) -- Interface/Icons/INV_Misc_Rune_07
				end
			end
		end
	end

	function mod:EnterZone()
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")
		if isRetail then
			timers = {
				NewTimer(5, GetTimeRemaining),
				NewTimer(30, GetTimeRemaining),
				NewTimer(60, GetTimeRemaining),
				NewTimer(130, GetTimeRemaining),
				NewTimer(240, GetTimeRemaining),
			}
		elseif not isForever then
			self:RegisterEvent("UPDATE_UI_WIDGET", "WSGTimeLeft")
		end
	end

	function mod:ExitZone()
		prevMinutes = nil
		if timers then
			for i = 1, #timers do
				timers[i]:Cancel()
			end
			timers = nil
		end
		self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
		self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
		self:UnregisterEvent("UPDATE_UI_WIDGET")
	end
end

mod:RegisterZone(2106) -- Warsong Gulch
mod:RegisterZone(489) -- Warsong Gulch classic
mod:RegisterZone(726) -- Twin Peaks
