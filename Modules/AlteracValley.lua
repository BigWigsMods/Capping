
local mod, L, cap, isRetail
do
	local _, core = ...
	mod, L, cap = core:NewMod()
	isRetail = core.isRetail
end

do
	local GetNumGossipActiveQuests = C_GossipInfo.GetNumActiveQuests
	local GetGossipActiveQuests = C_GossipInfo.GetActiveQuests
	local GetNumGossipAvailableQuests = C_GossipInfo.GetNumAvailableQuests
	local GetGossipAvailableQuests = C_GossipInfo.GetAvailableQuests
	local GetGossipOptions = C_GossipInfo.GetOptions
	local GetItemCount = C_Item.GetItemCount
	local IsQuestComplete = C_QuestLog.IsComplete
	local UnitFactionGroup = UnitFactionGroup
	local UnitIsMercenary = UnitIsMercenary

	local knownBadGossipIDs = {
		-- Open Quest to Smith or Murgot
		[30907] = true, -- alliance
		[30908] = true, -- alliance
		[30909] = true, -- alliance
		[35739] = true, -- horde
		[35740] = true, -- horde
		[35741] = true, -- horde

		[29176] = true, -- How many more supplies are needed to send ground assaults? [Stormpike Quartermaster (12096) - Alliance]
		[97018] = true, -- How many more supplies are needed to send ground assaults? [Stormpike Quartermaster (12096) - Alliance] (WoW Forever)
		[29178] = true, -- I want to browse your goods. [Stormpike Quartermaster (12096) - Alliance]
		[97016] = true, -- I want to browse your goods. [Stormpike Quartermaster (12096) - Alliance] (WoW Forever)
		[32488] = true, -- How many more supplies are needed to send a ground assault? [Frostwolf Quartermaster (12097) - Horde]
		[32490] = true, -- I want to browse your goods. [Frostwolf Quartermaster (12097) - Horde]

		[31070] = true, -- Where is the Stormpike Quartermaster? [Corporal Noreg Stormpike (13447) - Alliance]
		[31071] = true, -- Where is the Stormpike Quartermaster? [Corporal Noreg Stormpike (13447) - Alliance]
		[34597] = true, -- Where is the Frostwolf Quartermaster? [Sergeant Yazra Bloodsnarl (13448) - Horde]
		[34598] = true, -- Where is the Frostwolf Quartermaster? [Sergeant Yazra Bloodsnarl (13448) - Horde]

		[33622] = true, -- Tell me about Alterac Valley. [Stormpike Herald (11997) - Alliance]
		[97630] = true, -- Tell me about Alterac Valley. [Stormpike Herald (11997) - Alliance] (WoW Forever)
		[33623] = true, -- Tell me about graveyards. [Stormpike Herald (11997) - Alliance]
		[97629] = true, -- Tell me about graveyards. [Stormpike Herald (11997) - Alliance] (WoW Forever)
		[33624] = true, -- Tell me about mines. [Stormpike Herald (11997) - Alliance]
		[97628] = true, -- Tell me about mines. [Stormpike Herald (11997) - Alliance] (WoW Forever)
		[33625] = true, -- Tell me about towers. [Stormpike Herald (11997) - Alliance]
		[97627] = true, -- Tell me about towers. [Stormpike Herald (11997) - Alliance] (WoW Forever)
		[29172] = true, -- Tell me about Alterac Valley. [Frostwolf Herald (11998) - Horde]
		[29173] = true, -- Tell me about graveyards. [Frostwolf Herald (11998) - Horde]
		[29174] = true, -- Tell me about mines. [Frostwolf Herald (11998) - Horde]
		[29175] = true, -- Tell me about towers. [Frostwolf Herald (11998) - Horde]

		[30482] = true, -- Have you made contact with Ivus, Archdruid? [Archdruid Renferal (13442) - Alliance]
		[97515] = true, -- Have you made contact with Ivus, Archdruid? [Archdruid Renferal (13442) - Alliance] (WoW Forever)
	}
	local knownGoodGossipIDs = {
		-- Open Quest to Smith or Murgot
		[30904] = true, -- Upgrade to seasoned units! [Alliance]
		[97833] = true, -- Upgrade to seasoned units! [Alliance] (WoW Forever)
		[30905] = true, -- Upgrade to veteran units! [Alliance]
		[30906] = true, -- Upgrade to champion units! [Alliance]
		[35736] = true, -- Upgrade to seasoned units! [Horde]
		[35737] = true, -- Upgrade to veteran units! [Horde]
		[35738] = true, -- Upgrade to champion units! [Horde]

		[32605] = true, -- With pleasure. These things stink! [Stormpike Stable Master (13617) - Alliance]
		--[32605] = true, -- With pleasure. These things stink! [Frostwolf Stable Master (13616) - Horde]

		-- Wing Commanders in the towers
		[30406] = true, -- I got your back, Ichman. GO GO GO! [Wing Commander Ichman (13437) - Alliance]
		[97516] = true, -- I got your back, Ichman. GO GO GO! [Wing Commander Ichman (13437) - Alliance] (WoW Forever)
		[30407] = true, -- I got you covered, Vipore. Move out! [Wing Commander Vipore (13439) - Alliance]
		[96694] = true, -- I got you covered, Vipore. Move out! [Wing Commander Vipore (13439) - Alliance] (WoW Forever)
		[30614] = true, -- I got your back, Slidore, but to be honest, you do stink. Take a shower, man. [Wing Commander Slidore (13438) - Alliance]
		[96695] = true, -- I got your back, Slidore, but to be honest, you do stink. Take a shower, man. [Wing Commander Slidore (13438) - Alliance] (WoW Forever)
	}

	local knownBadQuestIDs = {
		[7027] = true, -- Empty Stables [Stormpike Stable Master (13617) - Alliance]
		[7001] = true, -- Empty Stables [Frostwolf Stable Master (13616) - Horde]
	}
	local knownGoodActiveQuestIDs = {
		[5892] = true, -- Irondeep Supplies [Stormpike Quartermaster (12096) - Alliance]
		[6982] = true, -- Coldtooth Supplies [Stormpike Quartermaster (12096) - Alliance]
		[6985] = true, -- Irondeep Supplies [Frostwolf Quartermaster (12097) - Horde]
		[5893] = true, -- Coldtooth Supplies [Frostwolf Quartermaster (12097) - Horde]
	}
	local knownGoodAvailableQuestIDs = { -- [questID] = {itemID, requiredCount}
		-- Armor Scraps (17422)
		[6781] = {17422, 20}, -- More Armor Scraps [Alliance]
		[6741] = {17422, 20}, -- More Booty! [Horde]
		[57318] = {17422, 20}, -- More Booty! [Horde, specific to Korrak's Revenge]
		[57306] = {17422, 20}, -- More Armor Scraps [Alliance, specific to Korrak's Revenge]

		-- Stormpike Soldier's Blood (17306) [Horde, Primalist Thurloga]
		[7385] = {17306, 5}, -- A Gallon of Blood [Horde]
		[6801] = {17306, 1}, -- Lokholar the Ice Lord [Horde]

		-- Storm Crystal (17423) [Alliance, Archdruid Renferal]
		[7386] = {17423, 5}, -- Crystal Cluster [Alliance]
		[6881] = {17423, 1}, -- Ivus the Forest Lord [Alliance]

		-- Frost Wolf Hide (17643) [Alliance, Stormpike Ram Rider Commander]
		[7026] = {17643, 1}, -- Stormpike Ram Rider Commander [Alliance, only in Korrak's Revenge on retail]

		-- Alterac Ram Hide (17642) [Horde, Frostwolf Wolf Rider Commander]
		[7002] = {17642, 1}, -- Ram Hide Harnesses [Horde, Frostwolf Wolf Rider Commander, only in Korrak's Revenge on retail]
	}

	local function ReportUnknown(msg, id, name)
		local faction = UnitFactionGroup("player")
		if UnitIsMercenary("player") then
			if faction == "Horde" then
				faction = "Alliance (Mercenary)"
			elseif faction == "Alliance" then
				faction = "Horde (Mercenary)"
			end
		end
		print("|cFF33FF99Capping|r: ".. msg ..", TELL THE DEVS!", id, name, faction)
		geterrorhandler()("|cFF33FF99Capping|r: ".. msg ..", TELL THE DEVS! ".. tostring(id) ..", ".. tostring(name) ..", ".. tostring(faction))
		BasicMessageDialog.Text:SetText("Capping needs help, see chat for details")
		BasicMessageDialog:Show()
	end

	function mod:GOSSIP_SHOW()
		if not cap.db.profile.autoTurnIn then return end

		local selectedActiveQuestID
		if GetNumGossipActiveQuests() > 0 then
			local tbl = GetGossipActiveQuests()
			for i = 1, #tbl do
				local questTable = tbl[i]
				local questID = questTable.questID
				if knownGoodActiveQuestIDs[questID] then
					if not selectedActiveQuestID and IsQuestComplete(questID) then
						selectedActiveQuestID = questID
					end
				elseif not knownBadQuestIDs[questID] and not knownGoodAvailableQuestIDs[questID] then
					ReportUnknown("NEW ACTIVE QUEST", questID, questTable.title)
				end
			end
		end

		local selectedAvailableQuestID, selectedAvailableQuestCount = nil, 0
		if GetNumGossipAvailableQuests() > 0 then
			local tbl = GetGossipAvailableQuests()
			for i = 1, #tbl do
				local questTable = tbl[i]
				local questID = questTable.questID
				local itemInfo = knownGoodAvailableQuestIDs[questID]
				if itemInfo then
					local requiredCount = itemInfo[2]
					if requiredCount > selectedAvailableQuestCount and GetItemCount(itemInfo[1]) >= requiredCount then
						selectedAvailableQuestID = questID
						selectedAvailableQuestCount = requiredCount
					end
				elseif not knownBadQuestIDs[questID] and not knownGoodActiveQuestIDs[questID] then
					ReportUnknown("NEW AVAILABLE QUEST", questID, questTable.title)
				end
			end
		end

		local selectedGossipID
		local gossipOptions = GetGossipOptions()
		if gossipOptions[1] then
			for i = 1, #gossipOptions do
				local gossipTable = gossipOptions[i]
				local gossipOptionID = gossipTable.gossipOptionID
				if knownGoodGossipIDs[gossipOptionID] then
					if not selectedGossipID then
						selectedGossipID = gossipOptionID
					end
				elseif not knownBadGossipIDs[gossipOptionID] then
					ReportUnknown("NEW GOSSIP ID FOUND", gossipOptionID, gossipTable.name)
				end
			end
		end

		if selectedGossipID then
			self:SelectGossipID(selectedGossipID)
		elseif selectedAvailableQuestID then
			self:SelectGossipAvailableQuestID(selectedAvailableQuestID)
		elseif selectedActiveQuestID then
			self:SelectGossipActiveQuestID(selectedActiveQuestID)
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
--local function allow() hereFromTheStart = false end
local function stop() hereFromTheStart = true stopTimer = nil end
--local GetScoreInfo = C_PvP.GetScoreInfo
local SendAddonMessage = C_ChatInfo.SendAddonMessage
--local function AVSyncRequest()
--	for i = 1, 80 do
--		local scoreTbl = GetScoreInfo(i)
--		if scoreTbl and scoreTbl.damageDone and scoreTbl.damageDone ~= 0 then
--			hereFromTheStart = true
--			hasData = false
--			mod:Timer(0.5, allow)
--			stopTimer = NewTicker(3, stop, 1)
--			SendAddonMessage("Capping", "tr", "INSTANCE_CHAT")
--			return
--		end
--	end
--
--	hereFromTheStart = true
--	hasData = true
--end

do
	local timer = nil
	local function SendAVTimers()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local str = ""
			for bar in next, CappingFrame.bars do
				local poiId = bar:Get("capping:poiid")
				if poiId then
					str = string.format("%s%d-%d~", str, poiId, math.floor(bar:GetRemainingTime()))
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
					if widget and barTime and barTime > 5 and barTime < (isRetail and 245 or 303) then
						inProgressDataTbl[widget] = barTime
					end
				end
			end

			if next(inProgressDataTbl) then
				self:RestoreFlagCaptures(inProgressDataTbl, isRetail and 242 or 300)
			end
		end

		local me = UnitName("player")
		local Ambiguate = Ambiguate
		function mod:CHAT_MSG_ADDON(prefix, msg, channel, sender)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				sender = Ambiguate(sender, "none")
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
	--local RequestBattlefieldScoreData = RequestBattlefieldScoreData
	local poiEnglishNames = {
		-- Alterac Valley (map 30) - Alliance Bunkers
		[1353] = "Dun Baldar North Bunker", -- Alliance conflict
		[1354] = "Dun Baldar North Bunker", -- Horde conflict
		[1356] = "Dun Baldar South Bunker", -- Alliance conflict
		[1357] = "Dun Baldar South Bunker", -- Horde conflict
		[1381] = "Icewing Bunker", -- Alliance conflict
		[1382] = "Icewing Bunker", -- Horde conflict
		[1390] = "Stonehearth Bunker", -- Alliance conflict
		[1391] = "Stonehearth Bunker", -- Horde conflict

		-- Alterac Valley (map 30) - Horde Towers
		[1378] = "Iceblood Tower", -- Horde conflict
		[1379] = "Iceblood Tower", -- Alliance conflict
		[1406] = "Tower Point", -- Horde conflict
		[1407] = "Tower Point", -- Alliance conflict
		[1529] = "West Frostwolf Tower", -- Horde conflict
		[1530] = "West Frostwolf Tower", -- Alliance conflict
		[1363] = "East Frostwolf Tower", -- Alliance conflict
		[1364] = "East Frostwolf Tower", -- Horde conflict

		-- Alterac Valley (map 30) - Graveyards
		[1396] = "Stormpike Aid Station", -- Alliance conflict
		[1397] = "Stormpike Aid Station", -- Horde conflict
		[1399] = "Stormpike Graveyard", -- Alliance conflict
		[1400] = "Stormpike Graveyard", -- Horde conflict
		[1393] = "Stonehearth Graveyard", -- Alliance conflict
		[1394] = "Stonehearth Graveyard", -- Horde conflict
		[1387] = "Snowfall Graveyard", -- Horde conflict
		[1388] = "Snowfall Graveyard", -- Alliance conflict
		[1375] = "Iceblood Graveyard", -- Alliance conflict
		[1376] = "Iceblood Graveyard", -- Horde conflict
		[1369] = "Frostwolf Graveyard", -- Alliance conflict
		[1370] = "Frostwolf Graveyard", -- Horde conflict
		[1372] = "Frostwolf Relief Hut", -- Horde conflict
		[1373] = "Frostwolf Relief Hut", -- Alliance conflict

		-- Korrak's Revenge (map 2197) - Alliance Bunkers
		[6423] = "Dun Baldar North Bunker", -- Alliance conflict
		[6424] = "Dun Baldar North Bunker", -- Horde conflict
		[6426] = "Dun Baldar South Bunker", -- Alliance conflict
		[6427] = "Dun Baldar South Bunker", -- Horde conflict
		[6446] = "Icewing Bunker", -- Alliance conflict
		[6447] = "Icewing Bunker", -- Horde conflict
		[6454] = "Stonehearth Bunker", -- Alliance conflict
		[6455] = "Stonehearth Bunker", -- Horde conflict

		-- Korrak's Revenge (map 2197) - Horde Towers
		[6443] = "Iceblood Tower", -- Horde conflict
		[6444] = "Iceblood Tower", -- Alliance conflict
		[6466] = "Tower Point", -- Horde conflict
		[6467] = "Tower Point", -- Alliance conflict
		[6470] = "West Frostwolf Tower", -- Horde conflict
		[6471] = "West Frostwolf Tower", -- Alliance conflict
		[6431] = "East Frostwolf Tower", -- Alliance conflict
		[6432] = "East Frostwolf Tower", -- Horde conflict

		-- Korrak's Revenge (map 2197) - Graveyards
		[6460] = "Stormpike Aid Station", -- Alliance conflict
		[6461] = "Stormpike Aid Station", -- Horde conflict
		[6463] = "Stormpike Graveyard", -- Alliance conflict
		[6464] = "Stormpike Graveyard", -- Horde conflict
		[6457] = "Stonehearth Graveyard", -- Alliance conflict
		[6458] = "Stonehearth Graveyard", -- Horde conflict
		[6451] = "Snowfall Graveyard", -- Horde conflict
		[6452] = "Snowfall Graveyard", -- Alliance conflict
		[6440] = "Iceblood Graveyard", -- Alliance conflict
		[6441] = "Iceblood Graveyard", -- Horde conflict
		[6434] = "Frostwolf Graveyard", -- Alliance conflict
		[6435] = "Frostwolf Graveyard", -- Horde conflict
		[6437] = "Frostwolf Relief Hut", -- Horde conflict
		[6438] = "Frostwolf Relief Hut", -- Alliance conflict
	}
	function mod:EnterZone(id)
		if id == 2197 then
			self:StartFlagCaptures(241, nil, poiEnglishNames) -- Korrak's Revenge (WoW 15th)
		else
			self:StartFlagCaptures(isRetail and 242 or 300, nil, poiEnglishNames) -- 300 on Forever
		end
		--self:SetupHealthCheck("11946", L.hordeBoss, "Horde Boss", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		--self:SetupHealthCheck("11948", L.allianceBoss, "Alliance Boss", 236444, "colorHorde") -- Interface/Icons/Achievement_Character_Dwarf_Male
		--self:SetupHealthCheck("11947", L.galvangar, "Galvangar", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		--self:SetupHealthCheck("11949", L.balinda, "Balinda", 236447, "colorHorde") -- Interface/Icons/Achievement_Character_Human_Female
		--self:SetupHealthCheck("13419", L.ivus, "Ivus", 874581, "colorAlliance") -- Interface/Icons/inv_pet_ancientprotector_winter
		--self:SetupHealthCheck("13256", L.lokholar, "Lokholar", 1373132, "colorHorde") -- Interface/Icons/Inv_infernalmounice.blp
		--self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("GOSSIP_SHOW")
		self:RegisterEvent("QUEST_PROGRESS")
		self:RegisterEvent("QUEST_COMPLETE")
		--RequestBattlefieldScoreData()
		--self:Timer(1, function() RequestBattlefieldScoreData() end)
		--self:Timer(2, AVSyncRequest)
	end
end

function mod:ExitZone()
	self:UnregisterEvent("GOSSIP_SHOW")
	self:UnregisterEvent("QUEST_PROGRESS")
	self:UnregisterEvent("QUEST_COMPLETE")
	--self:UnregisterEvent("CHAT_MSG_ADDON")
	self:StopFlagCaptures()
	--self:StopHealthCheck()
end

mod:RegisterZone(30)
mod:RegisterZone(2197) -- Korrak's Revenge (WoW 15th)
