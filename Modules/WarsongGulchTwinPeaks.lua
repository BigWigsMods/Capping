
local mod, L, isRetail
do
	local _, core = ...
	mod, L = core:NewMod()
	isRetail = core.isRetail
end

local strmatch = string.match
do
	local icon = {136441, C_Minimap.GetPOITextureCoords(45)}
	function mod:CHAT_MSG(msg)
		if strmatch(msg, L.capturedTheTrigger) then -- flag was captured
			self:StartBar(L.flagRespawns, 12, isRetail and icon or 134420, "colorOther") -- White flag, or inv_misc_rune_07 (WSG rune)
		end
	end
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber = tonumber
	local function GetTimeRemaining(self)
		-- 6: WSG & TP, 630: TP old versions (changed at some point prior to 11.1.5)
		local tbl = GetIconAndTextWidgetVisualizationInfo(6) or GetIconAndTextWidgetVisualizationInfo(630)
		if tbl and tbl.state == 1 then
			local minutes, seconds = strmatch(tbl.text, "(%d%d)[^%d]+(%d%d)")
			minutes = tonumber(minutes)
			seconds = tonumber(seconds)
			if minutes and seconds then
				local remaining = seconds + (minutes*60) + 1
				local bar = self:GetBar(L.timeRemaining)
				if remaining > 3 and (not bar or bar.remaining > remaining+5 or bar.remaining < remaining-5) then -- Don't restart bars for subtle changes +/- 5s
					self:StartBar(L.timeRemaining, remaining, 134420, "colorOther") -- Interface/Icons/INV_Misc_Rune_07
				end
			end
		end
	end

	function mod:WSGTimeLeft(widgetInfo)
		if widgetInfo and widgetInfo.widgetID == 4330 then -- Wrath, not sure about Vanilla/TBC/Cata/Mists
			local tbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
			if tbl and tbl.state == 1 then
				local minutes = strmatch(tbl.text, "(%d+)")
				minutes = tonumber(minutes)
				if minutes and minutes < 16 then -- Starts at 25min, wait until 15min is left
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
			local func = function() GetTimeRemaining(self) end
			self:Timer(5, func)
			self:Timer(30, func)
			self:Timer(60, func)
			self:Timer(130, func)
			self:Timer(240, func)
		else
			self:RegisterEvent("UPDATE_UI_WIDGET", "WSGTimeLeft")
		end
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
end

mod:RegisterZone(2106) -- Warsong Gultch
mod:RegisterZone(489) -- Warsong Gultch classic
mod:RegisterZone(726) -- Twin Peaks
