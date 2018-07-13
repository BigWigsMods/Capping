
local addonName, mod = ...

local L = mod.L
local _G = getfenv(0)

local floor = math.floor
local strmatch, strlower, pairs, format, tonumber = strmatch, strlower, pairs, format, tonumber
local UnitIsEnemy, UnitName, GetTime = UnitIsEnemy, UnitName, GetTime
local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager and C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo -- XXX 8.0
local assaulted, claimed, defended, taken = L["has assaulted"], L["claims the"], L["has defended the"], L["has taken the"]
local GetNumGroupMembers = GetNumGroupMembers

local GetBattlefieldScore, GetNumBattlefieldScores = GetBattlefieldScore, GetNumBattlefieldScores
local function GetClassByName(name, faction) -- retrieves a player's class by name
	for i = 1, GetNumBattlefieldScores(), 1 do
		local iname, _, _, _, _, ifaction, _, _, iclass = GetBattlefieldScore(i)
		if ifaction == faction and gsub(iname or "blah", "-(.+)", "") == name then
			return iclass
		end
	end
end

local classcolor = { }
for class, color in pairs(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS) do
	classcolor[class] = format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end
if CUSTOM_CLASS_COLORS then
	CUSTOM_CLASS_COLORS:RegisterCallback(function()
		for class, color in pairs(CUSTOM_CLASS_COLORS) do
			classcolor[class] = format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
		end
	end)
end

local SetupAssault, GetIconData
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
	local GetAreaPOIForMap = C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap -- XXX 8.0
	local GetAreaPOIInfo = C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIInfo -- XXX 8.0
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
		if GetMapLandmarkInfo then -- XXX 8.0
			for i = 1, GetNumMapLandmarks() do
				local _, name, _, icon = GetMapLandmarkInfo(i)
				landmarkCache[name] = icon
			end
			mod:RegisterTempEvent("WORLD_MAP_UPDATE")
		else
			local pois = GetAreaPOIForMap(uiMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(uiMapID, pois[i])
				landmarkCache[tbl.name] = tbl.textureIndex
			end
			mod:RegisterTempEvent("AREA_POIS_UPDATED")
		end
	end
	-----------------------------------
	function mod:WORLD_MAP_UPDATE() -- XXX 8.0 remove me
	-----------------------------------
		for i = 1, GetNumMapLandmarks() do
			local _, name, _, icon = GetMapLandmarkInfo(i)
			if landmarkCache[name] ~= icon then
				landmarkCache[name] = icon
				if iconDataConflict[icon] then
					self:StartBar(name, capTime, GetIconData(icon), iconDataConflict[icon])
					if icon == 137 or icon == 139 then -- Workshop in IoC
						self:StopBar((GetSpellInfo(56661))) -- Build Siege Engine
					end
				else
					self:StopBar(name)
					if icon == 136 or icon == 138 then -- Workshop in IoC
						self:StartBar((GetSpellInfo(56661)), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
					elseif icon == 2 or icon == 3 then
						local _, _, _, id = UnitPosition("player")
						if id == 30 then -- Alterac Valley
							local bar = self:StartBar(name, 3600, GetIconData(icon), icon == 3 and "colorAlliance" or "colorHorde") -- Paused bar for mine status
							bar:Pause()
							bar:SetTimeVisibility(false)
						end
					end
				end
			end
		end
	end
	-----------------------------------
	function mod:AREA_POIS_UPDATED()
	-----------------------------------
		local pois = GetAreaPOIForMap(curMapID)
		for i = 1, #pois do
			local tbl = GetAreaPOIInfo(curMapID, pois[i])
			local name, icon = tbl.name, tbl.textureIndex
			if landmarkCache[name] ~= icon then
				landmarkCache[name] = icon
				if iconDataConflict[icon] then
					self:StartBar(name, capTime, GetIconData(icon), iconDataConflict[icon])
					if icon == 137 or icon == 139 then -- Workshop in IoC
						self:StopBar((GetSpellInfo(56661))) -- Build Siege Engine
					end
				else
					self:StopBar(name)
					if icon == 136 or icon == 138 then -- Workshop in IoC
						self:StartBar((GetSpellInfo(56661)), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
					elseif icon == 2 or icon == 3 then
						local _, _, _, id = UnitPosition("player")
						if id == 30 then -- Alterac Valley
							local bar = self:StartBar(name, 3600, GetIconData(icon), icon == 3 and "colorAlliance" or "colorHorde") -- Paused bar for mine status
							bar:Pause()
							bar:SetTimeVisibility(false)
						end
					end
				end
			end
		end
	end
end

-----------------------------------------------------------
function mod:CreateCarrierButton(name, postclick) -- create common secure button
-----------------------------------------------------------
	--self.CarrierOnEnter = self.CarrierOnEnter or function(this)
	--	if not this.car then return end
	--	local c = self.db.colors[strlower(this.faction)] or self.db.colors.info1
	--	this:SetBackdropColor(c.r, c.g, c.b, 0.4)
	--end
	--self.CarrierOnLeave = self.CarrierOnLeave or function(this)
	--	this:SetBackdropColor(0, 0, 0, 0)
	--end
	--local b = CreateFrame("Button", name, UIParent, "SecureUnitButtonTemplate")
	--b:SetWidth(200)
	--b:SetHeight(20)
	--b:RegisterForClicks("AnyUp")
	--b:SetBackdrop(self.backdrop)
	--b:SetBackdropColor(0, 0, 0, 0)
	--b:SetScript("PostClick", postclick)
	--b:SetScript("OnEnter", self.CarrierOnEnter)
	--b:SetScript("OnLeave", self.CarrierOnLeave)
	--return b
end

-- initialize or update a final score estimation bar (AB and EotS uses this)
local NewEstimator
do
	local ascore, atime, abases, hscore, htime, hbases, currentbg, prevText, prevTime
	local allianceWidget, hordeWidget = 0, 0
	local ppsTable
	NewEstimator = function(bg, aW, hW, pointsPerSecond) -- resets estimator and sets new battleground
		allianceWidget, hordeWidget = aW, hW
		ppsTable = pointsPerSecond
		if GetWorldStateUIInfo then -- XXX 8.0
			if not mod.UPDATE_WORLD_STATES then
				local f2 = L["Final: %d - %d"]
				local lookup = {
					[1] = { [0] = 0, [1] = 1, [2] = 1.5, [3] = 2, [4] = 3.5, [5] = 30, }, -- ab
					[2] = { [0] = 0, [1] = 0.5, [2] = 1, [3] = 2.5, [4] = 5, }, -- eots
					[3] = { [0] = 0, [1] = 1, [2] = 3, [3] = 30, }, -- gilneas
					[4] = { [0] = 0, [1] = 8, [2] = 16, [3] = 32, }, -- Deepwind Gorge
				}
				local function getlscore(ltime, pps, currentscore, maxscore, awin) -- estimate loser's final score
					if currentbg == 2 then -- EotS
						ltime = floor(ltime * pps + currentscore + 0.5)
						ltime = (ltime < maxscore and ltime) or (maxscore - 1)
					else -- AB or Gilneas
						ltime = 10 * floor((ltime * pps + currentscore + 5) * 0.1)
						ltime = (ltime < maxscore and ltime) or (maxscore - 10)
					end
					return (awin and format(f2, maxscore, ltime)) or format(f2, ltime, maxscore)
				end
				--------------------------------------
				function mod:UPDATE_WORLD_STATES()
				--------------------------------------
					local _, zType = GetInstanceInfo()
					if zType ~= "pvp" then return end

					local currenttime = GetTime()
					local updatetime = false

					local _, _, _, scoreStringA = GetWorldStateUIInfo(currentbg == 2 and 2 or 1) -- 1 & 2 for AB and Gil, 2 & 3 for EotS
					local base, score, smax = strmatch(scoreStringA, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)") -- Bases: %d  Resources: %d/%d
					local ABases, AScore, MaxScore = tonumber(base), tonumber(score), tonumber(smax) or 2000
					local _, _, _, scoreStringH = GetWorldStateUIInfo(currentbg == 2 and 3 or 2) -- 1 & 2 for AB and Gil, 2 & 3 for EotS

					base, score = strmatch(scoreStringH, "[^%d]+(%d+)[^%d]+(%d+)/") -- Bases: %d  Resources: %d/%d
					local HBases, HScore = tonumber(base), tonumber(score)

					if ABases and HBases then
						abases, hbases = ABases, HBases
						if ascore ~= AScore then
							ascore, atime, updatetime = AScore, currenttime, true
						end
						if hscore ~= HScore then
							hscore, htime, updatetime = HScore, currenttime, true
						end
					end

					if not updatetime then return end

					local apps, hpps = lookup[currentbg][abases], lookup[currentbg][hbases]
					-- timeTilFinal = ((remainingScore) / scorePerSec) - (timeSinceLastUpdate)
					local ATime = ((MaxScore - ascore) / (apps > 0 and apps or 0.000001)) - (currenttime - atime)
					local HTime = ((MaxScore - hscore) / (hpps > 0 and hpps or 0.000001)) - (currenttime - htime)

					if HTime < ATime then -- Horde is winning
						local newText = getlscore(HTime, apps, ascore, MaxScore)
						if newText ~= prevText then
							self:StopBar(prevText)
							self:StartBar(newText, HTime, GetIconData(48), "colorHorde") -- 48 = Horde Insignia
							prevText = newText
						end
					else -- Alliance is winning
						local newText = getlscore(ATime, hpps, hscore, MaxScore, true)
						if newText ~= prevText then
							self:StopBar(prevText)
							self:StartBar(newText, ATime, GetIconData(46), "colorAlliance") -- 46 = Alliance Insignia
							prevText = newText
						end
					end
				end
			end
			currentbg, ascore, atime, abases, hscore, htime, hbases, prevText = bg, 0, 0, 0, 0, 0, 0, ""
			mod:RegisterTempEvent("UPDATE_WORLD_STATES")
		else
			if not mod.UPDATE_UI_WIDGET then
				local f2 = L["Final: %d - %d"]
				--------------------------------------
				function mod:UPDATE_UI_WIDGET(tbl)
				--------------------------------------

					local updateBases = false
					local t = GetTime()
					local id = tbl.widgetID
					local MaxScore = 1500

					if id == allianceWidget then
						local dataTbl = GetIconAndTextWidgetVisualizationInfo(id)
						local base, score, smax = strmatch(dataTbl.text, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)") -- Bases: %d  Resources: %d/%d
						local ABases, AScore = tonumber(base), tonumber(score)
						MaxScore = tonumber(smax) or MaxScore

						if ABases then
							if abases ~= ABases then
								abases = ABases
								updateBases = true
							end
							ascore = AScore
						end
					elseif id == hordeWidget then
						local dataTbl = GetIconAndTextWidgetVisualizationInfo(id)
						local base, score, smax = strmatch(dataTbl.text, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)") -- Bases: %d  Resources: %d/%d
						local HBases, HScore = tonumber(base), tonumber(score)
						MaxScore = tonumber(smax) or MaxScore

						if HBases then
							if hbases ~= HBases then
								hbases = HBases
								updateBases = true
							end
							hscore = HScore
						end
					else
						local data = GetIconAndTextWidgetVisualizationInfo(id)
						print("Capping: Found a new id - ", id, data.tooltip)
					end

					-- Conditions:
					-- 1) Amount of owned bases changed
					-- 2) Two updates happened in a short space of time and we want the data from the 2nd update (latest score info)
					-- This happens when both teams have bases, the first update (alliance) will be incomplete, the second update (horde) will give us a complete outlook of final scores
					if updateBases or (t - prevTime) < 0.8 then
						prevTime = t
						local apps, hpps = ppsTable[abases], ppsTable[hbases]

						-- timeTilFinal = ((remainingScore) / scorePerSec) - (timeSinceLastUpdate)
						local ATime = apps and ((MaxScore - ascore) / apps) or 1000000
						local HTime = hpps and ((MaxScore - hscore) / hpps) or 1000000

						if HTime < ATime then -- Horde is winning
							local score = apps and (ascore + floor(apps * HTime)) or ascore
							local txt = format(f2, score, MaxScore)
							self:StopBar(prevText)
							self:StartBar(txt, HTime, GetIconData(48), "colorHorde") -- 48 = Horde Insignia
							prevText = txt
						else -- Alliance is winning
							local score = hpps and (hscore + floor(hpps * ATime)) or hscore
							local txt = format(f2, MaxScore, score)
							self:StopBar(prevText)
							self:StartBar(txt, ATime, GetIconData(46), "colorAlliance") -- 46 = Alliance Insignia
							prevText = txt
						end
					end
				end
			end
			ascore, abases, hscore, hbases, prevText, prevTime = 0, 0, 0, 0, "", 0
			mod:RegisterTempEvent("UPDATE_UI_WIDGET")
		end
	end
end

do
	------------------------------------------------ Arathi Basin -----------------------------------------------------
	local pointsPerSecond = {1, 1.5, 2, 3.5, 30} -- Updates every 2 seconds

	local function ArathiBasin()
		SetupAssault(60, 93)
		NewEstimator(1, 495, 496, pointsPerSecond) -- BG table, alliance score widget, horde score widget
	end
	mod:AddBG(529, ArathiBasin)

	local function ArathiBasinSnowyPvPBrawl()
		SetupAssault(60, 837)
		NewEstimator(2)
	end
	mod:AddBG(1681, ArathiBasinSnowyPvPBrawl)
end

do
	------------------------------------------------ Deepwind Gorge -----------------------------------------------------
	local pointsPerSecond = {1.6, 3.2, 6.4} -- Updates every 5 seconds

	local function DeepwindGorge()
		SetupAssault(61, 519)
		NewEstimator(4, 734, 735, pointsPerSecond) -- BG table, alliance score widget, horde score widget
	end
	mod:AddBG(1105, DeepwindGorge)
end

do
	------------------------------------------------ Gilneas -----------------------------------------------------
	local pointsPerSecond = {1, 3, 30} -- Updates every 1 second

	local function TheBattleForGilneas()
		SetupAssault(60, 275) -- Base cap time, uiMapID
		NewEstimator(3, 699, 700, pointsPerSecond) -- BG table, alliance score widget, horde score widget
	end
	mod:AddBG(761, TheBattleForGilneas) -- Instance ID
end

do
	------------------------------------------------ Alterac Valley ---------------------------------------------------
	local function AlteracValley(self)
		function mod:AVTurnIn()
			local target = UnitGUID("npc")
			if target then
				local _, _, _, _, _, id = strsplit("-", target)
				local mobId = tonumber(id)
				if mobId == 13176 or mobId == 13257 then -- Smith Regzar, Murgot Deepforge
					-- Open Quest to Smith or Murgot
					if GetGossipOptions() and strmatch(GetGossipOptions(), L["Upgrade to"] ) then
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
		self:RegisterTempEvent("GOSSIP_SHOW", "AVTurnIn")
		self:RegisterTempEvent("QUEST_PROGRESS", "AVTurnInProgress")
		self:RegisterTempEvent("QUEST_COMPLETE", "AVTurnInComplete")
	end
	mod:AddBG(30, AlteracValley)
end

do
	------------------------------------------------ Eye of the Storm -------------------------------------------------
	local pointsPerSecond = {1, 1.5, 2, 6} -- Updates every 2 seconds

	local ef, ResetCarrier
	local function EyeOfTheStorm(self)
		if not ef then
			local eficon, eftext, carrier, cclass
			-- handles secure stuff
			local function SetEotSCarrierAttribute()
				--ef:SetFrameStrata("HIGH")
				--ef:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame1:GetRight() - 14, AlwaysUpFrame1:GetBottom() + 8.5)
				--if UnitExists("arena1") then
				--	SecureUnitButton_OnLoad(ef, "arena1")
				--elseif UnitExists("arena2") then
				--	SecureUnitButton_OnLoad(ef, "arena2")
				--end
				--UnregisterUnitWatch(ef)
			end
			-- resets carrier display
			ResetCarrier = function(captured)
				--carrier, ef.faction, ef.car = nil, nil, nil
				--eftext:SetText("")
				--eficon:Hide()
				if captured then
					self:StartBar(L["Flag respawns"], 21, GetIconData(45), "colorOther") -- 45 = White flag
				end
				--self:CheckCombat(SetEotSCarrierAttribute)
			end
			local function CarrierOnClick(this)
				if IsControlKeyDown() and carrier then
					SendChatMessage(format(L["%s's flag carrier: %s (%s)"], this.faction, carrier, cclass), "INSTANCE_CHAT")
				end
			end
			-- parse battleground messages
			local function EotSFlag(a1, faction, name)
				local found = strmatch(a1, L["^(.+) has taken the flag!"])
				if found then
					if found == "L'Alliance" then -- frFR
						ResetCarrier(true)
					else
						--cclass = GetClassByName(name, faction)
						--carrier, ef.car = name, true
						--ef.faction = (faction == 0 and _G.FACTION_HORDE) or _G.FACTION_ALLIANCE
						--eftext:SetFormattedText("|cff%s%s|r", classcolor[cclass or "PRIEST"] or classcolor.PRIEST, name or "")
						--eficon:SetTexture(faction == 0 and 137218 or 137200) --137218-"Interface\\WorldStateFrame\\HordeFlag" || 137200-"Interface\\WorldStateFrame\\AllianceFlag"
						--eficon:Show()
						--self:CheckCombat(SetEotSCarrierAttribute)
					end
				elseif strmatch(a1, L["dropped"]) then
					ResetCarrier()
				elseif strmatch(a1, L["captured the"]) or strmatch(a1, taken) then
					ResetCarrier(true)
				end
			end
			function mod:HFlagUpdate(msg, _, _, _, name)
				EotSFlag(msg, 0, name)
			end
			function mod:AFlagUpdate(msg, _, _, _, name)
				EotSFlag(msg, 1, name)
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
					C_Timer.After(15, StartNextGravTimer)
					C_Timer.After(10, PrintExtraMessage)
					if ticker1 then
						ticker1:Cancel()
						ticker2:Cancel()
						ticker1, ticker2 = nil, nil
					end
				end
			end

			--ef = self:CreateCarrierButton("CappingEotSFrame", CarrierOnClick)
			--eficon = ef:CreateTexture(nil, "ARTWORK") -- flag icon
			--eficon:SetPoint("TOPLEFT", ef, "TOPLEFT", 0, 1)
			--eficon:SetPoint("BOTTOMRIGHT", ef, "BOTTOMLEFT", 20, -1)

			--eftext = self:CreateText(ef, 13, "LEFT", eficon, 22, 0, ef, 0, 0) -- carrier text
			--ef.text = eftext

			--self:AddFrameToHide(ef) -- add to the tohide list to hide when bg is over
		end

		--ef:Show()
		ResetCarrier()

		-- setup for final score estimation (2 for EotS)
		NewEstimator(2, 523, 524, pointsPerSecond) -- BG table, alliance score widget, horde score widget
		SetupAssault(60, 112) -- In RBG the four points have flags that need to be assaulted, like AB
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "HFlagUpdate")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "AFlagUpdate")
		self:RegisterTempEvent("RAID_BOSS_WHISPER", "CheckForGravity")
	end
	mod:AddBG(566, EyeOfTheStorm)
end

do
	------------------------------------------------ Isle of Conquest --------------------------------------
	local function IsleOfConquest()
		SetupAssault(61, 169)
	end
	mod:AddBG(628, IsleOfConquest)
end

do
	------------------------------------------------ Warsong Gulch ----------------------------------------------------
	local function WarsongGulch(self)
		if not self.WSGBulk then -- init some data and create carrier frames
			local wsgicon, playerfaction, prevtime, togunit
			local af, aftext, aftexthp, acarrier, aclass
			local hf, hftext, hftexthp, hcarrier, hclass
			local ahealth, hhealth = 0, 0
			local elap = 0
			local unknownhp = "|cff777777??%|r"

			-- props to "Fedos" and the ICU mod
			-- updates a carrier's frame secure stuff, button will be slightly transparent if button cannot update (in combat)
			--local function SetWSGCarrierAttribute()
			--	if not af:GetAttribute("unit") or not hf:GetAttribute("unit") then
			--		if acarrier == "arena1" or hcarrier == "arena2" then
			--			SecureUnitButton_OnLoad(af, "arena1")
			--			SecureUnitButton_OnLoad(hf, "arena2")
			--		elseif acarrier or hcarrier then
			--			SecureUnitButton_OnLoad(af, "arena2")
			--			SecureUnitButton_OnLoad(hf, "arena1")
			--		end
			--		UnregisterUnitWatch(af)
			--		UnregisterUnitWatch(hf)
			--	end
			--	if AlwaysUpFrame1 then
			--		af:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame1:GetRight() + 38, AlwaysUpFrame1:GetTop())
			--		hf:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame2:GetRight() + 38, AlwaysUpFrame2:GetTop())
			--	end
			--end
			--local function SetCarrier(faction, carrier, class, u) -- setup carrier frames
			--	if faction == "Horde" then
			--		hcarrier, hclass, hf.car = carrier, class, carrier
			--		hftext:SetFormattedText("|cff%s%s|r", classcolor[class or "PRIEST"] or classcolor.PRIEST, carrier or "")
			--		local hhealth_before = hhealth
			--		hhealth = min(floor(100 * UnitHealth(u)/UnitHealthMax(u)), 100)
			--		hftexthp:SetFormattedText("|cff%s%d%%|r", (hhealth < hhealth_before and "ff2222") or "dddddd", hhealth)
			--		hcarrier = u
			--		hftext.unit = u
			--		return hhealth
			--	elseif faction == "Alliance" then
			--		acarrier, aclass, af.car = carrier, class, carrier
			--		aftext:SetFormattedText("|cff%s%s|r", classcolor[class or "PRIEST"] or classcolor.PRIEST, carrier or "")
			--		ahealth = 0
			--		aftexthp:SetText((carrier and unknownhp) or "")
			--		local ahealth_before = ahealth
			--		ahealth = min(floor(100 * UnitHealth(u)/UnitHealthMax(u)), 100)
			--		aftexthp:SetFormattedText("|cff%s%d%%|r", (ahealth < ahealth_before and "ff2222") or "dddddd", ahealth)
			--		acarrier = u
			--		aftext.unit = u
			--		return ahealth
			--	elseif aftext.unit == faction then
			--		aftext:SetText("")
			--		aftexthp:SetText("")
			--		acarrier, aclass, af.car = "", "", nil
			--	elseif hftext.unit == faction then
			--		hftext:SetText("")
			--		hftexthp:SetText("")
			--		hcarrier, hclass, hf.car = "", "", nil
			--	end
			--	mod:CheckCombat(SetWSGCarrierAttribute)
			--end
			--local function CarrierOnClick() -- sends basic carrier info to battleground chat
            --
			--end
			--local function CreateWSGFrame() -- create all frames
			--	local function CreateCarrierFrame(faction) -- create carriers' frames
			--		local b = self:CreateCarrierButton("CappingTarget"..faction, CarrierOnClick)
			--		local text = self:CreateText(b, 14, "LEFT", b, 29, 0, b, 0, 0)
			--		local texthp = self:CreateText(b, 10, "RIGHT", b, -4, 0, b, 28 - b:GetWidth(), 0)
			--		b.faction = (faction == "Alliance" and _G.FACTION_ALLIANCE) or _G.FACTION_HORDE
			--		b.text = text
			--		self:AddFrameToHide(b)
			--		return b, text, texthp
			--	end
			--	af, aftext, aftexthp = CreateCarrierFrame("Alliance")
			--	hf, hftext, hftexthp = CreateCarrierFrame("Horde")
            --
			--	af:SetScript("OnUpdate", function(_, a1)
			--		elap = elap + a1
			--		if elap > 0.25 then -- health check and display
			--			elap, togunit = 0, not togunit
			--			if togunit then
			--				if UnitExists("arena1") then
			--					local faction = UnitFactionGroup("arena1")
			--					local name = GetUnitName("arena1", true)
			--					local health = UnitHealth("arena1")
			--					local _, class = UnitClass("arena1")
			--					SetCarrier(faction, name, class, "arena1")
			--				else
			--					SetCarrier("arena1")
			--				end
			--			else
			--				if UnitExists("arena2") then
			--					local faction = UnitFactionGroup("arena2")
			--					local name = GetUnitName("arena2", true)
			--					local health = UnitHealth("arena2")
			--					local _, class = UnitClass("arena2")
			--					SetCarrier(faction, name, class, "arena2")
			--				else
			--					SetCarrier("arena2")
			--				end
			--			end
			--		end
			--	end)
			--	CreateCarrierFrame, CreateWSGFrame = nil, nil
			--end
			self.WSGBulk = function() -- stuff to do at the beginning of every wsg, but after combat
				--af:Show()
				--hf:Show()
				--SetCarrier()

				prevtime = nil
				self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "WSGFlagCarrier")
				self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "WSGFlagCarrier")
				self:RegisterTempEvent("WORLD_STATE_UI_TIMER_UPDATE", "WSGEnd")
				
				self:WSGEnd()
			end
			--------------------------------------------
			function mod:WSGFlagCarrier(a1) -- carrier detection and setup
			--------------------------------------------
				if strmatch(a1, L["captured the"]) then -- flag was captured, reset all carriers
					--SetCarrier()
					self:StartBar(L["Flag respawns"], 12, GetIconData(45), "colorOther") -- White flag
				end
			end
			-------------------------
			function mod:WSGEnd() -- timer for last 5 minutes of WSG
			-------------------------
				local _, _, _, timeString = GetWorldStateUIInfo(4)
				if timeString then
					local minutes, seconds = strmatch(timeString, "(%d+):(%d+)")
					minutes = tonumber(minutes)
					seconds = tonumber(seconds)
					if minutes and seconds then
						local remaining = seconds + (minutes*60) + 1
						local text = gsub(_G.TIME_REMAINING, ":", "")
						local bar = self:GetBar(text)
						if remaining > 3 and remaining < 600 and (not bar or bar.remaining > remaining+5 or bar.remaining < remaining-5) then -- Don't restart bars for subtle changes +/- 5s
							self:StartBar(text, remaining, 134420, "colorOther") -- Interface/Icons/INV_Misc_Rune_07
						end
						prevtime = remaining
					end
				end
			end

			--playerfaction = UnitFactionGroup("player")
			--wsgicon = strlower(playerfaction)
			--self:CheckCombat(CreateWSGFrame)
		end

		self:WSGBulk()
	end
	mod:AddBG(489, WarsongGulch)
	mod:AddBG(726, WarsongGulch) -- Twin Peaks
end

do
	------------------------------------------------ Wintergrasp ------------------------------------------
	local wallid, walls = nil, nil
	local GetAreaPOIForMap = C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap -- XXX 8.0
	local GetAreaPOIInfo = C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIInfo -- XXX 8.0
	local function Wintergrasp(self)
		if GetNumMapLandmarks then
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
				for k, v in pairs(intact) do
					damaged[k + 1] = true
					destroyed[k + 2] = true
					all[k], all[k + 1], all[k + 2] = true, true, true
				end
				function mod:WinterAssault() -- scans POI landmarks for changes in wall textures
					for i = 1, GetNumMapLandmarks() do
						local _, name, _, textureIndex, _, _, _, _, _, _, poiID = C_WorldMap.GetMapLandmarkInfo(i)
						local ti = walls[poiID]
						if (ti and ti ~= textureIndex) or (not ti and wallid[poiID]) then
							if intact[ti] and damaged[textureIndex] then -- intact before, damaged now
								RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[poiID], name, _G.ACTION_ENVIRONMENTAL_DAMAGE))
							elseif damaged[ti] and destroyed[textureIndex] then -- damaged before, destroyed now
								RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[poiID], name, _G.ACTION_UNIT_DESTROYED))
							end
							walls[poiID] = all[textureIndex] and textureIndex or ti
						end
					end
				end
			end
			walls = { }
			for i = 1, GetNumMapLandmarks() do
				local _, _, _, textureIndex, _, _, _, _, _, _, poiID = C_WorldMap.GetMapLandmarkInfo(i)
				if wallid[poiID] then
					walls[poiID] = textureIndex
				end
			end
			self:RegisterTempEvent("WORLD_MAP_UPDATE", "WinterAssault")
		else
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
				for k, v in pairs(intact) do
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
								RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[POI], tbl.name, _G.ACTION_ENVIRONMENTAL_DAMAGE))
							elseif damaged[ti] and destroyed[textureIndex] then -- damaged before, destroyed now
								RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[POI], tbl.name, _G.ACTION_UNIT_DESTROYED))
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
	end
	if not GetAreaPOIForMap then -- XXX 8.0
		mod:AddBG(-501, Wintergrasp) -- map id
	else
		mod:AddBG(-123, Wintergrasp) -- map id
	end
end

do
	------------------------------------------------ Ashran ------------------------------------------
	local function Ashran(self)
		if not self.AshranControl then
			function mod:AshranControl(msg)
				--print(msg, ...)
				--Ashran Herald yells: The Horde controls the Market Graveyard for 15 minutes!
				local faction, point, timeString = strmatch(msg, "The (.+) controls the (.+) for (%d+) minutes!")
				local timeLeft = tonumber(timeString)
				if faction and point and timeLeft then
					self:StartBar(point, timeLeft*60, GetIconData(faction == "Horde" and 14 or 4), faction == "Horde" and "colorHorde" or "colorAlliance")
				end
			end
		end
		if not self.AshranEvents then
			function mod:AshranEvents(msg)
				local idString = strmatch(msg, "spell:(%d+)")
				local id = tonumber(idString)
				--print(msg:gsub("|", "||"), ...)
				if id and id ~= 168506 then -- 168506 = Ancient Artifact
					local name, _, icon = GetSpellInfo(id)
					self:StartBar(name, 180, icon, "colorOther")
				end
			end
		end
		if not self.AshranTimeLeft then
			function mod:AshranTimeLeft()
				local _, _, _, timeString = GetWorldStateUIInfo(12)
				if timeString then
					local minutes, seconds = strmatch(timeString, "(%d+):(%d+)")
					minutes = tonumber(minutes)
					seconds = tonumber(seconds)
					if minutes and seconds then
						local remaining = seconds + (minutes*60) + 1
						if remaining > 4 then
							local text = _G.NEXT_BATTLE_LABEL
							local bar = self:GetBar(text)
							if not bar or remaining > bar.remaining+5 or remaining < bar.remaining-5 then -- Don't restart bars for subtle changes +/- 5s
								self:StartBar(text, remaining, 1031537, "colorOther") -- Interface/Icons/Achievement_Zone_Ashran
							end
						end
					end
				end
			end
		end
		self:RegisterTempEvent("CHAT_MSG_MONSTER_YELL", "AshranControl")
		self:RegisterTempEvent("CHAT_MSG_MONSTER_EMOTE", "AshranEvents")
		self:RegisterTempEvent("WORLD_STATE_UI_TIMER_UPDATE", "AshranTimeLeft")
	end
	if GetWorldStateUIInfo then -- XXX 8.0
		mod:AddBG(-978, Ashran) -- map id
	end
end

do
	------------------------------------------------ Arena ------------------------------------------
	local function Arena(self)
		if GetNumWorldStateUI then -- XXX 8.0
			if not self.ArenaTimers then
				function mod:ArenaTimers()
					for i = 1, GetNumWorldStateUI() do -- Not always at the same location, so check them all
						local _, state, _, timeString = GetWorldStateUIInfo(i)
						if state > 0 and timeString then -- Skip hidden states and states without text
							local minutes, seconds = timeString:match("(%d+):(%d+)")
							minutes = tonumber(minutes)
							seconds = tonumber(seconds)
							if minutes and seconds then
								local remaining = seconds + (minutes*60) + 1
								if remaining > 4 then
									self:UnregisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
									local spell, _, icon = GetSpellInfo(34709)
									self:StartBar(spell, 93, icon, "colorOther")
									local text = gsub(_G.TIME_REMAINING, ":", "")
									self:StartBar(text, remaining, nil, "colorOther")
								end
							end
						end
					end
				end
			end
			self:RegisterTempEvent("WORLD_STATE_UI_TIMER_UPDATE", "ArenaTimers")
		-- What we CAN'T use for Shadow Sight timer
		-- COMBAT_LOG_EVENT_UNFILTERED for Arena Preparation removal event, it randomly removes and reapplies itself during the warmup
		-- UPDATE_WORLD_STATES will sometimes fire during the warmup, so we can't assume the first time it fires is the doors opening
		-- UNIT_SPELLCAST_SUCCEEDED arena1-5 events, probably won't work if the entire enemy team is stealth
		-- What we CAN use for Shadow Sight timer
		-- CHAT_MSG_BG_SYSTEM_NEUTRAL#The Arena battle has begun! - Requires localization
		-- WORLD_STATE_UI_TIMER_UPDATE The first event fired with a valid remaining time (the current chosen method)
		else
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
									local text = gsub(_G.TIME_REMAINING, ":", "")
									self:StartBar(text, remaining, nil, "colorOther")
								end
							end
						end
					end
				end
			end
			self:RegisterTempEvent("UPDATE_UI_WIDGET", "ArenaTimers")
		end
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
end

