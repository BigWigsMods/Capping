
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	-- GetPOITextureCoords(45)
	local icon = {136441, 0.21484375, 0.28125, 0.21484375, 0.28125}
	function mod:CHAT_MSG(msg)
		if strmatch(msg, L.capturedTheTrigger) then -- flag was captured
			self:StartBar(L.flagRespawns, 12, icon, "colorOther") -- White flag
		end
	end
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber, gsub, strmatch = tonumber, string.gsub, string.match
	function mod:WSGTimeLeft(widgetInfo)
		if widgetInfo and widgetInfo.widgetID == 4330 then
			local tbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
			if tbl and tbl.state == 1 then
				local minutes = strmatch(tbl.text, "(%d+)")
				minutes = tonumber(minutes)
				if minutes and minutes < 16 then -- Starts at 25min, wait until 15min is left
					local remaining = minutes * 60
					local text = gsub(TIME_REMAINING, ":", "")
					self:StartBar(text, remaining, 134420, "colorOther", nil, minutes > 5 and 900 or 300) -- Interface/Icons/INV_Misc_Rune_07
				end
			end
		end
	end

	function mod:EnterZone()
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")
		self:RegisterEvent("UPDATE_UI_WIDGET", "WSGTimeLeft")
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
end

--mod:RegisterZone(2106)
mod:RegisterZone(489)
