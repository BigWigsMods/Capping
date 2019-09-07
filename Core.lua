
-- LOCALS
local addonName, mod = ...
local frame = CreateFrame("Frame", "CappingFrame", UIParent)
local L = mod.L

local format, type = format, type
local db
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
			local tmp = {}
			RearrangeBars = function()
				wipe(tmp)
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
					v(event, ...)
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
		--local unitTable1 = {
		--	"target", "targettarget",
		--	"mouseover", "mouseovertarget",
		--	"focus", "focustarget",
		--	"nameplate1", "nameplate2", "nameplate3", "nameplate4", "nameplate5", "nameplate6", "nameplate7", "nameplate8", "nameplate9", "nameplate10",
		--	"nameplate11", "nameplate12", "nameplate13", "nameplate14", "nameplate15", "nameplate16", "nameplate17", "nameplate18", "nameplate19", "nameplate20",
		--	"nameplate21", "nameplate22", "nameplate23", "nameplate24", "nameplate25", "nameplate26", "nameplate27", "nameplate28", "nameplate29", "nameplate30",
		--	"nameplate31", "nameplate32", "nameplate33", "nameplate34", "nameplate35", "nameplate36", "nameplate37", "nameplate38", "nameplate39", "nameplate40",
		--}
		--local unitTable2 = {
		--	"nameplate1target", "nameplate2target", "nameplate3target", "nameplate4target", "nameplate5target",
		--	"nameplate6target", "nameplate7target", "nameplate8target", "nameplate9target", "nameplate10target",
		--	"nameplate11target", "nameplate12target", "nameplate13target", "nameplate14target", "nameplate15target",
		--	"nameplate16target", "nameplate17target", "nameplate18target", "nameplate19target", "nameplate20target",
		--	"nameplate21target", "nameplate22target", "nameplate23target", "nameplate24target", "nameplate25target",
		--	"nameplate26target", "nameplate27target", "nameplate28target", "nameplate29target", "nameplate30target",
		--	"nameplate31target", "nameplate32target", "nameplate33target", "nameplate34target", "nameplate35target",
		--	"nameplate36target", "nameplate37target", "nameplate38target", "nameplate39target", "nameplate40target",
		--}
		--local unitTable3 = {
		--	"raid1target", "raid2target", "raid3target", "raid4target", "raid5target",
		--	"raid6target", "raid7target", "raid8target", "raid9target", "raid10target",
		--	"raid11target", "raid12target", "raid13target", "raid14target", "raid15target",
		--	"raid16target", "raid17target", "raid18target", "raid19target", "raid20target",
		--	"raid21target", "raid22target", "raid23target", "raid24target", "raid25target",
		--	"raid26target", "raid27target", "raid28target", "raid29target", "raid30target",
		--	"raid31target", "raid32target", "raid33target", "raid34target", "raid35target",
		--	"raid36target", "raid37target", "raid38target", "raid39target", "raid40target"
		--}
		--local collection, reset, blocked, started = {}, {}, {}, false
		--local count1, count2, count3 = #unitTable1, #unitTable2, #unitTable3
		--local UnitGUID, strsplit = UnitGUID, strsplit
		--
		--local function parse2()
		--	for i = 1, count2 do
		--		local unit = unitTable2[i]
		--		local guid = UnitGUID(unit)
		--		if guid then
		--			local _, _, _, _, _, strid = strsplit("-", guid)
		--			if strid and collection[strid] and not blocked[strid] then
		--				blocked[strid] = true
		--				local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
		--				SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
		--			end
		--		end
		--	end
		--end
		--local function parse3()
		--	for i = 1, count3 do
		--		local unit = unitTable3[i]
		--		local guid = UnitGUID(unit)
		--		if guid then
		--			local _, _, _, _, _, strid = strsplit("-", guid)
		--			if strid and collection[strid] and not blocked[strid] then
		--				blocked[strid] = true
		--				local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
		--				SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
		--			end
		--		end
		--	end
		--end
		--local function HealthScan()
		--	local _, _, _, id = UnitPosition("player")
		--	if id == 30 or id == 628 then -- Alterac Valley, IoC
		--		Timer(1, HealthScan)
		--		Timer(0.1, parse2) -- Break up parsing
		--		Timer(0.2, parse3)
		--	else
		--		started = false
		--		collection, reset = {}, {}
		--		return
		--	end
		--
		--	for id, counter in next, reset do
		--		reset[id] = counter + 1
		--		if counter > 20 then
		--			local tbl = collection[id]:Get("capping:hpdata")
		--			collection[id]:Stop()
		--			reset[id] = nil
		--			collection[id] = tbl
		--		end
		--	end
		--
		--	blocked = {}
		--	for i = 1, count1 do
		--		local unit = unitTable1[i]
		--		local guid = UnitGUID(unit)
		--		if guid then
		--			local _, _, _, _, _, strid = strsplit("-", guid)
		--			if strid and collection[strid] and not blocked[strid] then
		--				blocked[strid] = true
		--				local hp = UnitHealth(unit) / UnitHealthMax(unit) * 100
		--				SendAddonMessage("Capping", format("%s:%.1f", strid, hp), "INSTANCE_CHAT")
		--			end
		--		end
		--	end
		--end
		--
		--function API:SetupHealthCheck(npcId, npcName, englishName, icon, color)
		--	collection[npcId] = {npcName, englishName, icon, color}
		--	if not started then
		--		started = true
		--		C_ChatInfo.RegisterAddonMessagePrefix("Capping")
		--		mod:RegisterTempEvent("CHAT_MSG_ADDON", "HealthUpdate")
		--		Timer(1, HealthScan)
		--	end
		--end
		--
		--function mod:HealthUpdate(prefix, msg, channel)
		--	if prefix == "Capping" and channel == "INSTANCE_CHAT" then
		--		local strid, strhp = strsplit(":", msg)
		--		local hp = tonumber(strhp)
		--		if strid and hp and collection[strid] and hp < 100.1 and hp > 0 then
		--			if collection[strid].candyBarBar then
		--				if hp < 100 then
		--					reset[strid] = 0
		--				end
		--				collection[strid].candyBarBar:SetValue(hp)
		--				collection[strid].candyBarDuration:SetFormattedText("%.1f%%", hp)
		--			elseif hp < 100 then
		--				local tbl = collection[strid]
		--				local bar = mod:StartBar(tbl[1], 100, tbl[3], tbl[4], true)
		--				bar:Pause()
		--				bar.candyBarBar:SetValue(hp)
		--				bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
		--				bar:Set("capping:customchat", function(bar)
		--					if tbl[1] ~= tbl[2] then
		--						return tbl[2] .."/".. tbl[1] .." - ".. bar.candyBarDuration:GetText()
		--					else
		--						return tbl[1] .." - ".. bar.candyBarDuration:GetText()
		--					end
		--				end)
		--				bar:Set("capping:hpdata", tbl)
		--				reset[strid] = 0
		--				collection[strid] = bar
		--			end
		--		end
		--	end
		--end
	end

	do
		local mods = {}
		function mod:NewMod(name)
			local t = {}
			for k,v in next, API do
				t[k] = v
			end
			mods[name] = t
			return t, L, frame
		end
	end
end

-- CORE
local core = mod:NewMod("Core")
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
			},
		}
		db = LibStub("AceDB-3.0"):New("CappingSettings", defaults, true)
		CappingFrame.db = db

		frame:ClearAllPoints()
		frame:SetPoint(db.profile.position[1], UIParent, db.profile.position[2], db.profile.position[3], db.profile.position[4])
		local bg = frame:CreateTexture(nil, "PARENT")
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

		self:Timer(15, function()
			local x = GetLocale()
			if x ~= "enUS" and x ~= "enGB" then -- XXX temp
				print("|cFF33FF99Capping|r is missing locale for", x, "and needs your help! Please visit the project page on GitHub for more info.")
			end
		end)
	end
end
core:RegisterEvent("ADDON_LOADED")

do
	local prevZone = 0
	local GetInstanceInfo = GetInstanceInfo
	function core:PLAYER_ENTERING_WORLD()
		local _, _, _, _, _, _, _, id = GetInstanceInfo()
		if zoneIds[id] then
			prevZone = id
			zoneIds[id]:EnterZone()
		else
			if zoneIds[prevZone] then
				self:StopAllBars()
				zoneIds[prevZone]:ExitZone()
			end
			prevZone = id
		end
	end
end

function core:Test(locale)
	core:StartBar(locale.queueBars, 100, 236396, "colorQueue") -- Interface/Icons/Achievement_BG_winWSG
	core:StartBar(locale.otherBars, 75, 1582141, "colorOther") -- Interface/Icons/Achievement_PVP_Legion03
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
