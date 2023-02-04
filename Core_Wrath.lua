
-- LOCALS
local addonName, mod = ...
local frame = CreateFrame("Frame", "CappingFrame", UIParent)
local L = mod.L

local format, type = string.format, type
local db, core
local zoneIds = {}

local activeBars = { }
frame.bars = activeBars

-- LIBRARIES
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")

-- API
do
	local API = {}
	do
		local BarOnClick
		do
			local function ReportBar(bar, channel)
				if not activeBars[bar] then return end
				if channel == "INSTANCE_CHAT" and not IsInGroup(2) then channel = "RAID" end -- LE_PARTY_CATEGORY_INSTANCE = 2
				local custom = bar:Get("capping:customchat")
				if not custom then
					local colorid = bar:Get("capping:colorid")
					local faction = colorid == "colorHorde" and _G.FACTION_HORDE or colorid == "colorAlliance" and _G.FACTION_ALLIANCE or ""
					local timeLeft = bar.candyBarDuration:GetText()
					if not timeLeft:find("[:%.]") then timeLeft = "0:"..timeLeft end
					SendChatMessage(format("Capping: %s - %s %s", bar:GetLabel(), timeLeft, faction == "" and faction or "("..faction..")"), channel)
				else
					local msg = custom(bar)
					if msg then
						SendChatMessage(format("Capping: %s", msg), channel)
					end
				end
			end
			function BarOnClick(bar)
				if IsShiftKeyDown() and db.profile.barOnShift ~= "NONE" then
					ReportBar(bar, db.profile.barOnShift)
				elseif IsControlKeyDown() and db.profile.barOnControl ~= "NONE" then
					ReportBar(bar, db.profile.barOnControl)
				elseif IsAltKeyDown() and db.profile.barOnAlt ~= "NONE" then
					ReportBar(bar, db.profile.barOnAlt)
				end
			end
		end

		local RearrangeBars
		do
			-- Ripped from BigWigs bar sorter
			local function barSorter(a, b)
				local idA = a:Get("capping:priority")
				local idB = b:Get("capping:priority")
				if idA and not idB then
					return true
				elseif idB and not idA then
					return
				else
					return a.remaining < b.remaining
				end
			end
			RearrangeBars = function()
				local tmp = {}
				for bar in next, activeBars do
					tmp[#tmp + 1] = bar
				end
				table.sort(tmp, barSorter)
				local lastBar = nil
				local up = db.profile.growUp
				for i = 1, #tmp do
					local bar = tmp[i]
					local spacing = db.profile.spacing
					bar:ClearAllPoints()
					if up then
						if lastBar then -- Growing from a bar
							bar:SetPoint("BOTTOMLEFT", lastBar, "TOPLEFT", 0, spacing)
							bar:SetPoint("BOTTOMRIGHT", lastBar, "TOPRIGHT", 0, spacing)
						else -- Growing from the anchor
							bar:SetPoint("BOTTOM", frame, "TOP")
						end
						lastBar = bar
					else
						if lastBar then -- Growing from a bar
							bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, -spacing)
							bar:SetPoint("TOPRIGHT", lastBar, "BOTTOMRIGHT", 0, -spacing)
						else -- Growing from the anchor
							bar:SetPoint("TOP", frame, "BOTTOM")
						end
						lastBar = bar
					end
				end
			end
			frame.RearrangeBars = RearrangeBars
		end

		function API:StartBar(name, remaining, icon, colorid, priority, maxBarTime)
			self:StopBar(name)
			local bar = candy:New(media:Fetch("statusbar", db.profile.barTexture), db.profile.width, db.profile.height)
			activeBars[bar] = true

			bar:Set("capping:colorid", colorid)
			if priority then
				bar:Set("capping:priority", priority)
			end

			bar:SetParent(frame)
			bar:SetLabel(name)
			bar.candyBarLabel:SetJustifyH(db.profile.alignText)
			bar.candyBarDuration:SetJustifyH(db.profile.alignTime)
			bar:SetDuration(remaining)
			bar:SetColor(unpack(db.profile[colorid]))
			bar.candyBarBackground:SetVertexColor(unpack(db.profile.colorBarBackground))
			bar:SetTextColor(unpack(db.profile.colorText))
			if db.profile.icon then
				if type(icon) == "table" then
					bar:SetIcon(icon[1], icon[2], icon[3], icon[4], icon[5])
				else
					bar:SetIcon(icon)
				end
				bar:SetIconPosition(db.profile.alignIcon)
			end
			bar:SetTimeVisibility(db.profile.timeText)
			bar:SetFill(db.profile.fill)
			local flags = nil
			if db.profile.monochrome and db.profile.outline ~= "NONE" then
				flags = "MONOCHROME," .. db.profile.outline
			elseif db.profile.monochrome then
				flags = "MONOCHROME"
			elseif db.profile.outline ~= "NONE" then
				flags = db.profile.outline
			end
			bar.candyBarLabel:SetFont(media:Fetch("font", db.profile.font), db.profile.fontSize, flags)
			bar.candyBarDuration:SetFont(media:Fetch("font", db.profile.font), db.profile.fontSize, flags)
			bar:SetScript("OnMouseUp", BarOnClick)
			if db.profile.barOnShift ~= "NONE" or db.profile.barOnControl ~= "NONE" or db.profile.barOnAlt ~= "NONE" then
				bar:EnableMouse(true)
			else
				bar:EnableMouse(false)
			end
			bar:Start(maxBarTime)
			RearrangeBars()
			return bar
		end

		function API:StopBar(text)
			local dirty = nil
			for bar in next, activeBars do
				if bar:GetLabel() == text then
					bar:Stop()
					dirty = true
				end
			end
			if dirty then RearrangeBars() end
		end

		candy.RegisterCallback(API, "LibCandyBar_Stop", function(_, bar)
			if activeBars[bar] then
				activeBars[bar] = nil
				RearrangeBars()
			end
		end)
	end

	function API:StopAllBars()
		for bar in next, activeBars do
			bar:Stop()
		end
	end

	function API:GetBar(text)
		for bar in next, activeBars do
			if bar:GetLabel() == text then
				return bar
			end
		end
	end

	do
		local eventMap = {}
		frame:SetScript("OnEvent", function(_, event, ...)
			for k,v in next, eventMap[event] do
				if type(v) == "function" then
					v(...)
				else
					k[v](k, ...)
				end
			end
		end)

		function API:RegisterEvent(event, func)
			if not eventMap[event] then eventMap[event] = {} end
			eventMap[event][self] = func or event
			frame:RegisterEvent(event)
		end
		function API:UnregisterEvent(event)
			if not eventMap[event] then return end
			eventMap[event][self] = nil
			if not next(eventMap[event]) then
				frame:UnregisterEvent(event)
				eventMap[event] = nil
			end
		end
	end

	function API:RegisterZone(id)
		zoneIds[id] = self
	end

	local Timer = C_Timer.After
	function API:Timer(duration, func)
		Timer(duration, func)
	end

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
		local collection, reset, blocked, started = {}, {}, {}, false
		local count1, count2, count3 = #unitTable1, #unitTable2, #unitTable3
		local UnitGUID, strsplit = UnitGUID, strsplit
		local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
		local SendAddonMessage = C_ChatInfo.SendAddonMessage
		local curMod = nil

		local function parse2()
			if started then
				for i = 1, count2 do
					local unit = unitTable2[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end
		local function parse3()
			if started then
				for i = 1, count3 do
					local unit = unitTable3[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end
		local function HealthScan()
			if started then
				Timer(1, HealthScan)
				Timer(0.01, parse2) -- Break up parsing
				Timer(0.02, parse3)

				for id, counter in next, reset do
					reset[id] = counter + 1
					if counter > 20 then
						local tbl = collection[id]:Get("capping:hpdata")
						collection[id]:Stop()
						reset[id] = nil
						collection[id] = tbl
					end
				end

				for k in next, blocked do
					blocked[k] = nil
				end
				for i = 1, count1 do
					local unit = unitTable1[i]
					local guid = UnitGUID(unit)
					if guid then
						local _, _, _, _, _, strid = strsplit("-", guid)
						if strid and collection[strid] and not blocked[strid] then
							local maxHP = UnitHealthMax(unit)
							if maxHP > 0 then
								blocked[strid] = true
								local hp = UnitHealth(unit) / maxHP * 100
								SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
							end
						end
					end
				end
			end
		end

		local function HealthUpdate(prefix, msg, channel)
			if prefix == "Capping" and channel == "INSTANCE_CHAT" then
				local strid, strhp = strsplit(":", msg)
				local hp = tonumber(strhp)
				if strid and hp and collection[strid] and hp <= 100 and hp >= 0 and (hp < 0) ~= (hp >= 0) then -- Check hp is 0-100 and isn't NaN
					if collection[strid].candyBarBar then
						if hp < 100 then
							reset[strid] = 0
						end
						collection[strid].candyBarBar:SetValue(hp)
						collection[strid].candyBarDuration:SetFormattedText("%.1f%%", hp)
					elseif hp < 100 then
						local tbl = collection[strid]
						local bar = curMod:StartBar(tbl[1], 100, tbl[3], tbl[4], true)
						bar:Pause()
						bar.candyBarBar:SetValue(hp)
						bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
						bar:Set("capping:customchat", function(candyBar)
							if tbl[1] ~= tbl[2] then
								return tbl[2] .."/".. tbl[1] .." - ".. candyBar.candyBarDuration:GetText()
							else
								return tbl[1] .." - ".. candyBar.candyBarDuration:GetText()
							end
						end)
						bar:Set("capping:hpdata", tbl)
						reset[strid] = 0
						collection[strid] = bar
					end
				end
			end
		end

		function API:SetupHealthCheck(npcId, npcName, englishName, icon, color)
			curMod = self
			collection[npcId] = {npcName, englishName, icon, color}
			if not started then
				started = true
				C_ChatInfo.RegisterAddonMessagePrefix("Capping")
				core:RegisterEvent("CHAT_MSG_ADDON", HealthUpdate)
				Timer(1, HealthScan)
			end
		end

		function API:StopHealthCheck()
			started = false
			collection, reset, blocked = {}, {}, {}
			core:UnregisterEvent("CHAT_MSG_ADDON")
		end
	end

	do
		local prevText = ""
		local prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
		local timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
		local maxscore, ascore, hscore, aIncrease, hIncrease = 0, 0, 0, 0, 0
		local aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0
		local aBases, hBases = 0, 0
		local aTime, hTime = 0, 0
		local prevfinalAScore, prevfinalHScore = 0, 0
		local curMod = nil

		local function UpdatePredictor()
			if aIncrease ~= prevAIncrease or hIncrease ~= prevHIncrease or timeBetweenEachTick ~= prevTick then
				if aIncrease > 60 or hIncrease > 60 --[[or aIncrease < 0 or hIncrease < 0]] then -- Scores can reduce in DG
					curMod:StopBar(prevText) -- >60 increase means captured a flag/cart in EotS/DG
					prevAIncrease, prevHIncrease = -1, -1
					return
				end
				prevAIncrease, prevHIncrease, prevTick = aIncrease, hIncrease, timeBetweenEachTick
				if hTicksToWin < aTicksToWin then -- Horde is winning
					local timeToWin = hTicksToWin * timeBetweenEachTick
					local finalAScore = ascore + (hTicksToWin * aIncrease)
					local txt = format(L.finalScore, finalAScore, maxscore)
					if txt ~= prevText or timeToWin ~= prevTimeToWin then
						prevTimeToWin = timeToWin
						curMod:StopBar(prevText)
						curMod:StartBar(txt, timeToWin-0.5, 132485, "colorHorde") -- 132485 = Interface/Icons/INV_BannerPVP_01
						prevText = txt
					end
				elseif aTicksToWin < hTicksToWin then -- Alliance is winning
					local timeToWin = aTicksToWin * timeBetweenEachTick
					local finalHScore = hscore + (aTicksToWin * hIncrease)
					local txt = format(L.finalScore, maxscore, finalHScore)
					if txt ~= prevText or timeToWin ~= prevTimeToWin then
						prevTimeToWin = timeToWin
						curMod:StopBar(prevText)
						curMod:StartBar(txt, timeToWin-0.5, 132486, "colorAlliance") -- 132486 = Interface/Icons/INV_BannerPVP_02
						prevText = txt
					end
				end
			end
		end

		local GetIconAndTextWidgetVisualizationInfo = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
		local ceil, floor = math.ceil, math.floor
		local function ScorePredictor(widgetInfo)
			if widgetInfo and (widgetInfo.widgetID == 3116 or widgetInfo.widgetID == 3117) then
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
				if not dataTbl or not dataTbl.text then return end
				if prevTime == 0 then
					prevTime = GetTime()
					local allianceTbl = GetIconAndTextWidgetVisualizationInfo(3116)
					prevAScore = tonumber(string.match(allianceTbl.text, "(%d+)/%d+")) or 0
					local hordeTbl = GetIconAndTextWidgetVisualizationInfo(3117)
					prevHScore = tonumber(string.match(hordeTbl.text, "(%d+)/%d+")) or 0
					return
				end

				local t = GetTime()
				local elapsed = t - prevTime
				prevTime = t
				if elapsed > 0.5 then
					-- If there's only 1 update, it could be either alliance or horde, so we update both stats in this one
					local allianceTbl = GetIconAndTextWidgetVisualizationInfo(3116)
					ascore = tonumber(string.match(allianceTbl.text, "(%d+)/%d+")) or 0
					local hordeTbl = GetIconAndTextWidgetVisualizationInfo(3117)
					hscore = tonumber(string.match(hordeTbl.text, "(%d+)/%d+")) or 0
					aIncrease = ascore - prevAScore
					hIncrease = hscore - prevHScore
					aRemain = maxscore - ascore
					hRemain = maxscore - hscore
					-- Always round ticks upwards. 1.2 ticks will always be 2 ticks to end.
					-- If ticks are 0 (no bases) then set to a random huge number (10,000)
					aTicksToWin = ceil(aIncrease == 0 and 10000 or aRemain / aIncrease)
					hTicksToWin = ceil(hIncrease == 0 and 10000 or hRemain / hIncrease)
					-- Round to the closest time
					timeBetweenEachTick = elapsed % 1 >= 0.5 and ceil(elapsed) or floor(elapsed)
					prevAScore, prevHScore = ascore, hscore
					Timer(0.5, UpdatePredictor)
				else
					-- If elapsed < 0.5 then the event fired twice because both alliance and horde have bases.
					-- 1st update = horde, 2nd update = alliance
					-- If only one faction has bases, the event only fires once.
					-- Unfortunately we need to wait for the 2nd event to fire (the alliance update) to know the true alliance stats.
					-- In this one where we have 2 updates, we overwrite the alliance stats from the 1st update.
					local allianceTbl = GetIconAndTextWidgetVisualizationInfo(3116)
					ascore = tonumber(string.match(allianceTbl.text, "(%d+)/%d+")) or 0
					aIncrease = ascore - prevAScore
					aRemain = maxscore - ascore
					-- Always round ticks upwards. 1.2 ticks will always be 2 ticks to end.
					-- If ticks are 0 (no bases) then set to a random huge number (10,000)
					aTicksToWin = ceil(aIncrease == 0 and 10000 or aRemain / aIncrease)
					prevAScore = ascore
				end
			end
		end

		local abTable = {0.8333, 1.1111, 1.6667, 3.3333, 30}
		local function ScorePredictorAB(widgetInfo)
			if widgetInfo and (widgetInfo.widgetID == 1893 or widgetInfo.widgetID == 1894) then
				local dataTbl = GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
				if not dataTbl or not dataTbl.text then return end

				local curTime = GetTime()

				local allianceTbl = GetIconAndTextWidgetVisualizationInfo(1893)
				local aBasesStr, ascoreStr = string.match(allianceTbl.text, "(%d)[^%d]+(%d+)/%d+")
				aBases, ascore = tonumber(aBasesStr), tonumber(ascoreStr)
				local hordeTbl = GetIconAndTextWidgetVisualizationInfo(1894)
				local hBasesStr, hscoreStr = string.match(hordeTbl.text, "(%d)[^%d]+(%d+)/%d+")
				hBases, hscore = tonumber(hBasesStr), tonumber(hscoreStr)

				-- Hackjob backport of original code
				local allowUpdate = false
				if ascore and ascore ~= prevAScore then
					prevAScore, aTime, allowUpdate = ascore, curTime, true
				end
				if hscore and hscore ~= prevHScore then
					prevHScore, hTime, allowUpdate = hscore, curTime, true
				end
				if not allowUpdate then return end

				local apps, hpps = abTable[aBases] or 0, abTable[hBases] or 0
				local ATimeRemain = ((maxscore - ascore) / apps) - (curTime - aTime)
				if ATimeRemain > 10000 then ATimeRemain = 10000 end
				local HTimeRemain = ((maxscore - hscore) / hpps) - (curTime - hTime)
				if HTimeRemain > 10000 then HTimeRemain = 10000 end

				if HTimeRemain < ATimeRemain then -- Horde is winning
					local finalAScore = 10 * math.floor((HTimeRemain * apps + ascore + 5) * 0.1)
					finalAScore = (finalAScore < 0 and 0) or (finalAScore < maxscore and finalAScore) or (maxscore - 10)
					local txt = format(L.finalScore, finalAScore, maxscore)
					if txt ~= prevText and finalAScore ~= (prevfinalAScore+10) then
						curMod:StopBar(prevText)
						curMod:StartBar(txt, HTimeRemain, 132485, "colorHorde") -- 132485 = Interface/Icons/INV_BannerPVP_01
						prevText = txt
						prevfinalAScore = finalAScore
					end
				else -- Alliance is winning
					local finalHScore = 10 * math.floor((ATimeRemain * hpps + hscore + 5) * 0.1)
					finalHScore = (finalHScore < 0 and 0) or (finalHScore < maxscore and finalHScore) or (maxscore - 10)
					local txt = format(L.finalScore, maxscore, finalHScore)
					if txt ~= prevText and finalHScore ~= (prevfinalHScore+10) then
						curMod:StopBar(prevText)
						curMod:StartBar(txt, ATimeRemain, 132486, "colorAlliance") -- 132486 = Interface/Icons/INV_BannerPVP_02
						prevText = txt
						prevfinalHScore = finalHScore
					end
				end
			end
		end
		function API:StartScoreEstimator()
			prevText = ""
			curMod = self
			prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
			timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
			maxscore, ascore, hscore, aIncrease, hIncrease = 1600, 0, 0, 0, 0
			aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0

			self:RegisterEvent("UPDATE_UI_WIDGET", ScorePredictor)
		end
		function API:StartScoreEstimatorAB()
			prevText = ""
			curMod = self
			prevTime, prevAScore, prevHScore, prevAIncrease, prevHIncrease = 0, 0, 0, 0, 0
			timeBetweenEachTick, prevTick, prevTimeToWin = 0, 0, 0
			maxscore, ascore, hscore, aIncrease, hIncrease = 1600, 0, 0, 0, 0
			aRemain, hRemain, aTicksToWin, hTicksToWin = 0, 0, 0, 0
			aTime, hTime = 0, 0
			prevfinalAScore, prevfinalHScore = 0, 0

			self:RegisterEvent("UPDATE_UI_WIDGET", ScorePredictorAB)
		end
		function API:StopScoreEstimator()
			self:UnregisterEvent("UPDATE_UI_WIDGET")
		end
	end

	do
		local GetPOITextureCoords = C_Minimap.GetPOITextureCoords
		-- Easy world map icon checker
		--local start = function(self) self:StartMoving() end
		--local stop = function(self) self:StopMovingOrSizing() end
		--local frames = {}
		--do
		--	local f = CreateFrame("Frame", nil, UIParent)
		--	f:SetPoint("CENTER")
		--	f:SetSize(24,24)
		--	f:EnableMouse(true)
		--	f:SetMovable(true)
		--	f:RegisterForDrag("LeftButton")
		--	f:SetScript("OnDragStart", start)
		--	f:SetScript("OnDragStop", stop)
		--	frames[1] = f
		--	local tx = f:CreateTexture()
		--	tx:SetAllPoints(f)
		--	tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		--	tx:SetTexCoord(GetPOITextureCoords(1))
		--	local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		--	n:SetPoint("BOTTOM", f, "TOP")
		--	n:SetText(1)
		--end
		--for i = 2, 200 do
		--	local f = CreateFrame("Frame", nil, UIParent)
		--	f:SetPoint("LEFT", frames[i-1], "RIGHT", 10, 0)
		--	f:SetSize(24,24)
		--	f:EnableMouse(true)
		--	f:SetMovable(true)
		--	f:RegisterForDrag("LeftButton")
		--	f:SetScript("OnDragStart", start)
		--	f:SetScript("OnDragStop", stop)
		--	frames[i] = f
		--	local tx = f:CreateTexture()
		--	tx:SetAllPoints(f)
		--	tx:SetTexture(136441) -- Interface\\Minimap\\POIIcons
		--	tx:SetTexCoord(GetPOITextureCoords(i))
		--	local n = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		--	n:SetPoint("BOTTOM", f, "TOP")
		--	n:SetText(i)
		--end
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
			-- Market
			[208] = "colorAlliance",
			[209] = "colorHorde",
			-- Ruins
			[213] = "colorAlliance",
			[214] = "colorHorde",
			-- Shrine
			[218] = "colorAlliance",
			[219] = "colorHorde",
		}
		local atlasColors = nil
		local capTime = 0
		local curMapID = 0
		local curMod = nil
		local path = {136441}
		local GetIconData = function(icon)
			path[2], path[3], path[4], path[5] = GetPOITextureCoords(icon)
			return path
		end
		local landmarkCache = {}
		local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
		local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
		local GetAtlasInfo = C_Texture.GetAtlasInfo

		local function UpdatePOI()
			local pois = GetAreaPOIForMap(curMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(curMapID, pois[i])
				local name, icon, atlasName, areaPoiID = tbl.name, tbl.textureIndex, tbl.atlasName, tbl.areaPoiID
				if icon then
					if landmarkCache[name] ~= icon then
						landmarkCache[name] = icon
						if iconDataConflict[icon] then
							local bar = curMod:StartBar(name, capTime, GetIconData(icon), iconDataConflict[icon])
							bar:Set("capping:poiid", areaPoiID)
							if icon == 137 or icon == 139 then -- Workshop in IoC
								curMod:StopBar((GetSpellInfo(56661))) -- Build Siege Engine
							end
						else
							curMod:StopBar(name)
							if icon == 136 or icon == 138 then -- Workshop in IoC
								curMod:StartBar(GetSpellInfo(56661), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
							elseif icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
								-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
								local _, _, _, id = UnitPosition("player")
								if id == 30 or id == 628 or id == 2197 then -- Alterac Valley, IoC, Korrak's Revenge (WoW 15th)
									local bar = curMod:StartBar(name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
									bar:Pause()
									bar:SetTimeVisibility(false)
									bar:Set("capping:customchat", function() end)
								end
							end
						end
					end
				elseif atlasName then
					local atlasTbl = GetAtlasInfo(atlasName)
					if landmarkCache[name] ~= atlasName then
						--print(name, atlasName)
						landmarkCache[name] = atlasName
						if atlasColors[atlasName] then
							local bar = curMod:StartBar(
								name,
								capTime,
								{ -- Begin Icon Texture
									atlasTbl.file,
									atlasTbl.leftTexCoord,
									atlasTbl.rightTexCoord,
									atlasTbl.topTexCoord,
									atlasTbl.bottomTexCoord,
								}, -- End Icon Texture
								atlasColors[atlasName] -- Color
							)
							bar:Set("capping:poiid", areaPoiID)
							--if atlasName == WORKSHOPHORDE or atlasName == WORKSHOPALLIANCE then -- Workshop in IoC
							--	curMod:StopBar((GetSpellInfo(56661))) -- Build Siege Engine
							--end
						else
							curMod:StopBar(name)
							--if icon == 136 or icon == 138 then -- Workshop in IoC
							--	curMod:StartBar(GetSpellInfo(56661), 181, 252187, icon == 136 and "colorAlliance" or "colorHorde") -- Build Siege Engine, 252187 = ability_vehicle_siegeengineram
							--elseif icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
							--	-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
							--	local _, _, _, id = UnitPosition("player")
							--	if id == 30 or id == 628 then -- Alterac Valley, IoC
							--		local bar = curMod:StartBar(name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
							--		bar:Pause()
							--		bar:SetTimeVisibility(false)
							--		bar:Set("capping:customchat", function() end)
							--	end
							--end
						end
					end
				end
			end
		end

		function API:StartFlagCaptures(bgcaptime, uiMapID, colors)
			atlasColors = colors
			capTime = bgcaptime -- cap time
			curMapID = uiMapID -- current map
			landmarkCache = {}
			curMod = self
			local pois = GetAreaPOIForMap(uiMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(uiMapID, pois[i])
				local icon = tbl.textureIndex
				local atlasName = tbl.atlasName
				if icon then
					landmarkCache[tbl.name] = icon
					if icon == 2 or icon == 3 or icon == 151 or icon == 153 or icon == 18 or icon == 20 then
						-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
						local _, _, _, id = UnitPosition("player")
						if id == 30 or id == 628 or id == 2197 then -- Alterac Valley, IoC, Korrak's Revenge (WoW 15th)
							local bar = self:StartBar(tbl.name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
							bar:Pause()
							bar:SetTimeVisibility(false)
							bar:Set("capping:customchat", function() end)
						end
					end
				elseif atlasName then
					--local atlasTbl = GetAtlasInfo(atlasName)
					landmarkCache[tbl.name] = atlasName
					-- This can stay commented out until the day IoC/AV is converted to atlasNames
					--if atlasName == 2 or atlasName == 3 or atlasName == 151 or atlasName == 153 or atlasName == 18 or atlasName == 20 then
					--	-- Horde mine, Alliance mine, Alliance Refinery, Horde Refinery, Alliance Quarry, Horde Quarry
					--	local _, _, _, id = UnitPosition("player")
					--	if id == 30 or id == 628 then -- Alterac Valley, IoC
					--		local bar = self:StartBar(tbl.name, 3600, GetIconData(icon), (icon == 3 or icon == 151 or icon == 18) and "colorAlliance" or "colorHorde", true) -- Paused bar for mine status
					--		bar:Pause()
					--		bar:SetTimeVisibility(false)
					--		bar:Set("capping:customchat", function() end)
					--	end
					--end
				end
			end
			self:RegisterEvent("AREA_POIS_UPDATED", UpdatePOI)
		end

		function API:StopFlagCaptures()
			self:UnregisterEvent("AREA_POIS_UPDATED")
		end

		function API:RestoreFlagCaptures(uiMapID, inProgressDataTbl, maxBarTime)
			local pois = GetAreaPOIForMap(uiMapID)
			for i = 1, #pois do
				local tbl = GetAreaPOIInfo(uiMapID, pois[i])
				local name, icon, areaPoiID = tbl.name, tbl.textureIndex, tbl.areaPoiID
				local timer = inProgressDataTbl[areaPoiID]
				if timer and iconDataConflict[icon] then
					self:StartBar(name, timer, GetIconData(icon), iconDataConflict[icon], nil, maxBarTime)
				end
			end
		end
	end

	do
		local GetOptions = C_GossipInfo.GetOptions
		local SelectOption = C_GossipInfo.SelectOption
		function API:GetGossipNumOptions()
			local gossipOptions = GetOptions()
			return #gossipOptions
		end
		function API:GetGossipID(id)
			local gossipOptions = GetOptions()
			for i = 1, #gossipOptions do
				local gossipTable = gossipOptions[i]
				if gossipTable.gossipOptionID == id then
					return true
				end
			end
		end
		function API:SelectGossipID(id)
			SelectOption(id)
		end
	end

	do
		local GetAvailableQuests = C_GossipInfo.GetAvailableQuests
		local SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
		function API:GetGossipAvailableQuestID(id)
			local gossipOptions = GetAvailableQuests()
			for i = 1, #gossipOptions do
				local gossipTable = gossipOptions[i]
				if gossipTable.questID == id then
					return true
				end
			end
		end
		function API:SelectGossipAvailableQuestID(id)
			SelectAvailableQuest(id)
		end
	end

	function mod:NewMod()
		local t = {}
		for k,v in next, API do
			t[k] = v
		end
		return t, L, frame
	end
end

-- CORE
core = mod:NewMod()
function core:ADDON_LOADED(addon)
	if addon == addonName then
		self:UnregisterEvent("ADDON_LOADED")
		-- saved variables database setup
		local defaults = {
			profile = {
				lock = false,
				position = {"CENTER", "CENTER", 0, 0},
				fontSize = 10,
				barTexture = "Blizzard Raid Bar",
				outline = "NONE",
				monochrome = false,
				font = media:GetDefault("font"),
				width = 200,
				height = 20,
				icon = true,
				timeText = true,
				fill = false,
				growUp = false,
				spacing = 0,
				alignText = "LEFT",
				alignTime = "RIGHT",
				alignIcon = "LEFT",
				colorText = {1,1,1,1},
				colorAlliance = {0,0,1,1},
				colorHorde = {1,0,0,1},
				colorQueue = {0.6,0.6,0.6,1},
				colorOther = {1,1,0,1},
				colorBarBackground = {0,0,0,0.75},
				queueBars = true,
				useMasterForQueue = true,
				barOnShift = "SAY",
				barOnControl = "INSTANCE_CHAT",
				barOnAlt = "NONE",
				autoTurnIn = true,
			},
		}
		db = LibStub("AceDB-3.0"):New("CappingSettings", defaults, true)
		frame.db = db
		do
			local rl = function() ReloadUI() end
			db.RegisterCallback(self, "OnProfileChanged", rl)
			db.RegisterCallback(self, "OnProfileCopied", rl)
			db.RegisterCallback(self, "OnProfileReset", rl)
		end

		frame:ClearAllPoints()
		frame:SetPoint(db.profile.position[1], UIParent, db.profile.position[2], db.profile.position[3], db.profile.position[4])
		local bg = frame:CreateTexture()
		bg:SetAllPoints(frame)
		bg:SetColorTexture(0, 1, 0, 0.3)
		frame.bg = bg
		local header = frame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		header:SetAllPoints(frame)
		header:SetText(addon)
		frame.header = header

		if db.profile.lock then
			frame:EnableMouse(false)
			frame:SetMovable(false)
			frame.bg:Hide()
			frame.header:Hide()
		end

		-- Fix flag carriers for some people
		C_CVar.SetCVar("showArenaEnemyCastbar", "1")
		C_CVar.SetCVar("showArenaEnemyFrames", "1")
		C_CVar.SetCVar("showArenaEnemyPets", "1")

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end
core:RegisterEvent("ADDON_LOADED")

do
	local loc = GetLocale()
	local needsLocale = {
		--deDE = "German",
		--esES = "Spanish",
		--esMX = "Spanish MX",
		--itIT = "Italian",
		--koKR = "Korean",
		--zhTW = "zhTW",
	}
	if needsLocale[loc] then
		function core:LOADING_SCREEN_DISABLED()
			self:UnregisterEvent("LOADING_SCREEN_DISABLED")
			self:Timer(0, function() -- Timers aren't fully functional until 1 frame after loading is done
				self:Timer(15, function()
					print("|cFF33FF99Capping|r is missing locale for", needsLocale[loc], "and needs your help! Please visit the project page on GitHub for more info.")
				end)
			end)
		end
		core:RegisterEvent("LOADING_SCREEN_DISABLED")
	end
end

do
	local prevZone = 0
	local GetInstanceInfo = GetInstanceInfo
	function core:PLAYER_ENTERING_WORLD()
		local _, _, _, _, _, _, _, id = GetInstanceInfo()
		if zoneIds[id] then
			prevZone = id
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
			zoneIds[id]:EnterZone(id)
		end
	end
	function core:PLAYER_LEAVING_WORLD()
		self:UnregisterEvent("PLAYER_LEAVING_WORLD")
		self:StopAllBars()
		zoneIds[prevZone]:ExitZone()
	end
end

function core:Test(locale)
	core:StartBar(locale.queueBars, 100, 236396, "colorQueue") -- Interface/Icons/Achievement_BG_winWSG
	core:StartBar(locale.otherBars, 75, 132333, "colorOther") -- Interface/Icons/Ability_warrior_battleshout
	core:StartBar(locale.allianceBars, 45, 132486, "colorAlliance") -- Interface/Icons/INV_BannerPVP_02
	core:StartBar(locale.hordeBars, 25, 132485, "colorHorde") -- Interface/Icons/INV_BannerPVP_01
end
frame.Test = core.Test

-- OPTIONS
do
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:SetWidth(180)
	frame:SetHeight(15)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetClampedToScreen(true)
	frame:Show()
	local tooltip = CreateFrame("GameTooltip", "CappingTooltip", UIParent, "GameTooltipTemplate")
	frame:SetScript("OnEnter", function(f)
		tooltip:ClearLines()
		tooltip:SetOwner(f, db.profile.growUp and "ANCHOR_TOP" or "ANCHOR_BOTTOM")
		tooltip:AddLine(L.anchorTooltip, 0.2, 1, 0.2, 1)
		tooltip:AddLine(L.anchorTooltipNote, 1, 1, 1, 1)
		tooltip:Show()
	end)
	frame:SetScript("OnLeave", function() tooltip:Hide() end)
	frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
	frame:SetScript("OnDragStop", function(f)
		f:StopMovingOrSizing()
		local a, _, b, c, d = f:GetPoint()
		db.profile.position[1] = a
		db.profile.position[2] = b
		db.profile.position[3] = c
		db.profile.position[4] = d
	end)
	local function openOpts()
		EnableAddOn("Capping_Options") -- Make sure it wasn't left disabled for whatever reason
		LoadAddOn("Capping_Options")
		LibStub("AceConfigDialog-3.0"):Open(addonName)
	end
	SlashCmdList.Capping = openOpts
	SLASH_Capping1 = "/capping"
	frame:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			openOpts()
		end
	end)
end
