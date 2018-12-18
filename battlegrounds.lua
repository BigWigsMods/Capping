
local mod
do
	local _
	_, mod = ...
end
local L = mod.L

local ceil = math.ceil
local strmatch, pairs, format, tonumber = strmatch, pairs, format, tonumber
local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local Timer, SendAddonMessage = C_Timer.After, C_ChatInfo.SendAddonMessage

local SetupAssault, GetIconData, UpdateAssault
do -- POI handling
	-- Easy world map icon checker
	--[[local start = function(self) self:StartMoving() end
	local stop = function(self) self:StopMovingOrSizing() end
	local frames = {}
	do
		local f = CreateFrame("Frame", nil, UIParent)
		f:SetPoint("CENTER")
		f:SetSize(24,24)
		f:EnableMouse(true)
		f:SetMovable(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", start)
		f:SetScript("OnDragStop", stop)
		frames[1] = f
		local tx = f:CreateTexture()
		tx:SetAllPoints(f)
		tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		tx:SetTexCoord(GetPOITextureCoords(1))
		local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		n:SetPoint("BOTTOM", f, "TOP")
		n:SetText(1)
	end
	for i = 2, 205 do
		local f = CreateFrame("Frame", nil, UIParent)
		f:SetPoint("LEFT", frames[i-1], "RIGHT", 10, 0)
		f:SetSize(24,24)
		f:EnableMouse(true)
		f:SetMovable(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", start)
		f:SetScript("OnDragStop", stop)
		frames[i] = f
		local tx = f:CreateTexture()
		tx:SetAllPoints(f)
		tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		tx:SetTexCoord(GetPOITextureCoords(i))
		local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		n:SetPoint("BOTTOM", f, "TOP")
		n:SetText(i)
	end]]

	local iconDataConflict = {
		-- Graveyard
		[4] = "colorAlliance",
		[14] = "colorHorde",
		-- Tower
		[9] = "colorAlliance",
		[12] = "colorHorde",
		-- Mine/Stone
		[17] = "colorAlliance",
		[19] = "colorHorde",
		-- Lumber/Wood
		[22] = "colorAlliance",
		[24] = "colorHorde",
		-- Blacksmith/Anvil
		[27] = "colorAlliance",
		[29] = "colorHorde",
		-- Farm/House
		[32] = "colorAlliance",
		[34] = "colorHorde",
		-- Stables/Horse
		[37] = "colorAlliance",
		[39] = "colorHorde",
		-- Workshop/Tent
		[137] = "colorAlliance",
		[139] = "colorHorde",
		-- Hangar/Mushroom
		[142] = "colorAlliance",
		[144] = "colorHorde",
		-- Docks/Anchor
		[147] = "colorAlliance",
		[149] = "colorHorde",
		-- Oil/Refinery
		[152] = "colorAlliance",
		[154] = "colorHorde",
	}
	local GetPOITextureCoords = GetPOITextureCoords
	local capTime = 0
	local curMapID = 0
	local path = {136441}
	GetIconData = function(icon)
		path[2], path[3], path[4], path[5] = GetPOITextureCoords(icon)
		return path
	end
	local landmarkCache = {}
	SetupAssault = function(bgcaptime, uiMapID)
		capTime = bgcaptime -- cap time
		curMapID = uiMapID -- current map
		landmarkCache = {}
		local pois = GetAreaPOIForMap(uiMapID)
		for i = 1, #pois do
			local tbl = GetAreaPOIInfo(uiMapID, pois[i])
			local icon = tbl.textureIndex
			landmarkCache[tbl.name] = icon
			if icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
				-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
				local _, _, _, id = UnitPosition("player")
				if id == 30 or id == 628 then -- Alterac Valley, IoC
					local bar = mod:StartBar(tbl.name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
					bar:Pause()
					bar:SetTimeVisibility(false)
					bar:Set("capping:customchat", function() end)
				end
			end
		end
		mod:RegisterTempEvent("AREA_POIS_UPDATED")
	end
	-----------------------------------
	function mod:AREA_POIS_UPDATED()
	-----------------------------------
		local pois = GetAreaPOIForMap(curMapID)
		for i = 1, #pois do
			local tbl = GetAreaPOIInfo(curMapID, pois[i])
			local name, icon, areaPoiID = tbl.name, tbl.textureIndex, tbl.areaPoiID
			if landmarkCache[name] ~= icon then
				landmarkCache[name] = icon
				if iconDataConflict[icon] then
					local bar = self:StartBar(name, capTime, GetIconData(icon), iconDataConflict[icon])
					bar:Set("capping:poiid", areaPoiID)
					if icon == 137 or icon == 139 then -- Workshop in IoC
						self:StopBar((GetSpellInfo(56661))) -- Build Siege Engine
					end
				else
					self:StopBar(name)
					if icon == 136 or icon == 138 then -- Workshop in IoC
						self:StartBar(GetSpellInfo(56661), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
					elseif icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
						-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
						local _, _, _, id = UnitPosition("player")
						if id == 30 or id == 628 then -- Alterac Valley, IoC
							local bar = self:StartBar(name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
							bar:Pause()
							bar:SetTimeVisibility(false)
							bar:Set("capping:customchat", function() end)
						end
					end
				end
			end
		end
	end

	UpdateAssault = function(uiMapID, inProgressDataTbl)
		local pois = GetAreaPOIForMap(uiMapID)
		for i = 1, #pois do
			local tbl = GetAreaPOIInfo(uiMapID, pois[i])
			local name, icon, areaPoiID = tbl.name, tbl.textureIndex, tbl.areaPoiID
			local timer = inProgressDataTbl[areaPoiID]
			if timer and iconDataConflict[icon] then
				mod:StartBar(name, timer, GetIconData(icon), iconDataConflict[icon])
			end
		end
	end
end

-- initialize or update a final score estimation bar (AB and EotS uses this)
local NewEstimator
do
	local allianceWidget, hordeWidget, prevTime, updateBases, hordeWinning = 0, 0, 0, false, false
	local update = function() updateBases = true end
	local MaxScore, prevText = 1500, ""
	local ppsTable
	function mod:ScorePredictor()
		local t = GetTime()
		-- Conditions:
		-- 1) Amount of owned bases changed
		-- 2) Two updates happened in a short space of time and we want the data from the 2nd update (latest score info)
		-- This happens when both teams have bases, the first update (alliance) will be incomplete, the second update (horde) will give us a complete outlook of final scores
		if updateBases or (t - prevTime) < 0.8 then
			prevTime = t

			local ascore, abases = 0, 0
			do
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(allianceWidget)
				if not dataTbl then return end
				local base, score = strmatch(dataTbl.text, "^[^%d]+(%d)[^%d]+(%d+)[^%d]+%d+$") -- Bases: %d  Resources: %d/%d
				local ABases, AScore = tonumber(base), tonumber(score)
				if ABases and AScore then
					abases = ABases
					ascore = AScore
				end
			end

			local hscore, hbases = 0, 0
			do
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(hordeWidget)
				if not dataTbl then return end
				local base, score = strmatch(dataTbl.text, "^[^%d]+(%d)[^%d]+(%d+)[^%d]+%d+$") -- Bases: %d  Resources: %d/%d
				local HBases, HScore = tonumber(base), tonumber(score)

				if HBases and HScore then
					hbases = HBases
					hscore = HScore
				end
			end

			local apps, hpps = ppsTable[abases], ppsTable[hbases]
			-- timeTilFinal = ((remainingScore) / scorePerSec) - (timeSinceLastUpdate)
			local ATime = apps and ((MaxScore - ascore) / apps) or 1000000
			local HTime = hpps and ((MaxScore - hscore) / hpps) or 1000000

			if HTime < ATime then -- Horde is winning
				updateBases = false
				local score = apps and (ascore + ceil(apps * HTime)) or ascore
				local txt = format(L.finalScore, score, MaxScore)
				if txt ~= prevText or not hordeWinning then
					hordeWinning = true
					self:StopBar(prevText)
					self:StartBar(txt, HTime, 132485, "colorHorde") -- 132485 = Interface/Icons/INV_BannerPVP_01
					prevText = txt
				end
			elseif ATime < HTime then -- Alliance is winning
				updateBases = false
				local score = hpps and (hscore + ceil(hpps * ATime)) or hscore
				local txt = format(L.finalScore, MaxScore, score)
				if txt ~= prevText or hordeWinning then
					hordeWinning = false
					self:StopBar(prevText)
					self:StartBar(txt, ATime, 132486, "colorAlliance") -- 132486 = Interface/Icons/INV_BannerPVP_02
					prevText = txt
				end
			end
		end
	end
	NewEstimator = function(pointsPerSecond, aW, hW) -- resets estimator and sets new battleground
		allianceWidget, hordeWidget = aW, hW
		ppsTable = pointsPerSecond
		updateBases = false
		prevText = ""
		Timer(2, update) -- Delay the first update so we don't get bad data
		mod:RegisterTempEvent("UPDATE_UI_WIDGET", "ScorePredictor")
	end

	function mod:UpdateBases()
		Timer(1, update) -- Delay the first update so we don't get bad data
	end
end

local SetupHealthCheck
do
	local unitTable1 = {
		"target", "targettarget",
		"mouseover", "mouseovertarget",
		"focus", "focustarget",
		"nameplate1", "nameplate2", "nameplate3", "nameplate4", "nameplate5", "nameplate6", "nameplate7", "nameplate8", "nameplate9", "nameplate10",
		"nameplate11", "nameplate12", "nameplate13", "nameplate14", "nameplate15", "nameplate16", "nameplate17", "nameplate18", "nameplate19", "nameplate20",
		"nameplate21", "nameplate22", "nameplate23", "nameplate24", "nameplate25", "nameplate26", "nameplate27", "nameplate28", "nameplate29", "nameplate30",
		"nameplate31", "nameplate32", "nameplate33", "nameplate34", "nameplate35", "nameplate36", "nameplate37", "nameplate38", "nameplate39", "nameplate40",
	}
	local unitTable2 = {
		"nameplate1target", "nameplate2target", "nameplate3target", "nameplate4target", "nameplate5target",
		"nameplate6target", "nameplate7target", "nameplate8target", "nameplate9target", "nameplate10target",
		"nameplate11target", "nameplate12target", "nameplate13target", "nameplate14target", "nameplate15target",
		"nameplate16target", "nameplate17target", "nameplate18target", "nameplate19target", "nameplate20target",
		"nameplate21target", "nameplate22target", "nameplate23target", "nameplate24target", "nameplate25target",
		"nameplate26target", "nameplate27target", "nameplate28target", "nameplate29target", "nameplate30target",
		"nameplate31target", "nameplate32target", "nameplate33target", "nameplate34target", "nameplate35target",
		"nameplate36target", "nameplate37target", "nameplate38target", "nameplate39target", "nameplate40target",
	}
	local unitTable3 = {
		"raid1target", "raid2target", "raid3target", "raid4target", "raid5target",
		"raid6target", "raid7target", "raid8target", "raid9target", "raid10target",
		"raid11target", "raid12target", "raid13target", "raid14target", "raid15target",
		"raid16target", "raid17target", "raid18target", "raid19target", "raid20target",
		"raid21target", "raid22target", "raid23target", "raid24target", "raid25target",
		"raid26target", "raid27target", "raid28target", "raid29target", "raid30target",
		"raid31target", "raid32target", "raid33target", "raid34target", "raid35target",
		"raid36target", "raid37target", "raid38target", "raid39target", "raid40target"
	}
	local collection, reset, blocked, prev, started = {}, {}, {}, 0, false
	local count1, count2, count3 = #unitTable1, #unitTable2, #unitTable3
	local UnitGUID, strsplit = UnitGUID, strsplit

	local function parse2()
		for i = 1, count2 do
			local unit = unitTable2[i]
			local guid = UnitGUID(unit)
			if guid then
				local _, _, _, _, _, strid = strsplit("-", guid)
				if strid and collection[strid] and not blocked[strid] then
					blocked[strid] = true
					local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
					SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
				end
			end
		end
	end
	local function parse3()
		for i = 1, count3 do
			local unit = unitTable3[i]
			local guid = UnitGUID(unit)
			if guid then
				local _, _, _, _, _, strid = strsplit("-", guid)
				if strid and collection[strid] and not blocked[strid] then
					blocked[strid] = true
					local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
					SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
				end
			end
		end
	end
	local function HealthScan()
		local _, _, _, id = UnitPosition("player")
		if id == 30 or id == 628 then -- Alterac Valley, IoC
			Timer(1, HealthScan)
			Timer(0.1, parse2) -- Break up parsing
			Timer(0.2, parse3)
		else
			started = false
			collection, reset = {}, {}
			return
		end

		for id, counter in next, reset do
			reset[id] = counter + 1
			if counter > 20 then
				local tbl = collection[id]:Get("capping:hpdata")
				collection[id]:Stop()
				reset[id] = nil
				collection[id] = tbl
			end
		end

		blocked = {}
		for i = 1, count1 do
			local unit = unitTable1[i]
			local guid = UnitGUID(unit)
			if guid then
				local _, _, _, _, _, strid = strsplit("-", guid)
				if strid and collection[strid] and not blocked[strid] then
					blocked[strid] = true
					local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
					SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
				end
			end
		end
	end

	SetupHealthCheck = function(npcId, npcName, englishName, icon, color)
		collection[npcId] = {npcName, englishName, icon, color}
		if not started then
			started = true
			C_ChatInfo.RegisterAddonMessagePrefix("Capping")
			mod:RegisterTempEvent("CHAT_MSG_ADDON", "HealthUpdate")
			Timer(1, HealthScan)
		end
	end

	function mod:HealthUpdate(prefix, msg, channel, sender)
		if prefix == "Capping" and channel == "INSTANCE_CHAT" then
			local strid, strhp = strsplit(":", msg)
			local hp = tonumber(strhp)
			if strid and hp and collection[strid] and hp < 100.1 and hp > 0 then
				if collection[strid].candyBarBar then
					if hp < 100 then
						reset[strid] = 0
					end
					collection[strid].candyBarBar:SetValue(hp)
					collection[strid].candyBarDuration:SetFormattedText("%.1f%%", hp)
				elseif hp < 100 then
					local tbl = collection[strid]
					local bar = mod:StartBar(tbl[1], 100, tbl[3], tbl[4], true)
					bar:Pause()
					bar.candyBarBar:SetValue(hp)
					bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
					bar:Set("capping:customchat", function()
						if tbl[1] ~= tbl[2] then
							return tbl[2] .."/".. tbl[1] .." - ".. bar.candyBarDuration:GetText()
						else
							return tbl[1] .." - ".. bar.candyBarDuration:GetText()
						end
					end)
					bar:Set("capping:hpdata", tbl)
					reset[strid] = 0
					collection[strid] = bar
				end
			end
		end
	end
end

do
	------------------------------------------------ Arathi Basin -----------------------------------------------------
	local pointsPerSecond = {1, 1.5, 2, 3.5, 30} -- Updates every 2 seconds

	local function ArathiBasin(self)
		SetupAssault(60, 93)
		NewEstimator(pointsPerSecond, 495, 496) -- BG table, alliance score widget, horde score widget
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "UpdateBases")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "UpdateBases")
	end
	mod:AddBG(529, ArathiBasin)

	local function ArathiBasinSnowyPvPBrawl(self)
		SetupAssault(60, 837)
		NewEstimator(pointsPerSecond, 914, 915) -- BG table, alliance score widget, horde score widget
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "UpdateBases")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "UpdateBases")
	end
	mod:AddBG(1681, ArathiBasinSnowyPvPBrawl)
end

do
	------------------------------------------------ Deepwind Gorge -----------------------------------------------------
	local pointsPerSecond = {1.6, 3.2, 6.4} -- Updates every 5 seconds

	local function DeepwindGorge(self)
		SetupAssault(61, 519)
		NewEstimator(pointsPerSecond, 734, 735) -- BG table, alliance score widget, horde score widget
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "UpdateBases")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "UpdateBases")
	end
	mod:AddBG(1105, DeepwindGorge)
end

do
	------------------------------------------------ Gilneas -----------------------------------------------------
	local pointsPerSecond = {1, 3, 30} -- Updates every 1 second

	local function TheBattleForGilneas(self)
		SetupAssault(60, 275) -- Base cap time, uiMapID
		NewEstimator(pointsPerSecond, 699, 700) -- BG table, alliance score widget, horde score widget
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "UpdateBases")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "UpdateBases")
	end
	mod:AddBG(761, TheBattleForGilneas) -- Instance ID
end

do
	------------------------------------------------ Alterac Valley ---------------------------------------------------
	local hereFromTheStart, hasData = true, true
	local stopTimer = nil
	local function allow() hereFromTheStart = false end
	local function stop() hereFromTheStart = true hasData = true stopTimer = nil end
	local function AVSyncRequest()
		local t = GetTime()
		if mod.prevTimer and t - mod.prevTimer < 2 then -- mod.prevTimer set when START_TIMER fires (Capping.lua)
			hereFromTheStart = true
			hasData = true
		else
			hereFromTheStart = true
			hasData = false
			Timer(0.5, allow)
			stopTimer = C_Timer.NewTicker(3, stop, 1)
			C_ChatInfo.SendAddonMessage("Capping", "tr", "INSTANCE_CHAT")
		end
	end

	local timer = nil
	local function SendAVTimers()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local str = ""
			for bar in next, CappingFrame.bars do
				local poiId = bar:Get("capping:poiid")
				if poiId then
					str = format("%s%d-%d~", str, poiId, math.floor(bar.remaining))
				end
			end

			if str ~= "" and string.len(str) < 250 then
				SendAddonMessage("Capping", str, "INSTANCE_CHAT")
			end
		end
	end

	do
		local function Unwrap(...)
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
				UpdateAssault(91, inProgressDataTbl)
			end
		end

		local me = UnitName("player").. "-" ..GetRealmName()
		function mod:AVSync(prefix, msg, channel, sender)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				self:HealthUpdate(prefix, msg, channel, sender)
				if msg == "tr" and sender ~= me then -- timer request
					if hasData then -- Joined a late game, don't send data
						if timer then timer:Cancel() end
						timer = C_Timer.NewTicker(1, SendAVTimers, 1)
					elseif stopTimer then
						stopTimer:Cancel()
						stopTimer = C_Timer.NewTicker(3, stop, 1)
					end
				elseif not hereFromTheStart and sender ~= me and msg:find("~", nil, true) then
					hereFromTheStart = true
					hasData = true
					Unwrap(strsplit("~", msg))
				end
			end
		end
	end

	local function AlteracValley(self)
		function mod:AVTurnIn()
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
				elseif mobId == 13617 or mobId == 13616 then -- Stormpike Stable Master, Frostwolf Stable Master
					if GetGossipOptions() then
						SelectGossipOption(1)
					end
				elseif mobId == 13236 then -- Primalist Thurloga
					local num = GetItemCount(17306) -- Stormpike Soldier's Blood 17306
					if num >= 5 then
						SelectGossipAvailableQuest(2)
					elseif num > 0 then
						SelectGossipAvailableQuest(1)
					end
				elseif mobId == 13442 then -- Arch Druid Renferal
					local num = GetItemCount(17423) -- Storm Crystal 17423
					if num >= 5 then
						SelectGossipAvailableQuest(2)
					elseif num > 0 then
						SelectGossipAvailableQuest(1)
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
		function mod:AVTurnInProgress()
			self:AVTurnIn()
			if IsQuestCompletable() then
				CompleteQuest()
			end
		end
		function mod:AVTurnInComplete()
			GetQuestReward(0)
		end

		SetupAssault(242, 91)
		SetupHealthCheck("11946", L.hordeBoss, "Horde Boss", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		SetupHealthCheck("11948", L.allianceBoss, "Alliance Boss", 236444, "colorHorde") -- Interface/Icons/Achievement_Character_Dwarf_Male
		SetupHealthCheck("11947", L.galvangar, "Galvangar", 236452, "colorAlliance") -- Interface/Icons/Achievement_Character_Orc_Male
		SetupHealthCheck("11949", L.balinda, "Balinda Stonehearth", 236447, "colorHorde") -- Interface/Icons/Achievement_Character_Human_Female
		self:RegisterTempEvent("CHAT_MSG_ADDON", "AVSync")
		self:RegisterTempEvent("GOSSIP_SHOW", "AVTurnIn")
		self:RegisterTempEvent("QUEST_PROGRESS", "AVTurnInProgress")
		self:RegisterTempEvent("QUEST_COMPLETE", "AVTurnInComplete")
		Timer(2, AVSyncRequest)
	end
	mod:AddBG(30, AlteracValley)
end

do
	------------------------------------------------ Eye of the Storm -------------------------------------------------
	local pointsPerSecond = {1, 1.5, 2, 6} -- Updates every 2 seconds

	local function EyeOfTheStorm(self)
		if not mod.FlagUpdate then
			function mod:FlagUpdate(msg)
				local found = strmatch(msg, L.takenTheFlagTrigger)
				if (found and found == "L'Alliance") or strmatch(msg, L.capturedTheTrigger) then -- frFR
					self:StartBar(L.flagRespawns, 21, GetIconData(45), "colorOther") -- 45 = White flag
				end
				self:UpdateBases()
			end
			-- EotS PvP Brawl: Gravity Lapse
			local ticker1, ticker2 = nil, nil
			local extraMsg = nil
			local color = {r=0,g=1,b=0}
			local function PrintExtraMessage()
				local _, _, _, _, _, _, _, id = GetInstanceInfo()
				if extraMsg and id == 566 then -- Check the game isn't over
					RaidNotice_AddMessage(RaidBossEmoteFrame, extraMsg, color, 3)
				end
			end
			local function StartNextGravTimer()
				local _, _, _, _, _, _, _, id = GetInstanceInfo()
				if id == 566 then -- Check the game isn't over
					local name = GetSpellInfo(44224) -- Gravity Lapse
					local icon = GetSpellTexture(44224)
					self:StartBar(name, 55, icon, "colorOther")
					ticker1 = C_Timer.NewTicker(55, StartNextGravTimer, 1) -- Compensate for being dead (you don't get the message)
					ticker2 = C_Timer.NewTicker(50, PrintExtraMessage, 1)
				end
			end
			function mod:CheckForGravity(msg)
				if msg:find("15", nil, true) then
					if not extraMsg then
						extraMsg = msg:gsub("1", "")
					end
					local name = GetSpellInfo(44224) -- Gravity Lapse
					local icon = GetSpellTexture(44224)
					self:StartBar(name, 15, icon, "colorOther")
					Timer(15, StartNextGravTimer)
					Timer(10, PrintExtraMessage)
					if ticker1 then
						ticker1:Cancel()
						ticker2:Cancel()
						ticker1, ticker2 = nil, nil
					end
				end
			end
		end

		-- setup for final score estimation (2 for EotS)
		NewEstimator(pointsPerSecond, 523, 524) -- BG table, alliance score widget, horde score widget
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "FlagUpdate")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "FlagUpdate")
		self:RegisterTempEvent("RAID_BOSS_WHISPER", "CheckForGravity")
	end
	mod:AddBG(566, EyeOfTheStorm)

	local function EyeOfTheStormRated(self)
		if not mod.FlagUpdateRated then
			function mod:FlagUpdateRated(msg)
				local found = strmatch(msg, L.takenTheFlagTrigger)
				if (found and found == "L'Alliance") or strmatch(msg, L.capturedTheTrigger) then -- frFR
					self:StartBar(L.flagRespawns, 21, GetIconData(45), "colorOther") -- 45 = White flag
				end
				self:UpdateBases()
			end
		end

		-- setup for final score estimation (2 for EotS)
		NewEstimator(pointsPerSecond, 704, 705) -- BG table, alliance score widget, horde score widget
		SetupAssault(60, 397) -- In RBG the four points have flags that need to be assaulted, like AB
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "FlagUpdateRated")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "FlagUpdateRated")
	end
	mod:AddBG(968, EyeOfTheStormRated) -- EotS rated version
end

do
	------------------------------------------------ Isle of Conquest --------------------------------------
	local baseGateHealth = 1497600
	local lowestAllianceHp, lowestHordeHp = baseGateHealth, baseGateHealth
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	local hordeGates, allianceGates = {}, {}

	function mod:CheckGateHealth()
		local _, event, _, _, _, _, _, destGUID, _, _, _, _, _, _, amount = CombatLogGetCurrentEventInfo()
		if event == "SPELL_BUILDING_DAMAGE" then
			local _, _, _, _, _, strid = strsplit("-", destGUID)
			if hordeGates[strid] then
				local newHp = hordeGates[strid] - amount
				hordeGates[strid] = newHp
				if newHp < lowestHordeHp then
					lowestHordeHp = newHp
					local bar = mod:GetBar(L.hordeGate)
					if bar then
						local hp = newHp / baseGateHealth * 100
						if hp < 1 then
							bar:Stop()
						else
							bar.candyBarBar:SetValue(hp)
							bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
						end
					end
				end
			elseif allianceGates[strid] then
				local newHp = allianceGates[strid] - amount
				allianceGates[strid] = newHp
				if newHp < lowestAllianceHp then
					lowestAllianceHp = newHp
					local bar = mod:GetBar(L.allianceGate)
					if bar then
						local hp = newHp / baseGateHealth * 100
						if hp < 1 then
							bar:Stop()
						else
							bar.candyBarBar:SetValue(hp)
							bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
						end
					end
				end
			end
		elseif event == "UNIT_DIED" then
			local _, _, _, _, _, strid = strsplit("-", destGUID)
			if strid == "34776" or strid == "35069" then -- Alliance Siege, Horde Siege
				SendAddonMessage("Capping", "rb", "INSTANCE_CHAT")
			end
		end
	end

	local function initGateBars()
		mod:RegisterTempEvent("COMBAT_LOG_EVENT_UNFILTERED", "CheckGateHealth")
		local aBar = mod:StartBar(L.allianceGate, 100, 2054277, "colorHorde", true) -- Interface/Icons/spell_tailor_defenceup01
		aBar:Pause()
		aBar.candyBarBar:SetValue(100)
		aBar.candyBarDuration:SetText("100%")
		aBar:Set("capping:customchat", function()
			if L.allianceGate ~= "Alliance Gate" then
				return "Alliance Gate/".. L.allianceGate .." - ".. aBar.candyBarDuration:GetText()
			else
				return L.allianceGate .." - ".. aBar.candyBarDuration:GetText()
			end
		end)
		local hBar = mod:StartBar(L.hordeGate, 100, 2054277, "colorAlliance", true) -- Interface/Icons/spell_tailor_defenceup01
		hBar:Pause()
		hBar.candyBarBar:SetValue(100)
		hBar.candyBarDuration:SetText("100%")
		hBar:Set("capping:customchat", function()
			if L.hordeGate ~= "Horde Gate" then
				return "Horde Gate/".. L.hordeGate .." - ".. hBar.candyBarDuration:GetText()
			else
				return L.hordeGate .." - ".. hBar.candyBarDuration:GetText()
			end
		end)
	end

	local hereFromTheStart, hasData = true, true
	local stopTimer = nil
	local function allow() hereFromTheStart = false end
	local function stop() hereFromTheStart = true stopTimer = nil end
	local function IoCSyncRequest()
		local t = GetTime()
		if mod.prevTimer and t - mod.prevTimer < 2 then -- mod.prevTimer set when START_TIMER fires (Capping.lua)
			hereFromTheStart = true
			hasData = true
			initGateBars()
		else
			hereFromTheStart = true
			hasData = false
			Timer(0.5, allow)
			stopTimer = C_Timer.NewTicker(3, stop, 1)
			SendAddonMessage("Capping", "gr", "INSTANCE_CHAT")
		end
	end

	local timer = nil
	local function SendIoCGates()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local msg = format(
				"195494:%d:195495:%d:195496:%d:195698:%d:195699:%d:195700:%d",
				hordeGates["195494"], hordeGates["195495"], hordeGates["195496"],
				allianceGates["195698"], allianceGates["195699"], allianceGates["195700"]
			)
			SendAddonMessage("Capping", msg, "INSTANCE_CHAT")
		end
	end

	do
		local me = UnitName("player").. "-" ..GetRealmName()
		function mod:IoCSync(prefix, msg, channel, sender)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				self:HealthUpdate(prefix, msg, channel, sender)
				if msg == "gr" and sender ~= me then -- gate request
					if hasData then -- Joined a late game, don't send data
						if timer then timer:Cancel() end
						timer = C_Timer.NewTicker(1, SendIoCGates, 1)
					elseif stopTimer then
						stopTimer:Cancel()
						stopTimer = C_Timer.NewTicker(3, stop, 1)
					end
				elseif msg == "rb" or msg == "rbh" then -- Re-Build / Re-Build Halfway
					local pois = GetAreaPOIForMap(169)
					for i = 1, #pois do
						local tbl = GetAreaPOIInfo(169, pois[i])
						local icon = tbl.textureIndex
						if icon == 136 or icon == 138 then -- Workshop in IoC
							local text = GetSpellInfo(56661) -- Build Siege Engine
							local bar = self:GetBar(text)
							if not bar then
								self:StartBar(text, msg == "rb" and 181 or 90.5, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- 252187 = ability_vehicle_siegeengineram
							end
						end
					end
				elseif not hereFromTheStart and sender ~= me then
					local h1, h1hp, h2, h2hp, h3, h3hp, a1, a1hp, a2, a2hp, a3, a3hp = strsplit(":", msg)
					local hGate1, hGate2, hGate3, aGate1, aGate2, aGate3 = tonumber(h1hp), tonumber(h2hp), tonumber(h3hp), tonumber(a1hp), tonumber(a2hp), tonumber(a3hp)
					if hGate1 and hGate2 and hGate3 and aGate1 and aGate2 and aGate3 and -- Safety dance
					h1 == "195494" and h2 == "195495" and h3 == "195496" and a1 =="195698" and a2 == "195699" and a3 == "195700" then
						hereFromTheStart = true
						hasData = true
						initGateBars()
						lowestHordeHp = math.min(hGate1, hGate2, hGate3)
						lowestAllianceHp = math.min(aGate1, aGate2, aGate3)
						hordeGates["195494"] = hGate1
						hordeGates["195495"] = hGate2
						hordeGates["195496"] = hGate3
						allianceGates["195698"] = aGate1
						allianceGates["195699"] = aGate2
						allianceGates["195700"] = aGate3

						local bar = mod:GetBar(L.hordeGate)
						if bar then
							local hp = lowestHordeHp / baseGateHealth * 100
							if hp < 1 then
								bar:Stop()
							else
								bar.candyBarBar:SetValue(hp)
								bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							end
						end
						local bar = mod:GetBar(L.allianceGate)
						if bar then
							local hp = lowestAllianceHp / baseGateHealth * 100
							if hp < 1 then
								bar:Stop()
							else
								bar.candyBarBar:SetValue(hp)
								bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							end
						end
					end
				end
			end
		end
	end

	function mod:RestartSiegeBar(msg)
		if msg:find(L.broken, nil, true) then
			SendAddonMessage("Capping", "rb", "INSTANCE_CHAT")
		elseif msg:find(L.halfway, nil, true) then
			SendAddonMessage("Capping", "rbh", "INSTANCE_CHAT")
		end
	end

	local function IsleOfConquest()
		lowestAllianceHp, lowestHordeHp = baseGateHealth, baseGateHealth
		hordeGates = {
			["195494"] = baseGateHealth,
			["195495"] = baseGateHealth,
			["195496"] = baseGateHealth,
		}
		allianceGates = {
			["195698"] = baseGateHealth,
			["195699"] = baseGateHealth,
			["195700"] = baseGateHealth,
		}
		SetupAssault(61, 169)
		SetupHealthCheck("34922", L.hordeBoss, "Horde Boss", 236452, "colorAlliance") -- Overlord Agmar -- Interface/Icons/Achievement_Character_Orc_Male
		SetupHealthCheck("34924", L.allianceBoss, "Alliance Boss", 236448, "colorHorde") -- Halford Wyrmbane -- Interface/Icons/Achievement_Character_Human_Male
		mod:RegisterTempEvent("CHAT_MSG_ADDON", "IoCSync")
		mod:RegisterTempEvent("CHAT_MSG_MONSTER_YELL", "RestartSiegeBar")
		Timer(2, IoCSyncRequest)
	end
	mod:AddBG(628, IsleOfConquest)
end

do
	------------------------------------------------ Warsong Gulch ----------------------------------------------------
	local function WarsongGulch(self)
		if not self.WSGFlagCarrier then -- init some data and create carrier frames
			--------------------------------------------
			function mod:WSGFlagCarrier(a1) -- carrier detection and setup
			--------------------------------------------
				if strmatch(a1, L.capturedTheTrigger) then -- flag was captured
					self:StartBar(L.flagRespawns, 12, GetIconData(45), "colorOther") -- White flag
				end
			end
			-------------------------
			function mod:WSGGetTimeRemaining()
			-------------------------
				local tbl = GetIconAndTextWidgetVisualizationInfo(6) or GetIconAndTextWidgetVisualizationInfo(630) -- WSG or Twin Peaks
				if tbl and tbl.state == 1 then
					local minutes, seconds = strmatch(tbl.text, "(%d+):(%d+)")
					minutes = tonumber(minutes)
					seconds = tonumber(seconds)
					if minutes and seconds then
						local remaining = seconds + (minutes*60) + 1
						local text = gsub(TIME_REMAINING, ":", "")
						local bar = self:GetBar(text)
						if remaining > 3 and (not bar or bar.remaining > remaining+5 or bar.remaining < remaining-5) then -- Don't restart bars for subtle changes +/- 5s
							self:StartBar(text, remaining, 134420, "colorOther") -- Interface/Icons/INV_Misc_Rune_07
						end
					end
				end
			end
		end

		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "WSGFlagCarrier")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "WSGFlagCarrier")

		local func = function() self:WSGGetTimeRemaining() end
		Timer(5, func)
		Timer(30, func)
		Timer(60, func)
		Timer(130, func)
		Timer(240, func)
	end
	mod:AddBG(489, WarsongGulch)
	mod:AddBG(726, WarsongGulch) -- Twin Peaks
end

do
	------------------------------------------------ Wintergrasp ------------------------------------------
	local wallid, walls = nil, nil
	local function Wintergrasp(self)
		if not self.WinterAssault then
			wallid = { -- wall section locations
				[2222] = "NW ", [2223] = "NW ", [2224] = "NW ", [2225] = "NW ",
				[2226] = "SW ", [2227] = "SW ", [2228] = "S ",
				[2230] = "S ", [2231] = "SE ", [2232] = "SE ",
				[2233] = "NE ", [2234] = "NE ", [2235] = "NE ", [2236] = "NE ",
				[2237] = "Inner W ", [2238] = "Inner W ", [2239] = "Inner W ",
				[2240] = "Inner S ", [2241] = "Inner S ", [2242] = "Inner S ",
				[2243] = "Inner E ", [2244] = "Inner E ", [2245] = "Inner E ",
				[2229] = "", [2246] = "", -- front gate and fortress door
			}

			-- POI icon texture id
			local intact = { [77] = true, [80] = true, [86] = true, [89] = true, [95] = true, [98] = true, }
			local damaged, destroyed, all = { }, { }, { }
			for k in pairs(intact) do
				damaged[k + 1] = true
				destroyed[k + 2] = true
				all[k], all[k + 1], all[k + 2] = true, true, true
			end
			function mod:WinterAssault() -- scans POI landmarks for changes in wall textures
				local pois = GetAreaPOIForMap(123) -- Wintergrasp
				for i = 1, #pois do
					local POI = pois[i]
					local tbl = GetAreaPOIInfo(123, POI)
					local ti = walls[POI]
					local textureIndex = tbl.textureIndex
					if tbl and ((ti and ti ~= textureIndex) or (not ti and wallid[POI])) then
						if intact[ti] and damaged[textureIndex] then -- intact before, damaged now
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[POI], tbl.name, ACTION_ENVIRONMENTAL_DAMAGE))
						elseif damaged[ti] and destroyed[textureIndex] then -- damaged before, destroyed now
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[POI], tbl.name, ACTION_UNIT_DESTROYED))
						end
						walls[POI] = all[textureIndex] and textureIndex or ti
					end
				end
			end
		end
		walls = { }
		local pois = GetAreaPOIForMap(123) -- Wintergrasp
		for i = 1, #pois do
			local POI = pois[i]
			local tbl = GetAreaPOIInfo(123, POI)
			if wallid[POI] and tbl.textureIndex then
				walls[POI] = tbl.textureIndex
			end
		end
		self:RegisterTempEvent("AREA_POIS_UPDATED", "WinterAssault")
	end
	mod:AddBG(-123, Wintergrasp) -- map id
end

--do
--	------------------------------------------------ Ashran ------------------------------------------
--	local function Ashran(self)
--		if not self.AshranControl then
--			function mod:AshranControl(msg)
--				--print(msg, ...)
--				--Ashran Herald yells: The Horde controls the Market Graveyard for 15 minutes!
--				local faction, point, timeString = strmatch(msg, "The (.+) controls the (.+) for (%d+) minutes!")
--				local timeLeft = tonumber(timeString)
--				if faction and point and timeLeft then
--					self:StartBar(point, timeLeft*60, GetIconData(faction == "Horde" and 14 or 4), faction == "Horde" and "colorHorde" or "colorAlliance")
--				end
--			end
--		end
--		if not self.AshranEvents then
--			function mod:AshranEvents(msg)
--				local idString = strmatch(msg, "spell:(%d+)")
--				local id = tonumber(idString)
--				--print(msg:gsub("|", "||"), ...)
--				if id and id ~= 168506 then -- 168506 = Ancient Artifact
--					local name, _, icon = GetSpellInfo(id)
--					self:StartBar(name, 180, icon, "colorOther")
--				end
--			end
--		end
--		if not self.AshranTimeLeft then
--			function mod:AshranTimeLeft()
--				local _, _, _, timeString = GetWorldStateUIInfo(12)
--				if timeString then
--					local minutes, seconds = strmatch(timeString, "(%d+):(%d+)")
--					minutes = tonumber(minutes)
--					seconds = tonumber(seconds)
--					if minutes and seconds then
--						local remaining = seconds + (minutes*60) + 1
--						if remaining > 4 then
--							local text = NEXT_BATTLE_LABEL
--							local bar = self:GetBar(text)
--							if not bar or remaining > bar.remaining+5 or remaining < bar.remaining-5 then -- Don't restart bars for subtle changes +/- 5s
--								self:StartBar(text, remaining, 1031537, "colorOther") -- Interface/Icons/Achievement_Zone_Ashran
--							end
--						end
--					end
--				end
--			end
--		end
--		self:RegisterTempEvent("CHAT_MSG_MONSTER_YELL", "AshranControl")
--		self:RegisterTempEvent("CHAT_MSG_MONSTER_EMOTE", "AshranEvents")
--		self:RegisterTempEvent("WORLD_STATE_UI_TIMER_UPDATE", "AshranTimeLeft")
--	end
--	mod:AddBG(X, Ashran) -- map id
--end

do
	------------------------------------------------ Arena ------------------------------------------
	local function Arena(self)
		-- What we CAN'T use for Shadow Sight timer
		-- COMBAT_LOG_EVENT_UNFILTERED for Arena Preparation removal event, it randomly removes and reapplies itself during the warmup
		-- UPDATE_WORLD_STATES will sometimes fire during the warmup, so we can't assume the first time it fires is the doors opening
		-- UNIT_SPELLCAST_SUCCEEDED arena1-5 events, probably won't work if the entire enemy team is stealth
		-- What we CAN use for Shadow Sight timer
		-- CHAT_MSG_BG_SYSTEM_NEUTRAL#The Arena battle has begun! - Requires localization
		-- WORLD_STATE_UI_TIMER_UPDATE The first event fired with a valid remaining time (the current chosen method)
		if not self.ArenaTimers then
			function mod:ArenaTimers(tbl)
				if tbl.widgetSetID == 1 and tbl.widgetType == 0 then
					local id = tbl.widgetID
					local dataTbl = GetIconAndTextWidgetVisualizationInfo(id)
					if dataTbl and dataTbl.text and dataTbl.state == 1 then
						local minutes, seconds = dataTbl.text:match("(%d+):(%d+)")
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
		self:RegisterTempEvent("UPDATE_UI_WIDGET", "ArenaTimers")
	end
	mod:AddBG(572, Arena) -- Ruins of Lordaeron
	mod:AddBG(617, Arena) -- Dalaran Sewers
	mod:AddBG(980, Arena) -- Tol'Viron Arena
	mod:AddBG(1134, Arena) -- The Tiger's Peak
	mod:AddBG(1504, Arena) -- Black Rook Hold Arena
	mod:AddBG(1505, Arena) -- Nagrand Arena
	mod:AddBG(1552, Arena) -- Ashamane's Fall
	mod:AddBG(1672, Arena) -- Blade's Edge Arena
	mod:AddBG(1825, Arena) -- Hook Point
	mod:AddBG(1911, Arena) -- Mugambala
end

