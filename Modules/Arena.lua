
local mod
do
	local _, core = ...
	mod = core:NewMod()
end

do
	local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
	local tonumber, gsub, match = tonumber, string.gsub, string.match
	local GetSpellName = C_Spell.GetSpellName
	local GetSpellTexture = C_Spell.GetSpellTexture
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
						local spell = GetSpellName(34709)
						local icon = GetSpellTexture(34709)
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

mod:RegisterZone("arena")
