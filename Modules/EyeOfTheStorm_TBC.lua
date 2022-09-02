
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	-- GetPOITextureCoords(45)
	local icon = {136441, 0.625, 0.75, 0.625, 0.75}
	function mod:CHAT_MSG(msg)
		local found = strmatch(msg, L.takenTheFlagTrigger)
		if (found and found == "L'Alliance") or strmatch(msg, L.capturedTheTrigger) then -- frFR
			self:StartBar(L.flagRespawns, 21, icon, "colorOther") -- White flag
		end
	end
end

do
	-- EotS PvP Brawl: Gravity Lapse
	local ticker1, ticker2 = nil, nil
	local extraMsg = nil
	local color = {r=0,g=1,b=0}
	local NewTicker = C_Timer.NewTicker
	local function PrintExtraMessage()
		local _, _, _, _, _, _, _, id = GetInstanceInfo()
		if extraMsg and id == 566 then -- Check the game isn't over
			RaidNotice_AddMessage(RaidBossEmoteFrame, extraMsg, color, 3)
		end
	end
	local function StartNextGravTimer()
		local _, _, _, _, _, _, _, id = GetInstanceInfo()
		if id == 566 then -- Check the game isn't over
			local name, _, icon = GetSpellInfo(44224) -- Gravity Lapse
			mod:StartBar(name, 55, icon, "colorOther")
			ticker1 = NewTicker(55, StartNextGravTimer, 1) -- Compensate for being dead (you don't get the message)
			ticker2 = NewTicker(50, PrintExtraMessage, 1)
		end
	end
	function mod:RAID_BOSS_WHISPER(msg)
		if msg:find("15", nil, true) then
			if not extraMsg then
				extraMsg = msg:gsub("1", "")
			end
			local name, _, icon = GetSpellInfo(44224) -- Gravity Lapse
			self:StartBar(name, 15, icon, "colorOther")
			self:Timer(15, StartNextGravTimer)
			self:Timer(10, PrintExtraMessage)
			if ticker1 then
				ticker1:Cancel()
				ticker2:Cancel()
				ticker1, ticker2 = nil, nil
			end
		end
	end
end

do
	--local colors = {
	--	["eots_capPts-leftIcon2-state1"] = "colorAlliance",
	--	["eots_capPts-leftIcon3-state1"] = "colorAlliance",
	--	["eots_capPts-leftIcon4-state1"] = "colorAlliance",
	--	["eots_capPts-leftIcon5-state1"] = "colorAlliance",
	--	["eots_capPts-rightIcon2-state1"] = "colorHorde",
	--	["eots_capPts-rightIcon3-state1"] = "colorHorde",
	--	["eots_capPts-rightIcon4-state1"] = "colorHorde",
	--	["eots_capPts-rightIcon5-state1"] = "colorHorde",
	--}
	function mod:EnterZone()
		self:StartScoreEstimator()
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG")
		--if id == 566 then -- Normal/Brawl
		--	self:RegisterEvent("RAID_BOSS_WHISPER")
		--else -- Rated
		--	self:StartFlagCaptures(60, 397, colors)
		--end
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	--self:UnregisterEvent("RAID_BOSS_WHISPER")
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(566)
--mod:RegisterZone(968) -- In RBG the four points have flags that need to be assaulted, like AB
