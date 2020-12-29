
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber, gsub, match, GetSpellInfo = tonumber, string.gsub, string.match, GetSpellInfo
	function mod:UPDATE_UI_WIDGET(tbl)
		if tbl.widgetSetID == 1 and tbl.widgetType == 0 then
			local id = tbl.widgetID
			local dataTbl = GetIconAndTextWidgetVisualizationInfo(id)
			if dataTbl and dataTbl.text and dataTbl.state == 1 then
				local minutes, seconds = match(dataTbl.text, "(%d+):(%d+)")
				minutes = tonumber(minutes)
				seconds = tonumber(seconds)
				if minutes and seconds then
					local remaining = seconds + (minutes*60) + 1
					if remaining > 4 then
						self:UnregisterEvent("UPDATE_UI_WIDGET")
						local spell, _, icon = GetSpellInfo(34709)
						self:StartBar(spell, 93, icon, "colorOther")
						local text = gsub(TIME_REMAINING, ":", "")
						self:StartBar(text, remaining, nil, "colorOther")
					end
				end
			end
		end
	end
end

function mod:EnterZone()
	-- What we can NOT use for Shadow Sight timer
	-- COMBAT_LOG_EVENT_UNFILTERED for Arena Preparation removal event, it randomly removes and reapplies itself during the warmup
	-- UNIT_SPELLCAST_SUCCEEDED arena1-5 events, probably won't work if the entire enemy team is stealth
	-- What we CAN use for Shadow Sight timer
	-- CHAT_MSG_BG_SYSTEM_NEUTRAL#The Arena battle has begun! - Requires localization
	-- UPDATE_UI_WIDGET The first event fired with a valid remaining time (the current chosen method)
	self:RegisterEvent("UPDATE_UI_WIDGET")
end

function mod:ExitZone()
	self:UnregisterEvent("UPDATE_UI_WIDGET")
end

mod:RegisterZone(572) -- Ruins of Lordaeron
mod:RegisterZone(617) -- Dalaran Sewers
mod:RegisterZone(980) -- Tol'Viron Arena
mod:RegisterZone(1134) -- The Tiger's Peak
mod:RegisterZone(1504) -- Black Rook Hold Arena
mod:RegisterZone(1505) -- Nagrand Arena
mod:RegisterZone(1552) -- Ashamane's Fall
mod:RegisterZone(1672) -- Blade's Edge Arena
mod:RegisterZone(1825) -- Hook Point
mod:RegisterZone(1911) -- Mugambala
mod:RegisterZone(2167) -- The Robodrome
mod:RegisterZone(2373) -- Empyrean Domain
