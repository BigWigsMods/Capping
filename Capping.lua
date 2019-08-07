
local addonName, mod = ...
local frame = CreateFrame("Frame", "CappingFrame", UIParent)
local L = mod.L

local format, type = format, type
local db

local activeBars = { }
frame.bars = activeBars

-- LIBRARIES
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")

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

-- Event Handlers
local elist = {}
frame:SetScript("OnEvent", function(_, event, ...)
	mod[elist[event] or event](mod, ...)
end)
function mod:RegisterTempEvent(event, other)
	frame:RegisterEvent(event)
	elist[event] = other or event
end
function mod:RegisterEvent(event)
	frame:RegisterEvent(event)
end
function mod:UnregisterEvent(event)
	frame:UnregisterEvent(event)
end

function mod:START_TIMER(_, timeSeconds)
	local _, t = GetInstanceInfo()
	if t == "pvp" or t == "arena" or t == "scenario" then
		for i = 1, #TimerTracker.timerList do
			TimerTracker.timerList[i].bar:Hide() -- Hide the Blizz start timer
		end

		local faction = GetPlayerFactionGroup()
		if faction and faction ~= "Neutral" then
			local bar = self:GetBar(L.battleBegins)
			if not bar or timeSeconds > bar.remaining+3 or timeSeconds < bar.remaining-3 then -- Don't restart bars for subtle changes +/- 3s
				-- 132485 = Interface/Icons/INV_BannerPVP_01 || 132486 = Interface/Icons/INV_BannerPVP_02
				mod:StartBar(L.battleBegins, timeSeconds, faction == "Horde" and 132485 or 132486, "colorOther")
			end
		end
	end
end

function mod:PLAYER_LOGIN()
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
	header:SetText(addonName)
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

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("START_TIMER")
	self:ZONE_CHANGED_NEW_AREA()
end
mod:RegisterEvent("PLAYER_LOGIN")

do
	local zoneIds = {}
	function mod:AddBG(id, func)
		zoneIds[id] = func
	end

	local wasInBG = false
	local GetBestMapForUnit = C_Map.GetBestMapForUnit
	function mod:ZONE_CHANGED_NEW_AREA()
		if wasInBG then
			wasInBG = false
			for event in pairs(elist) do -- unregister all temp events
				elist[event] = nil
				self:UnregisterEvent(event)
			end
			for bar in next, activeBars do -- stop all bars
				bar:Stop()
			end
			self:UPDATE_BATTLEFIELD_STATUS(1) -- restore queue bars
		end

		local _, zoneType, _, _, _, _, _, id = GetInstanceInfo()
		if zoneType == "pvp" then
			local func = zoneIds[id]
			if func then
				for bar in next, activeBars do -- stop all bars
					bar:Stop()
				end
				wasInBG = true
				func(self)
			end
		elseif zoneType == "arena" then
			local func = zoneIds[id]
			if func then
				for bar in next, activeBars do -- stop all bars
					bar:Stop()
				end
				wasInBG = true
				func(self)
			else
				print(format("Capping found a new id '%d' at '%s' tell us on GitHub.", id, GetRealZoneText(id)))
			end
		else
			local id = -(GetBestMapForUnit("player") or 0)
			local func = zoneIds[id]
			if func then
				wasInBG = true
				func(self)
			end
		end
	end
end

do -- estimated wait timer and port timer
	local GetBattlefieldStatus = GetBattlefieldStatus
	local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
	local GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited = GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited
	local ARENA = ARENA

	local function cleanupQueue()
		for bar in next, activeBars do
			-- If we joined two queues, join and finish the first BG, zone out and they shuffle upwards so queue 2 becomes queue 1.
			-- We check every running bar to cancel any that might have changed to a different queue slot and left the bar in the previous slot running.
			-- This is only an issue for casual arenas where we change the name to be unique. The "Arena 2" bar will start an "Arena 1" bar, leaving behind the previous.
			-- This isn't an issue anywhere else as they all have unique names (e.g. Warsong Gultch) that we don't modify.
			-- If a WSG bar went from queue 2 to queue 1 another bar wouldn't spawn, we just update the queue id of the bar.
			--
			-- This messyness is purely down to Blizzard calling both casual arenas the same name... which would screw with our bars if we were queued for both at the same time.
			local id = bar:Get("capping:queueid")
			if id and GetBattlefieldStatus(id) == "none" then
				bar:Stop()
			end
		end
	end

	function mod:UPDATE_BATTLEFIELD_STATUS(queueId)
		local status, map, _, _, _, size = GetBattlefieldStatus(queueId)

		if size == "ARENASKIRMISH" then
			map = format("%s (%d)", ARENA, queueId) -- No size or name distinction given for casual arena 2v2/3v3, separate them manually. Messy :(
		end

		if status == "confirm" then -- BG has popped, time until cancelled
			local bar = self:GetBar(map)
			if bar and bar:Get("capping:colorid") == "colorQueue" then
				self:StopBar(map)
				bar = nil
			end

			if not bar then
				bar = self:StartBar(map, GetBattlefieldPortExpiration(queueId), 132327, "colorOther", true) -- 132327 = Interface/Icons/Ability_TownWatch
				bar:Set("capping:queueid", queueId)
			end

			if db.profile.useMasterForQueue then
				local _, id = PlaySound(8459, "Master", false) -- SOUNDKIT.PVP_THROUGH_QUEUE
				if id then
					StopSound(id-1) -- Should work most of the time to stop the blizz sound
				end
			end
		elseif status == "queued" and map and db.profile.queueBars then -- Waiting for BG to pop
			local _, zoneType = GetInstanceInfo()
			if zoneType == "pvp" or zoneType == "arena" then
				return -- Hide queue bars in pvp/arena
			end

			if size == "ARENASKIRMISH" then
				cleanupQueue()
			end

			local esttime = GetBattlefieldEstimatedWaitTime(queueId) / 1000 -- 0 when queue is paused
			local waited = GetBattlefieldTimeWaited(queueId) / 1000
			local estremain = esttime - waited
			local bar = self:GetBar(map)
			if bar and bar:Get("capping:queueid") ~= queueId then
				bar:Set("capping:queueid", queueId) -- The queues shuffle upwards after finishing a BG, update
			end

			if estremain > 1 then -- Not a paused queue (0) and not a negative queue (in queue longer than estimated time).
				if not bar or estremain > bar.remaining+10 or estremain < bar.remaining-10 then -- Don't restart bars for subtle changes +/- 10s
					local icon
					for i = 1, GetNumBattlegroundTypes() do
						local name,_,_,_,_,_,_,_,_,bgIcon = GetBattlegroundInfo(i)
						if name == map then
							icon = bgIcon
							break
						end
					end
					bar = self:StartBar(map, estremain, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					bar:Set("capping:queueid", queueId)
				end
			else -- Negative queue (in queue longer than estimated time) or 0 queue (paused)
				if not bar or bar.remaining ~= 1 then
					local icon
					for i = 1, GetNumBattlegroundTypes() do
						local name,_,_,_,_,_,_,_,_,bgIcon = GetBattlegroundInfo(i)
						if name == map then
							icon = bgIcon
							break
						end
					end
					bar = self:StartBar(map, 1, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					bar:Pause()
					bar.remaining = 1
					bar:SetTimeVisibility(false)
					bar:Set("capping:queueid", queueId)
				end
			end
		elseif status == "none" then -- Leaving queue
			cleanupQueue()
		end
	end
end

function mod:Test(locale)
	mod:StartBar(locale.queueBars, 100, 236396, "colorQueue") -- Interface/Icons/Achievement_BG_winWSG
	mod:StartBar(locale.otherBars, 75, 1582141, "colorOther") -- Interface/Icons/Achievement_PVP_Legion03
	mod:StartBar(locale.allianceBars, 45, 132486, "colorAlliance") -- Interface/Icons/INV_BannerPVP_02
	mod:StartBar(locale.hordeBars, 25, 132485, "colorHorde") -- Interface/Icons/INV_BannerPVP_01
end
frame.Test = mod.Test

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
				local msg = custom()
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

	function mod:StartBar(name, remaining, icon, colorid, priority, maxBarTime)
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

	function mod:StopBar(text)
		local dirty = nil
		for bar in next, activeBars do
			if bar:GetLabel() == text then
				bar:Stop()
				dirty = true
			end
		end
		if dirty then RearrangeBars() end
	end

	candy.RegisterCallback(mod, "LibCandyBar_Stop", function(_, bar)
		if activeBars[bar] then
			activeBars[bar] = nil
			RearrangeBars()
		end
	end)
end

function mod:GetBar(text)
	for bar in next, activeBars do
		if bar:GetLabel() == text then
			return bar
		end
	end
end

