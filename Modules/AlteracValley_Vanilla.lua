
local mod, L, cap
do
	local _, core = ...
	mod, L, cap = core:NewMod()
end

local hasPrinted = false
do
	local UnitGUID, strsplit, GetNumGossipActiveQuests, SelectGossipActiveQuest = UnitGUID, strsplit, GetNumGossipActiveQuests, SelectGossipActiveQuest
	local tonumber, SelectGossipOption, GetGossipOptions, GetItemCount, SelectGossipAvailableQuest = tonumber, SelectGossipOption, GetGossipOptions, GetItemCount, SelectGossipAvailableQuest
	function mod:GOSSIP_SHOW()
		if not cap.db.profile.autoTurnIn then return end

		local target = UnitGUID("npc")
		if target then
			local _, _, _, _, _, id = strsplit("-", target)
			local mobId = tonumber(id)
			if mobId == 13176 or mobId == 13257 then -- Smith Regzar, Murgot Deepforge
				-- Open Quest to Smith or Murgot
				if GetGossipOptions() and strmatch(GetGossipOptions(), L.upgradeToTrigger) then
					SelectGossipOption(1)
				elseif GetItemCount(17422) >= 20 then -- Armor Scraps 17422
					SelectGossipAvailableQuest(1)
				end
			elseif mobId == 13236 then -- Primalist Thurloga
				local num = GetItemCount(17306) -- Stormpike Soldier's Blood 17306
				if num > 0 then
					if GetNumGossipActiveQuests() == 1 then
						SelectGossipActiveQuest(1)
					elseif num >= 5 then
						SelectGossipAvailableQuest(2)
					else
						SelectGossipAvailableQuest(1)
					end
				end
			elseif mobId == 13442 then -- Archdruid Renferal
				local num = GetItemCount(17423) -- Storm Crystal 17423
				if num > 0 then
					if GetNumGossipActiveQuests() == 1 then
						SelectGossipActiveQuest(1)
					elseif num >= 5 then
						SelectGossipAvailableQuest(2)
					else
						SelectGossipAvailableQuest(1)
					end
				end
			elseif mobId == 13577 then -- Stormpike Ram Rider Commander
				if GetItemCount(17643) > 0 then -- Frost Wolf Hide 17643
					SelectGossipAvailableQuest(1)
				end
			elseif mobId == 13441 then -- Frostwolf Wolf Rider Commander
				if GetItemCount(17642) > 0 then -- Alterac Ram Hide 17642
					SelectGossipAvailableQuest(1)
				end
			end
		end
	end
end

do
	local IsQuestCompletable, CompleteQuest = IsQuestCompletable, CompleteQuest
	function mod:QUEST_PROGRESS()
		if not cap.db.profile.autoTurnIn then return end
		self:GOSSIP_SHOW()
		if IsQuestCompletable() then
			CompleteQuest()
			if not hasPrinted then
				hasPrinted = true
				print(L.handIn)
			end
		end
	end
end

do
	local GetNumQuestRewards, GetQuestReward = GetNumQuestRewards, GetQuestReward
	function mod:QUEST_COMPLETE()
		if not cap.db.profile.autoTurnIn then return end
		if GetNumQuestRewards() == 0 then
			GetQuestReward(0)
		end
	end
end

local NewTicker = C_Timer.NewTicker
local hereFromTheStart, hasData = true, true
local stopTimer = nil
local function allow() hereFromTheStart = false end
local function stop() hereFromTheStart = true hasData = true stopTimer = nil end
--local GetScoreInfo = C_PvP.GetScoreInfo
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local function AVSyncRequest()
	for i = 1, 80 do
		local _, _, _, _, _, _, _, _, _, _, damageDone = GetBattlefieldScore(i)
		if damageDone and damageDone ~= 0 then
			hereFromTheStart = true
			hasData = false
			mod:Timer(0.5, allow)
			stopTimer = NewTicker(3, stop, 1)
			SendAddonMessage("Capping", "tr", "INSTANCE_CHAT")
			return
		end
	end

	hereFromTheStart = true
	hasData = true
end

do
	local timer = nil
	local function SendAVTimers()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local str = ""
			for bar in next, CappingFrame.bars do
				local poiId = bar:Get("capping:poiid")
				if poiId then
					str = string.format("%s%d-%d~", str, poiId, math.floor(bar.remaining))
				end
			end

			if str ~= "" and string.len(str) < 250 then
				SendAddonMessage("Capping", str, "INSTANCE_CHAT")
			end
		end
	end

	do
		local function Unwrap(self, ...)
			local inProgressDataTbl = {}
			for i = 1, select("#", ...) do
				local arg = select(i, ...)
				local id, remaining = strsplit("-", arg)
				if id and remaining then
					local widget, barTime = tonumber(id), tonumber(remaining)
					if widget and barTime and barTime > 5 and barTime < 245 then
						inProgressDataTbl[widget] = barTime
					end
				end
			end

			if next(inProgressDataTbl) then
				self:RestoreFlagCaptures(91, inProgressDataTbl, 242)
			end
		end

		local me = UnitName("player").. "-" ..GetRealmName()
		function mod:CHAT_MSG_ADDON(prefix, msg, channel, sender)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				if msg == "tr" and sender ~= me then -- timer request
					if hasData then -- Joined a late game, don't send data
						if timer then timer:Cancel() end
						timer = NewTicker(1, SendAVTimers, 1)
					elseif stopTimer then
						stopTimer:Cancel()
						stopTimer = NewTicker(3, stop, 1)
					end
				elseif not hereFromTheStart and sender ~= me and msg:find("~", nil, true) then
					hereFromTheStart = true
					hasData = true
					Unwrap(self, strsplit("~", msg))
				end
			end
		end
	end
end

do
	local RequestBattlefieldScoreData = RequestBattlefieldScoreData
	function mod:EnterZone()
		hasPrinted = false
		--local _, _, _, _, _, _, _, id = GetInstanceInfo()
		--if id == 1537 then
		--	self:StartFlagCaptures(242, 1537) -- Korrak's Revenge (WoW 15th)
		--else
		--	self:StartFlagCaptures(242, 91)
		--end
		self:StartFlagCaptures(300, 1459)
		self:SetupHealthCheck("11946", L.hordeBoss, "Horde Boss", 134170, "colorAlliance") -- Interface/Icons/Inv_misc_head_orc_01
		self:SetupHealthCheck("11948", L.allianceBoss, "Alliance Boss", 134159, "colorHorde") -- Interface/Icons/inv_misc_head_dwarf_01
		self:SetupHealthCheck("11947", L.galvangar, "Galvangar", 134170, "colorAlliance") -- Interface/Icons/Inv_misc_head_orc_01
		self:SetupHealthCheck("11949", L.balinda, "Balinda", 134167, "colorHorde") -- Interface/Icons/inv_misc_head_human_02
		self:SetupHealthCheck("13419", L.ivus, "Ivus", 132129, "colorAlliance") -- Interface/Icons/ability_druid_forceofnature
		self:SetupHealthCheck("13256", L.lokholar, "Lokholar", 135861, "colorHorde") -- Interface/Icons/spell_frost_summonwaterelemental
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("GOSSIP_SHOW")
		self:RegisterEvent("QUEST_PROGRESS")
		self:RegisterEvent("QUEST_COMPLETE")
		RequestBattlefieldScoreData()
		self:Timer(1, function() RequestBattlefieldScoreData() end)
		self:Timer(2, AVSyncRequest)
	end
end

function mod:ExitZone()
	self:UnregisterEvent("GOSSIP_SHOW")
	self:UnregisterEvent("QUEST_PROGRESS")
	self:UnregisterEvent("QUEST_COMPLETE")
	self:UnregisterEvent("CHAT_MSG_ADDON")
	self:StopFlagCaptures()
	self:StopHealthCheck()
end

mod:RegisterZone(30)
--mod:RegisterZone(2197) -- Korrak's Revenge (WoW 15th)
