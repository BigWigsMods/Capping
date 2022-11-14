
local mod, L, cap
do
	local _, core = ...
	mod, L, cap = core:NewMod()
end

do
	local UnitGUID, strsplit, GetNumGossipActiveQuests, SelectGossipActiveQuest = UnitGUID, strsplit, C_GossipInfo.GetNumActiveQuests, C_GossipInfo.SelectActiveQuest
	local tonumber, GetGossipOptions, GetItemCount = tonumber, C_GossipInfo.GetOptions, GetItemCount
	local blockedIds = {
		[30907] = true, -- alliance
		[30908] = true, -- alliance
		[30909] = true, -- alliance
		[35739] = true, -- horde
		[35740] = true, -- horde
		[35741] = true, -- horde
	}
	function mod:GOSSIP_SHOW()
		if not cap.db.profile.autoTurnIn then return end

		local target = UnitGUID("npc")
		if target then
			local _, _, _, _, _, id = strsplit("-", target)
			local mobId = tonumber(id)
			if mobId == 13176 or mobId == 13257 then -- Smith Regzar, Murgot Deepforge
				-- Open Quest to Smith or Murgot
				if self:GetGossipID(30904) then -- Alliance
					self:SelectGossipID(30904) -- Upgrade to seasoned units!
				elseif self:GetGossipID(30905) then -- Alliance
					self:SelectGossipID(30905) -- Upgrade to veteran units!
				elseif self:GetGossipID(30906) then -- Alliance
					self:SelectGossipID(30906) -- Upgrade to champion units!
				elseif self:GetGossipID(35736) then -- Horde
					self:SelectGossipID(35736) -- Upgrade to seasoned units!
				elseif self:GetGossipID(35737) then -- Horde
					self:SelectGossipID(35737) -- Upgrade to veteran units!
				elseif self:GetGossipID(35738) then -- Horde
					self:SelectGossipID(35738) -- Upgrade to champion units!
				else
					local gossipOptions = GetGossipOptions()
					if gossipOptions[1] then
						for i = 1, #gossipOptions do
							local gossipTable = gossipOptions[i]
							if not blockedIds[gossipTable.gossipOptionID] then
								print("|cFF33FF99Capping|r: NEW ID FOUND, TELL THE DEVS!", gossipTable.gossipOptionID, mobId, gossipTable.name)
								geterrorhandler()("|cFF33FF99Capping|r: NEW ID FOUND, TELL THE DEVS! ".. tostring(gossipTable.gossipOptionID) ..", ".. mobId ..", ".. tostring(gossipTable.name))
								return
							end
						end
					end
				end

				if GetItemCount(17422) >= 20 then -- Armor Scraps 17422
					if self:GetGossipAvailableQuestID(6781) then -- Alliance, More Armor Scraps
						self:SelectGossipAvailableQuestID(6781)
					elseif self:GetGossipAvailableQuestID(6741) then -- Horde, More Booty!
						self:SelectGossipAvailableQuestID(6741)
					elseif self:GetGossipAvailableQuestID(57318) then -- Horde, More Booty! [Specific to Korrak's Revenge]
						self:SelectGossipAvailableQuestID(57318)
					elseif self:GetGossipAvailableQuestID(57306) then -- Alliance, More Armor Scraps [Specific to Korrak's Revenge]
						self:SelectGossipAvailableQuestID(57306)
					end
				end
			elseif mobId == 13236 then -- Horde, Primalist Thurloga
				local num = GetItemCount(17306) -- Stormpike Soldier's Blood 17306
				if num > 0 then
					if GetNumGossipActiveQuests() > 0 then
						local tbl = C_GossipInfo.GetActiveQuests()
						for i = 1, #tbl do
							local questTable = tbl[i]
							print("|cFF33FF99Capping|r: NEW ACTIVE QUEST, TELL THE DEVS!", questTable.questID, mobId, questTable.title)
							geterrorhandler()("|cFF33FF99Capping|r: NEW ACTIVE QUEST, TELL THE DEVS! ".. tostring(questTable.questID) ..", ".. mobId ..", ".. tostring(questTable.title))
						end
						return
						SelectGossipActiveQuest(1)
					elseif self:GetGossipAvailableQuestID(7385) and num >= 5 then -- A Gallon of Blood
						self:SelectGossipAvailableQuestID(7385)
					elseif self:GetGossipAvailableQuestID(6801) then -- Lokholar the Ice Lord
						self:SelectGossipAvailableQuestID(6801)
					end
				end
			elseif mobId == 13442 then -- Alliance, Archdruid Renferal
				local num = GetItemCount(17423) -- Storm Crystal 17423
				if num > 0 then
					if GetNumGossipActiveQuests() > 0 then
						local tbl = C_GossipInfo.GetActiveQuests()
						for i = 1, #tbl do
							local questTable = tbl[i]
							print("|cFF33FF99Capping|r: NEW ACTIVE QUEST, TELL THE DEVS!", questTable.questID, mobId, questTable.title)
							geterrorhandler()("|cFF33FF99Capping|r: NEW ACTIVE QUEST, TELL THE DEVS! ".. tostring(questTable.questID) ..", ".. mobId ..", ".. tostring(questTable.title))
						end
						return
						SelectGossipActiveQuest(1)
					elseif self:GetGossipAvailableQuestID(7386) and num >= 5 then -- Crystal Cluster
						self:SelectGossipAvailableQuestID(7386)
					elseif self:GetGossipAvailableQuestID(6881) then -- Ivus the Forest Lord
						self:SelectGossipAvailableQuestID(6881)
					end
				end
			elseif mobId == 13577 then -- Alliance, Stormpike Ram Rider Commander
				print("|cFF33FF99Capping|r: RAM RIDER, TELL THE DEVS!", self:GetGossipAvailableQuestID(7026)) -- Don't think this is needed anymore, adding a print to see, v10.0.0
				geterrorhandler()("|cFF33FF99Capping|r: RAM RIDER, TELL THE DEVS! ".. tostring(self:GetGossipAvailableQuestID(7026)))
				if GetItemCount(17643) > 0 then -- Frost Wolf Hide 17643
					self:SelectGossipAvailableQuestID(7026)
				end
			elseif mobId == 13441 then -- Horde, Frostwolf Wolf Rider Commander
				print("|cFF33FF99Capping|r: WOLF RIDER, TELL THE DEVS!", self:GetGossipAvailableQuestID(7002)) -- Don't think this is needed anymore, adding a print to see, v10.0.0
				geterrorhandler()("|cFF33FF99Capping|r: WOLF RIDER, TELL THE DEVS! ".. tostring(self:GetGossipAvailableQuestID(7002)))
				if GetItemCount(17642) > 0 then -- Alterac Ram Hide 17642
					self:SelectGossipAvailableQuestID(7002) -- Ram Hide Harnesses
				end
			end
		end
	end
end

do
	local hasPrinted = false
	local function allowPrints()
		hasPrinted = false
	end
	local IsQuestCompletable, CompleteQuest = IsQuestCompletable, CompleteQuest
	function mod:QUEST_PROGRESS()
		if not cap.db.profile.autoTurnIn then return end
		if IsQuestCompletable() then
			CompleteQuest()
			if not hasPrinted then
				hasPrinted = true
				C_Timer.After(10, allowPrints)
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
local GetScoreInfo = C_PvP.GetScoreInfo
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local function AVSyncRequest()
	for i = 1, 80 do
		local scoreTbl = GetScoreInfo(i)
		if scoreTbl and scoreTbl.damageDone and scoreTbl.damageDone ~= 0 then
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

local currentWorldMapId = 91
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
				self:RestoreFlagCaptures(currentWorldMapId, inProgressDataTbl, 242)
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
	function mod:EnterZone(id)
		if id == 2197 then
			currentWorldMapId = 1537
			self:StartFlagCaptures(241, currentWorldMapId) -- Korrak's Revenge (WoW 15th)
		else
			currentWorldMapId = 91
			self:StartFlagCaptures(242, currentWorldMapId)
		end
		self:SetupHealthCheck("11946", L.hordeBoss, "Horde Boss", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		self:SetupHealthCheck("11948", L.allianceBoss, "Alliance Boss", 236444, "colorHorde") -- Interface/Icons/Achievement_Character_Dwarf_Male
		self:SetupHealthCheck("11947", L.galvangar, "Galvangar", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		self:SetupHealthCheck("11949", L.balinda, "Balinda", 236447, "colorHorde") -- Interface/Icons/Achievement_Character_Human_Female
		self:SetupHealthCheck("13419", L.ivus, "Ivus", 874581, "colorAlliance") -- Interface/Icons/inv_pet_ancientprotector_winter
		self:SetupHealthCheck("13256", L.lokholar, "Lokholar", 1373132, "colorHorde") -- Interface/Icons/Inv_infernalmounice.blp
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
mod:RegisterZone(2197) -- Korrak's Revenge (WoW 15th)
