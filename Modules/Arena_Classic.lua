
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	local GetSpellInfo = GetSpellInfo
	function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
		if msg == L.arenaStartTrigger then
			self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
			local spell, _, icon = GetSpellInfo(34709)
			self:StartBar(spell, 95, icon, "colorOther")
		end
	end
end

function mod:EnterZone()
	-- What we can NOT use for Shadow Sight timer
	-- COMBAT_LOG_EVENT_UNFILTERED for Arena Preparation removal event, it randomly removes and reapplies itself during the warmup
	-- UNIT_SPELLCAST_SUCCEEDED arena1-5 events, probably won't work if the entire enemy team is stealth
	-- What we CAN use for Shadow Sight timer
	-- CHAT_MSG_BG_SYSTEM_NEUTRAL#The Arena battle has begun! - Requires localization
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
end

mod:RegisterZone(559) -- Nagrand Arena
mod:RegisterZone(562) -- Blade's Edge Arena
mod:RegisterZone(572) -- Ruins of Lordaeron
mod:RegisterZone(617) -- Dalaran Sewers
