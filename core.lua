
local addonName, Capping = ...

-- HEADER
local anchor = CreateFrame("Button", "CappingAnchor", UIParent)
local L = Capping.L

-- LIBRARIES
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
media:Register("statusbar", "BantoBarReverse", "Interface\\AddOns\\Capping\\BantoBarReverse")

-- GLOBALS MADE LOCAL
local _G = getfenv(0)
local format, strmatch, strlower, type = format, strmatch, strlower, type
local min, floor, math_sin, math_pi, tonumber = min, floor, math.sin, math.pi, tonumber
local GetTime, time = GetTime, time

-- LOCAL VARS
local db, wasInBG, bgmap, bgtab
local activeBars, bars, bgdd = { }, { }, { }
local av, ab, eots, wsg, winter, ioc = GetMapNameByID(401), GetMapNameByID(461), GetMapNameByID(813), GetMapNameByID(443), GetMapNameByID(501), GetMapNameByID(540)
local narrowed, borderhidden, ACountText, HCountText
Capping.backdrop = { bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", }

function Capping:RegisterEvent(event)
	anchor:RegisterEvent(event)
end
function Capping:UnregisterEvent(event)
	anchor:UnregisterEvent(event)
end

-- EVENT HANDLERS
local elist, clist = {}, {}
anchor:SetScript("OnEvent", function(frame, event, ...)
	Capping[elist[event] or event](Capping, ...)
end)
function Capping:RegisterTempEvent(event, other)
	self:RegisterEvent(event)
	elist[event] = other or event
end
function Capping:CheckCombat(func) -- check combat for secure functions
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		tinsert(clist, func)
	else
		func(self)
	end
end
function Capping:PLAYER_REGEN_ENABLED() -- run queue when combat ends
	for k, v in ipairs(clist) do
		v(self)
	end
	wipe(clist)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

-- LOCAL FUNCS
local ShowOptions
local nofunc = function() end
local function ToggleAnchor()
	if anchor:IsShown() then
		anchor:Hide()
	else
		anchor:Show()
	end
end
local function SetPoints(this, lp, lrt, lrp, lx, ly, rp, rrt, rrp, rx, ry)
	this:ClearAllPoints()
	this:SetPoint(lp, lrt, lrp, lx, ly)
	if rp then this:SetPoint(rp, rrt, rrp, rx, ry) end
end
local function SetWH(this, w, h)
	this:SetWidth(w)
	this:SetHeight(h)
end
local function NewText(parent, font, fontsize, justifyH, justifyV, overlay)
	local t = parent:CreateFontString(nil, overlay or "OVERLAY")
	if fontsize then
		t:SetFont(font, fontsize)
		t:SetShadowColor(0, 0, 0)
		t:SetShadowOffset(1, -1)
	else
		t:SetFontObject(font)
	end
	t:SetJustifyH(justifyH)
	t:SetJustifyV(justifyV)
	return t
end

local function StartWorldTimers()
	-- GetNumWorldPVPAreas() = 3
	-- 1) Wintergrasp, 2) Tol Barad, 3) Ashran (not timed)
	for i = 1, 2 do
		local _, localizedName, isActive, _, startTime = GetWorldPVPAreaInfo(i)
		if localizedName then
			db["worldname"..i] = localizedName
		end
		if db["world"..i] then
			if startTime < 1 or isActive then
				Capping:StopBar(localizedName)
			elseif startTime > 0 then
				local bar = Capping:GetBar(localizedName)
				local prevColor = bar and bar:Get("capping:colorid") -- Force refresh the bar if we have capture data
				local color
				if not bar or prevColor == "info1" then
					local currentmapid = GetCurrentMapAreaID()
					SetMapByID((i == 2 and 708) or 501)
					local _, _, ti, _, _ = GetMapLandmarkInfo(1)
					if ti == 46 then
						color = "alliance"
					elseif ti == 48 then
						color = "horde"
					else
						color = "info1"
					end
					SetMapByID(currentmapid)
					if color ~= "info1" then
						bar = nil
						prevColor = color
					end
				end

				if not bar or startTime > bar.remaining+5 or startTime < bar.remaining-5 then -- Don't restart bars for subtle changes +/- 5s
					local icon = i == 1 and "Interface\\Icons\\INV_EssenceOfWintergrasp" or "Interface\\Icons\\achievement_zone_tolbarad"
					bar = Capping:StartBar(localizedName, startTime, icon, prevColor or color, true)
					--bar:Set("capping:onexpire", func)
				end
			end
		else
			Capping:StopBar(localizedName)
		end
	end
end

local function StartMoving(this) this:StartMoving() end
local function CreateMover(oldframe, w, h, dragstopfunc)
	local mover = oldframe or CreateFrame("Button", nil, UIParent)
	SetWH(mover, w, h)
	mover:SetBackdrop(Capping.backdrop)
	mover:SetBackdropColor(0, 0, 0, 0.7)
	mover:SetMovable(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", StartMoving)
	mover:SetScript("OnDragStop", dragstopfunc)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover.close = CreateFrame("Button", nil, mover, "UIPanelCloseButton")
	SetWH(mover.close, 20, 20)
	mover.close:SetPoint("TOPRIGHT", 5, 5)
	return mover
end
--hooksecurefunc(WorldStateAlwaysUpFrame, "SetPoint", function()
--	if not db or not db.sbx then return end
--	oSetPoint(WorldStateAlwaysUpFrame, "TOP", UIParent, "TOPLEFT", db.sbx, db.sby)
--end)
--local function wsaufu()
--	if not db or not db.cbx then return end
--	local nexty = 0
--	for i = 1, NUM_EXTENDED_UI_FRAMES do
--		local cb = _G["WorldStateCaptureBar"..i]
--		if cb and cb:IsShown() then
--			cb:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", db.cbx, db.cby - nexty)
--			nexty = nexty + cb:GetHeight()
--		end
--	end
--end
--hooksecurefunc("WorldStateAlwaysUpFrame_Update", wsaufu)
--hooksecurefunc(VehicleSeatIndicator, "SetPoint", function()
--	if not db or not db.seatx then return end
--	oSetPoint(VehicleSeatIndicator, "TOPRIGHT", UIParent, "BOTTOMLEFT", db.seatx, db.seaty)
--end)
local function UpdateZoneMapVisibility()
	if (not bgmap or not bgmap:IsShown()) and GetCVar("showBattlefieldMinimap") ~= "0" then
		if not bgmap then
			LoadAddOn("Blizzard_BattlefieldMinimap")
		end
		bgmap:Show()
	end
end
--hooksecurefunc("WorldMapZoneMinimapDropDown_OnClick", function()
--	if GetMapInfo() == "LakeWintergrasp" or GetMapInfo() == "TolBarad" then
--		UpdateZoneMapVisibility()
--	end
--end)
--TimerTracker:HookScript("OnEvent", function(this, event, timerType, timeSeconds, totalTime)
--	if not db or not wasInBG then return end
--	if db.hideblizztime then
--		for a, timer in pairs(this.timerList) do
--			timer.time = nil
--			timer.type = nil
--			timer.isFree = nil
--			timer:SetScript("OnUpdate", nil)
--			timer.fadeBarOut:Stop()
--			timer.fadeBarIn:Stop()
--			timer.startNumbers:Stop()
--			timer.bar:SetAlpha(0)
--		end
--	end
--	if not db.hidecaptime and event == "START_TIMER" then
--		Capping:StartBar(L["Battle Begins"], timeSeconds+3, "Interface\\Icons\\Spell_Holy_PrayerOfHealing", "info2")
--	end
--end)
function Capping:START_TIMER(timerType, timeSeconds, totalTime)
	local _, t = GetInstanceInfo()
	if t == "pvp" or t == "arena" then
		if db.hideblizztime then
			for a, timer in pairs(TimerTracker.timerList) do
				timer:Hide()
			end
		end
		local faction = GetPlayerFactionGroup()
		if faction and faction ~= "Neutral" then
			local bar = self:GetBar(L["Battle Begins"])
			if not bar or timeSeconds > bar.remaining+3 or timeSeconds < bar.remaining-3 then -- Don't restart bars for subtle changes +/- 3s
				Capping:StartBar(L["Battle Begins"], timeSeconds, "Interface\\Timer\\"..faction.."-Logo", "info2")
			end
		end
	end
end
Capping:RegisterEvent("START_TIMER")


Capping:RegisterEvent("ADDON_LOADED")
---------------------------------
function Capping:ADDON_LOADED(a1)
---------------------------------
	if a1 ~= addonName then return end

	-- saved variables database setup
	CappingDB = CappingDB or {}
	db = CappingCharDB or (CappingDB.profiles and CappingDB.profiles.Default) or CappingDB
	self.db = db
	if db.dbinit ~= 7 then
		db.dbinit = 7
		db.winter = nil
		local function SetDefaults(db, t)
			for k, v in pairs(t) do
				if type(db[k]) == "table" then
					SetDefaults(db[k], v)
				else
					db[k] = (db[k] ~= nil and db[k]) or v
				end
			end
		end
		SetDefaults(db, {
			av = true, avquest = true, ab = true, wsg = true, arena = true, eots = true, ioc = true,
			world2 = true, world3 = true,
			port = true, wait = true,
			mapscale = 1.3, narrow = true, hidemapborder = false,
			texture = "BantoBarReverse",
			width = 200, height = 15, inset = 0, spacing = 1,
			mainup = false, reverse = false, fill = false,
			iconpos = "<-", timepos = "<-",
			font = "Friz Quadrata TT", fontsize = 10,
			colors = {
				alliance = { r=0.0, g=0.0, b=1.0, a=1.0, },
				horde = { r=1.0, g=0.0, b=0.0, a=1.0, },
				info1 = { r=0.6, g=0.6, b=0.6, a=1.0, },
				info2 = { r=1.0, g=1.0, b=0.0, a=1.0, },
				font = { r=1, g=1, b=1, a=1, },
			},
		})
	end
	db.colors.spark = db.colors.spark or { r=1, g=1, b=1, a=1, }
	SlashCmdList.CAPPING = ShowOptions
	SLASH_CAPPING1 = "/capping"

	-- adds Capping config to default UI Interface Options
	--local panel = CreateFrame("Frame", "CappingOptionsPanel", UIParent)
	--panel.name = "Capping"
	--panel:SetScript("OnShow", function(this)
	--	local t1 = NewText(this, GameFontNormalLarge, nil, "LEFT", "TOP", "ARTWORK")
	--	t1:SetPoint("TOPLEFT", 16, -16)
	--	t1:SetText(this.name)
    --
	--	local t2 = NewText(this, GameFontHighlightSmall, nil, "LEFT", "TOP", "ARTWORK")
	--	t2:SetHeight(43)
	--	SetPoints(t2, "TOPLEFT", t1, "BOTTOMLEFT", 0, -8, "RIGHT", this, "RIGHT", -32, 0)
	--	t2:SetNonSpaceWrap(true)
	--	local function GetInfo(field)
	--		return GetAddOnMetadata("Capping", field) or "N/A"
	--	end
	--	t2:SetFormattedText("Notes: %s\nAuthor: %s\nVersion: %s", GetInfo("Notes"), GetInfo("Author"), GetInfo("Version"))
    --
	--	local b = CreateFrame("Button", nil, this, "UIPanelButtonTemplate")
	--	SetWH(b, 120, 20)
	--	b:SetText(_G.GAMEOPTIONS_MENU)
	--	b:SetScript("OnClick", ShowOptions)
	--	b:SetPoint("TOPLEFT", t2, "BOTTOMLEFT", -2, -8)
	--	this:SetScript("OnShow", nil)
	--end)
	--InterfaceOptions_AddCategory(panel)

	-- anchor frame
	anchor:Hide()
	if db.x then
		anchor:SetPoint(db.p or "TOPLEFT", UIParent, db.rp or "TOPLEFT", db.x, db.y)
	else
		anchor:SetPoint("CENTER", UIParent, "CENTER", 200, -100)
	end
	CreateMover(anchor, db.width, 10, function(this)
		this:StopMovingOrSizing()
		local a,b,c,d,e = this:GetPoint()
		db.p, db.rp, db.x, db.y = a, c, floor(d + 0.5), floor(e + 0.5)
	end)
	anchor:RegisterForClicks("RightButtonUp")
	anchor:SetScript("OnClick", ShowOptions)
	anchor:SetNormalFontObject(GameFontHighlightSmall)
	anchor:SetText("Capping")


	--if db.sbx then WorldStateAlwaysUpFrame:SetPoint("TOP") end -- world state info frame positioning
	--if db.cbx then wsaufu() end -- capturebar position
	--if db.seatx then VehicleSeatIndicator:SetPoint("TOPRIGHT") end -- vehicle seat position

	local regal = false
	if BattlefieldMinimap then -- battlefield minimap setup
		self:InitBGMap()
	else
		regal = true
	end
	if PVPUIFrame then
		PVPUIFrame:HookScript("OnShow", StartWorldTimers)
	else
		regal = true
	end
	if regal then
		function Capping:ADDON_LOADED(a1)
			if a1 == "Blizzard_BattlefieldMinimap" then
				self:InitBGMap()
			elseif a1 == "Blizzard_PVPUI" then
				PVPUIFrame:HookScript("OnShow", StartWorldTimers)
				if BattlefieldMinimap then
					self:UnregisterEvent("ADDON_LOADED")
					self.ADDON_LOADED = nofunc
				end
			end
		end
	end

	if IsLoggedIn() then
		self:PLAYER_ENTERING_WORLD()
	else
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end

----------------------------
function Capping:InitBGMap()
----------------------------
	bgmap, bgtab = BattlefieldMinimap, BattlefieldMinimapTab
	if not db.disablemap then
		bgdd.notCheckable, bgdd.text, bgdd.func = 1, "Capping", ShowOptions
		--hooksecurefunc("BattlefieldMinimapTabDropDown_Initialize", function() UIDropDownMenu_AddButton(bgdd, 1) end)
		self:ModMap()
		self.InitBGMap = nil
		if PVPUIFrame then
			self:UnregisterEvent("ADDON_LOADED")
			self.ADDON_LOADED = nofunc
		end
	end
end

----------------------------------------
function Capping:PLAYER_ENTERING_WORLD()
----------------------------------------
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:ZONE_CHANGED_NEW_AREA()

	--RegisterAddonMessagePrefix("cap")

	self.PLAYER_ENTERING_WORLD = nil
end

local tohide = { }
local function HideProtectedStuff()
	for _, v in ipairs(tohide) do
		v:Hide()
	end
end
--------------------------------------
function Capping:AddFrameToHide(frame) -- secure frames that are hidden upon zone change
--------------------------------------
	tinsert(tohide, frame)
end
---------------------------
function Capping:ResetAll() -- reset all timers and unregister temp events
---------------------------
	wasInBG = false
	for event in pairs(elist) do -- unregister all temp events
		elist[event] = nil
		self:UnregisterEvent(event)
	end
	for bar in next, activeBars do -- close all temp timerbars
		local separate = bar:Get("capping:separate")
		if not separate then
			bar:Stop()
		end
	end
	self:CheckCombat(HideProtectedStuff) -- hide secure frames
	if ACountText then ACountText:SetText("") end
	if HCountText then HCountText:SetText("") end
end

do
	local zoneIds = {}
	function Capping:AddBG(id, func)
		zoneIds[id] = func
	end

	function Capping:ZONE_CHANGED_NEW_AREA()
		if wasInBG then
			self:ResetAll()
		end

		local _, zoneType, _, _, _, _, _, id = GetInstanceInfo()
		--print(id)
		--print(GetZonePVPInfo())
		if zoneType == "pvp" then
			local func = zoneIds[id]
			if func then
				wasInBG = true
				func(self)
			end

			if not self.bgtotals then -- frame to display roster count
				self.bgtotals = CreateFrame("Frame", nil, AlwaysUpFrame1)
				self.bgtotals:SetScript("OnUpdate", function(this, elapsed)
					this.elapsed = (this.elapsed or 0) + elapsed
					if this.elapsed < 4 then return end
					this.elapsed = 0
					RequestBattlefieldScoreData()
				end)
				self:AddFrameToHide(self.bgtotals)
			end
			self.bgtotals:Show()

			self:RegisterTempEvent("UPDATE_BATTLEFIELD_SCORE", "UpdateCountText")
			RequestBattlefieldScoreData()

			UpdateZoneMapVisibility()
		elseif zoneType == "arena" then
			local func = zoneIds[id]
			if func then
				wasInBG = true
				func(self)
			end

			if bgmap and bgmap:IsShown() and GetCVar("showBattlefieldMinimap") ~= "2" then
				bgmap:Hide()
			end
		else
			if GetZonePVPInfo() == "combat" then
				SetMapToCurrentZone()
				local z = GetMapInfo()
				local func = zoneIds[z]
				if func then
					wasInBG = true
					func(self)
					UpdateZoneMapVisibility()
				else
					if bgmap and bgmap:IsShown() and GetCVar("showBattlefieldMinimap") ~= "2" then
						bgmap:Hide()
					end
				end
			elseif id == 732 then -- Tol Barad, can't use GetZonePVPInfo, but it has it's own id!
				wasInBG = true
				UpdateZoneMapVisibility()
			else
				if bgmap and bgmap:IsShown() and GetCVar("showBattlefieldMinimap") ~= "2" then
					bgmap:Hide()
				end
			end
		end
		StartWorldTimers()
		self:ModMap()
	end
end

--------------------------------
function Capping:ModMap(disable) -- alter the default minimap
--------------------------------
	if not bgmap or db.disablemap then return end
	bgmap:SetScale(db.mapscale)
	local _, zoneType = IsInInstance()
	disable = zoneType ~= "pvp" or disable

	if db.narrow and not narrowed and not disable then -- narrow setting
		BattlefieldMinimap1:Hide() BattlefieldMinimap4:Hide() BattlefieldMinimap5:Hide()
		BattlefieldMinimap8:Hide() BattlefieldMinimap9:Hide() BattlefieldMinimap12:Hide()
		BattlefieldMinimapBackground:SetWidth(256 / 2)
		BattlefieldMinimapBackground:SetPoint("TOPLEFT", -12 + 64, 12)
		BattlefieldMinimapCorner:SetPoint("TOPRIGHT", -2 - 52, 3 + 1)
		SetWH(BattlefieldMinimapCorner, 24, 24)
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", bgmap, "TOPRIGHT", 2 - 53, 7)
		SetWH(BattlefieldMinimapCloseButton, 24, 24)
		narrowed = 1
	elseif disable or (not db.narrow and narrowed) then -- setting things back to blizz's default
		BattlefieldMinimap1:Show() BattlefieldMinimap4:Show() BattlefieldMinimap5:Show()
		BattlefieldMinimap8:Show() BattlefieldMinimap9:Show() BattlefieldMinimap12:Show()
		BattlefieldMinimapBackground:SetWidth(256)
		BattlefieldMinimapBackground:SetPoint("TOPLEFT", -12, 12)
		BattlefieldMinimapCorner:SetPoint("TOPRIGHT", -2, 3)
		SetWH(BattlefieldMinimapCorner, 32, 32)
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", bgmap, "TOPRIGHT", 2, 7)
		SetWH(BattlefieldMinimapCloseButton, 32, 32)
		narrowed = nil
	end

	if db.hidemapborder and not borderhidden then -- Hide border
		BattlefieldMinimapBackground:Hide()
		BattlefieldMinimapCorner:Hide()
		BattlefieldMinimapCloseButton:SetParent(bgtab)
		BattlefieldMinimapCloseButton:SetScale(db.mapscale)
		BattlefieldMinimapCloseButton:HookScript("OnClick", function() bgmap:Hide() end)
		borderhidden = true
	elseif not db.hidemapborder and borderhidden then -- Show border
		BattlefieldMinimapBackground:Show()
		BattlefieldMinimapCorner:Show()
		BattlefieldMinimapCloseButton:SetParent(bgmap)
		BattlefieldMinimapCloseButton:SetScale(1)
		borderhidden = nil
	end
	bgmap:SetPoint("TOPLEFT", bgtab, "BOTTOMLEFT", (narrowed and -64) or 0, (borderhidden and 0) or -5)
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

	function Capping:UPDATE_BATTLEFIELD_STATUS(queueId)
		if not db.port and not db.wait then return end

		local status, map, _, _, _, size = GetBattlefieldStatus(queueId)
		if size == "ARENASKIRMISH" then
			map = ("%s (%d)"):format(ARENA, queueId) -- No size or name distinction given for casual arena 2v2/3v3, separate them manually. Messy :(
		end

		if status == "confirm" then -- BG has popped, time until cancelled
			local bar = self:GetBar(map)
			if bar and bar:Get("capping:colorid") == "info1" then
				self:StopBar(map)
				bar = nil
			end

			if not bar and db.port then
				bar = self:StartBar(map, GetBattlefieldPortExpiration(queueId), "Interface\\Icons\\Ability_TownWatch", "info2", true)
				bar:Set("capping:queueid", queueId)
			end
		elseif status == "queued" and db.wait then -- Waiting for BG to pop
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
					bar = self:StartBar(map, estremain, icon or "Interface\\Icons\\inv_misc_questionmark", "info1", true) -- Question mark icon for random battleground
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
					bar = self:StartBar(map, 1, icon or "Interface\\Icons\\inv_misc_questionmark", "info1", true) -- Question mark icon for random battleground
					bar:Pause()
					bar.remaining = 1
					bar:SetTimeVisibility(false)
					bar:Set("capping:queueid", queueId)
				end
			end
		elseif status == "active" then -- Inside BG
			self:StopBar(map)
		elseif status == "none" then -- Leaving queue
			cleanupQueue()
		end
	end
end

local function ReportBar(bar, channel)
	if not activeBars[bar] then return end
	local colorid = bar:Get("capping:colorid")
	local faction = colorid == "horde" and _G.FACTION_HORDE or colorid == "alliance" and _G.FACTION_ALLIANCE or ""
	local timeLeft = bar.candyBarDuration:GetText()
	if not timeLeft:find("[:%.]") then timeLeft = "0:"..timeLeft end
	SendChatMessage(format("Capping: %s - %s %s", bar:GetLabel(), timeLeft, faction == "" and faction or "("..faction..")"), channel)
end
local function BarOnClick(bar, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ReportBar(bar, "SAY")
		elseif IsControlKeyDown() then
			ReportBar(bar, IsInGroup(2) and "INSTANCE_CHAT" or "RAID") -- LE_PARTY_CATEGORY_INSTANCE = 2
		else
			ToggleAnchor()
		end
	elseif button == "RightButton" then
		if IsControlKeyDown() then
			bar:Stop()
		else
			ShowOptions(nil, bar)
		end
	end
end

local function SetDepleteValue(this, remain, duration)
	this.bar:SetValue( (remain > 0 and remain or 0.0001) / duration )
end
local function SetFillValue(this, remain, duration)
	this.bar:SetValue( ((remain > 0 and duration - remain) or duration) / duration )
end
--local function BarOnUpdate(this, a1)
--	this.elapsed = this.elapsed + a1
--	if this.elapsed < this.throt then return end
--	this.elapsed = 0
--
--	local remain = this.endtime - GetTime()
--	this.remaining = remain
--
--	this:SetValue(remain, this.duration)
--	this.pfunction(remain)
--	if remain < 60 then
--		if remain < 10 then -- fade effects
--			if remain > 0.5 then
--				this:SetAlpha(0.75 + 0.25 * math_sin(remain * math_pi))
--			elseif remain > -1.5 then
--				this:SetAlpha((remain + 1.5) * 0.5)
--			elseif this.noclose then
--				if remain < -this.noclose then
--					Capping:StopBar(nil, this)
--				else
--					this:SetAlpha(0.7)
--					this.throt = 10
--				end
--				this.endfunction()
--				return
--			else
--				this.endfunction()
--				return Capping:StopBar(nil, this)
--			end
--			this.throt = 0.05
--		end
--		this.timetext:SetFormattedText("%d", remain < 0 and 0 or remain)
--	elseif remain < 600 then
--		this.timetext:SetFormattedText("%d:%02d", remain * stamin, remain % 60)
--	elseif remain < 3600 then
--		this.timetext:SetFormattedText("%dm", remain * stamin)
--	else
--		this.timetext:SetFormattedText("|cffaaaaaa%d:%02d|r", remain / 3600, remain % 3600 * stamin)
--	end
--end

--local function SetValue(this, frac)
--	frac = (frac < 0.0001 and 0.0001) or (frac > 1 and 1) or frac
--	this:SetWidth(frac * this.basevalue)
--	this:SetTexCoord(0, frac, 0, 1)
--end
--local function SetReverseValue(this, frac)
--	frac = (frac < 0.0001 and 0.0001) or (frac > 1 and 1) or frac
--	this:SetWidth(frac * this.basevalue)
--	this:SetTexCoord(frac, 0, 0, 1)
--end
--local function UpdateBarLayout(f)
--	local inset, w, h, tc = db.inset or 0, db.width or 200, db.height or 12, db.colors.font
--	local icon, bar, barback, spark, timetext, displaytext = f.icon, f.bar, f.barback, f.spark, f.timetext, f.displaytext
--	local nh = h * (db.altstyle and 0.25 or 1)
--	local ih = nh - 2 * inset
--	ih = ih > 0 and ih or 0.5
--	SetWH(f, w, h)
--	SetWH(icon, h, h)
--	SetWH(barback, w - h, nh)
--	bar:SetHeight(ih)
--	spark:SetHeight(2.35 * ih)
--	spark:SetVertexColor(db.colors.spark.r, db.colors.spark.g, db.colors.spark.b, db.colors.spark.a)
--	timetext:SetTextColor(tc.r, tc.g, tc.b, tc.a)
--	displaytext:SetTextColor(tc.r, tc.g, tc.b, tc.a)
--	f.SetValue = db.fill and SetFillValue or SetDepleteValue
--	if db.iconpos == "X" then -- icon position
--		icon:Hide()
--		barback:SetWidth(w)
--		SetPoints(barback, "BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
--	elseif db.iconpos == "->" then
--		icon:Show()
--		SetPoints(icon, "RIGHT", f, "RIGHT", 0, 0)
--		SetPoints(barback, "BOTTOMRIGHT", icon, "BOTTOMLEFT", 0, 0)
--	else
--		icon:Show()
--		SetPoints(icon, "LEFT", f, "LEFT", 0, 0)
--		SetPoints(barback, "BOTTOMLEFT", icon, "BOTTOMRIGHT", 0, 0)
--	end
--	if db.timepos == "->" then -- time text placement
--		SetPoints(timetext, "RIGHT", barback, "RIGHT", -(4 + inset), db.altstyle and (0.5 * h) or 0)
--		SetPoints(displaytext, "LEFT", barback, "LEFT", (4 + inset), db.altstyle and (0.5 * h) or 0, "RIGHT", timetext, "LEFT", -(4 + inset), 0)
--	else
--		SetPoints(displaytext, "LEFT", barback, "LEFT", db.fontsize * 3, db.altstyle and (0.5 * h) or 0, "RIGHT", barback, "RIGHT", -(4 + inset), 0)
--		SetPoints(timetext, "RIGHT", displaytext, "LEFT", -db.fontsize / 2.2, 0)
--	end
--	if db.reverse then -- horizontal flip of bar growth
--		SetPoints(bar, "RIGHT", barback, "RIGHT", -inset, 0)
--		spark:SetPoint("CENTER", bar, "LEFT", 0, 0)
--		bar.SetValue = SetReverseValue
--	else
--		SetPoints(bar, "LEFT", barback, "LEFT", inset, 0)
--		spark:SetPoint("CENTER", bar, "RIGHT", 0, 0)
--		bar.SetValue = SetValue
--	end
--	f:EnableMouse(not db.lockbar)
--	bar.basevalue = (w - h) - (2 * inset)
--	if f:IsShown() then
--		BarOnUpdate(f, 11)
--	end
--end

do
	local temp = { }
	local function lsort(a, b)
		return a.remaining < b.remaining
	end
	local function SortBars()
		wipe(temp)
		for k in next, activeBars do
			temp[#temp+1] = k
		end
		sort(temp, lsort)
		local pdown, pup = nil, nil
		for i = 1, #temp do
			local bar = temp[i]
			local separate = bar:Get("capping:separate")
			bar:ClearAllPoints()
			if separate then
				bar:SetPoint("BOTTOMLEFT", pup or anchor, "TOPLEFT", 0, db.spacing or 1)
				pup = bar
			else
				bar:SetPoint("TOPLEFT", pdown or anchor, "BOTTOMLEFT", 0, -(db.spacing or 1))
				pdown = bar
			end
		end
	end
	function Capping:StartBar(name, remaining, icon, colorid, separate)
		--print("Capping:", tostringall(name, remaining, icon, colorid, separate))
		self:StopBar(name)
		local bar = candy:New(media:Fetch("statusbar", db.texture), db.width, db.height)
		activeBars[bar] = true
		bar:Set("capping:separate", not db.onegroup and separate)
		bar:Set("capping:colorid", colorid)
		local c = colorid and db.colors[colorid] or db.colors.info1
		bar.candyBarBackground:SetVertexColor(c.r * 0.3, c.g * 0.3, c.b * 0.3, db.bgalpha or 0.7)
		bar:SetColor(c.r, c.g, c.b, c.a or 0.9)
		--bar.candyBarLabel:SetTextColor(colors:GetColor("barText", module, key))
		--bar.candyBarDuration:SetTextColor(colors:GetColor("barText", module, key))
		--bar.candyBarLabel:SetShadowColor(colors:GetColor("barTextShadow", module, key))
		--bar.candyBarDuration:SetShadowColor(colors:GetColor("barTextShadow", module, key))
		bar.candyBarLabel:SetJustifyH("LEFT")

		--local flags = nil
		--if db.monochrome and db.outline ~= "NONE" then
		--	flags = "MONOCHROME," .. db.outline
		--elseif db.monochrome then
		--	flags = nil -- "MONOCHROME", XXX monochrome only is disabled for now as it causes a client crash
		--elseif db.outline ~= "NONE" then
		--	flags = db.outline
		--end
		local font = media:Fetch("font", db.font)
		bar.candyBarLabel:SetFont(font, db.fontsize)
		bar.candyBarDuration:SetFont(font, db.fontsize)

		bar:SetLabel(name)
		bar:SetDuration(remaining)
		--bar:SetTimeVisibility(db.time)
		if type(icon) == "table" then
			bar:SetIcon(icon[1], icon[2], icon[3], icon[4], icon[5])
		else
			bar:SetIcon(icon)
		end
		bar:SetScript("OnMouseUp", BarOnClick)
		--bar:SetScale(db.scale)
		bar:SetFill(db.fill)
		bar:Start()
		SortBars()
		return bar
	end

	function Capping:GetBar(text)
		for bar in next, activeBars do
			if bar:GetLabel() == text then
				return bar
			end
		end
	end

	function Capping:StopBar(text)
		local dirty = nil
		for bar in next, activeBars do
			if bar:GetLabel() == text then
				bar:Stop()
				dirty = true
			end
		end
		if dirty then SortBars() end
	end

	candy.RegisterCallback(Capping, "LibCandyBar_Stop", function(event, bar)
		if activeBars[bar] then
			activeBars[bar] = nil
			SortBars()
		end
	end)
end

local GetBattlefieldScore, GetNumBattlefieldScores = GetBattlefieldScore, GetNumBattlefieldScores
----------------------------------
function Capping:UpdateCountText() -- roster counts
----------------------------------
	if not AlwaysUpFrame2 then return end
	local na, nh
	for i = 1, GetNumBattlefieldScores(), 1 do
		local _, _, _, _, _, ifaction = GetBattlefieldScore(i)
		if ifaction == 0 then
			nh = (nh or 0) + 1
		elseif ifaction == 1 then
			na = (na or 0) + 1
		end
	end
	ACountText = ACountText or self:CreateText(AlwaysUpFrame1, 10, "CENTER", AlwaysUpFrame1Icon, 3, 2, AlwaysUpFrame1Icon, -19, 16)
	HCountText = HCountText or self:CreateText(AlwaysUpFrame2, 10, "CENTER", AlwaysUpFrame2Icon, 3, 2, AlwaysUpFrame2Icon, -19, 16)
	ACountText:SetText(na or "")
	HCountText:SetText(nh or "")

	local offset = ((not AlwaysUpFrame1Icon:GetTexture() or AlwaysUpFrame1Icon:GetTexture() == "") and 1) or 0
	SetPoints(ACountText, "TOPLEFT", _G["AlwaysUpFrame"..(1 + offset).."Icon"], "TOPLEFT", 3, 2, "BOTTOMRIGHT", _G["AlwaysUpFrame"..(1 + offset).."Icon"], "BOTTOMRIGHT", -19, 16)
	SetPoints(HCountText, "TOPLEFT", _G["AlwaysUpFrame"..(2 + offset).."Icon"], "TOPLEFT", 3, 2, "BOTTOMRIGHT", _G["AlwaysUpFrame"..(2 + offset).."Icon"], "BOTTOMRIGHT", -19, 16)
end

---------------------------------------------------------------------------------------
function Capping:CreateText(parent, fontsize, justifyH, tlrp, tlx, tly, brrp, brx, bry) -- create common text fontstring
---------------------------------------------------------------------------------------
	local text = NewText(parent, GameFontNormal:GetFont(), fontsize, justifyH, "CENTER")
	SetPoints(text, "TOPLEFT", tlrp, "TOPLEFT", tlx, tly, "BOTTOMRIGHT", brrp, "BOTTOMRIGHT", brx, bry)
	text:SetShadowColor(0,0,0)
	text:SetShadowOffset(-1, -1)
	return text
end

local CappingDD, barid, Exec
function ShowOptions(a1, id)
	barid = type(id) == "number" and id
	if not CappingDD then
		CappingDD = CreateFrame("Frame", "CappingDD", CappingAnchor)
		CappingDD.displayMode = "MENU"
		local info = { }
		local abbrv = { av = av, ab = ab, eots = eots, wsg = wsg, winter = winter, ioc = ioc, }
		local offsetvalue, offsetcount, lastb
		local sbmover, cbmover, seatmover
		local function UpdateLook(k)
			local texture = media:Fetch("statusbar", db.texture)
			local font = media:Fetch("font", db.font)
			local fc = db.colors.font
			anchor:SetWidth(db.width)
			for bar in next, activeBars do
				bar:SetTexture(texture)
				bar.candyBarLabel:SetFont(font, db.fontsize)
				bar.candyBarDuration:SetFont(font, db.fontsize-1)
				bar:SetHeight(db.height)
				--if k == "colors" or k == "bgalpha" then
				--	local bc = db.colors[f.color]
				--	bar:SetVertexColor(bc.r, bc.g, bc.b, bc.a or 1)
					--f.barback:SetVertexColor(bc.r * 0.3, bc.g * 0.3, bc.b * 0.3, db.bgalpha or 0.7)
				--end
				--if k == "mainup" then f.down = not f.down end
				--if k == "onegroup" and db.onegroup then f.down = not db.mainup end
				--UpdateBarLayout(f)
			end
			Capping:ModMap()
		end
		local function HideCheck(b)
			if b and b.GetName and _G[b:GetName().."Check"] then
				_G[b:GetName().."Check"]:Hide()
			end
		end
		local function CloseMenu(b)
			if not b or not b:GetParent() then return end
			CloseDropDownMenus(b:GetParent():GetID())
		end
		hooksecurefunc("ToggleDropDownMenu", function(_, _, _, _, _, _, _, prev) lastb = prev end)
		Exec = function(b, k, value)
			if b then HideCheck(b) end
			if k == "showoptions" then CloseMenu(b) ShowOptions()
			elseif k == "anchor" then ToggleAnchor()
			elseif k == "syncav" and GetRealZoneText() == av then Capping:SyncAV()
			elseif k == "reportbg" then CloseMenu(b) ReportBar(value, "INSTANCE_CHAT")
			elseif k == "reportsay" then CloseMenu(b) ReportBar(value, "SAY")
			elseif k == "enterbattle" then
			elseif k == "canceltimer" then CloseMenu(b) if value and activeBars[value] then value:Stop() end
			elseif (k == "less" or k == "more") and lastb then
				local off = (k == "less" and -8) or 8
				if offsetvalue == value then
					offsetcount = offsetcount + off
				else
					offsetvalue, offsetcount = value, off
				end
				local tb = _G[gsub(lastb:GetName(), "ExpandArrow", "")]
				CloseMenu(b)
				ToggleDropDownMenu(b:GetParent():GetID(), tb.value, nil, nil, nil, nil, tb.menuList, tb)
			elseif k == "test" then
				local testicon = "Interface\\Icons\\Ability_ThunderBolt"
				Capping:StartBar(L["Test"].." - ".._G.OTHER.."1", 100, testicon, "info1", true)
				Capping:StartBar(L["Test"].." - ".._G.OTHER.."2", 75, testicon, "info2", true)
				Capping:StartBar(L["Test"].." - ".._G.FACTION_ALLIANCE, 45, testicon, "alliance")
				Capping:StartBar(L["Test"].." - ".._G.FACTION_HORDE, 100, testicon, "horde")
				Capping:StartBar(L["Test"], 75, testicon, "info2")
			--elseif k == "movesb" then
			--	sbmover = sbmover or CreateMover(nil, 220, 48, function(this)
			--		this:StopMovingOrSizing()
			--		db.sbx, db.sby = floor(this:GetLeft() + 50.5), floor(this:GetTop() - GetScreenHeight() + 10.5)
			--		WorldStateAlwaysUpFrame:SetPoint("TOP")
			--	end)
			--	sbmover:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", WorldStateAlwaysUpFrame:GetLeft() - 50, WorldStateAlwaysUpFrame:GetTop() - 10)
			--	sbmover:Show()
			--elseif k == "movecb" then
			--	cbmover = cbmover or CreateMover(nil, 173, 27, function(this)
			--		this:StopMovingOrSizing()
			--		db.cbx, db.cby = floor(this:GetRight() + 0.5), floor(this:GetTop() + 0.5)
			--		wsaufu()
			--	end)
			--	local x, y = db.cbx or max(0, MinimapCluster:GetRight() - CONTAINER_OFFSET_X), db.cby or max(20, MinimapCluster:GetBottom())
			--	cbmover:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
			--	cbmover:Show()
			--elseif k == "moveseat" then
			--	seatmover = seatmover or CreateMover(nil, 128, 128, function(this)
			--		this:StopMovingOrSizing()
			--		db.seatx, db.seaty = floor(this:GetRight() + 0.5), floor(this:GetTop() + 0.5)
			--		VehicleSeatIndicator:SetPoint("TOPRIGHT")
			--	end)
			--	seatmover:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", VehicleSeatIndicator:GetRight(), VehicleSeatIndicator:GetTop())
			--	seatmover:Show()
			elseif k == "resetmap" and bgtab then
				bgtab:ClearAllPoints()
				bgtab:SetPoint("CENTER")
			elseif k == "resetall" and IsShiftKeyDown() then
				CappingDB = nil
				ReloadUI()
			end
		end
		local function Set(b, k)
			if not k then return end
			db[k] = not db[k]
			if abbrv[k] then -- enable/disable a battleground while in it
				if GetRealZoneText() == abbrv[k] then
					Capping:ZONE_CHANGED_NEW_AREA()
				end
			elseif k == "perchar" then
				if CappingCharDB then
					CappingCharDB = nil
				else
					CappingCharDB = db
				end
				ReloadUI()
			elseif k == "disablemap" then
				ReloadUI()
			else -- update visual options
				StartWorldTimers()
				UpdateLook(k)
			end
		end
		local function SetSelect(b, a1)
			db[a1] = tonumber(b.value) or b.value
			local level, num = strmatch(b:GetName(), "DropDownList(%d+)Button(%d+)")
			level, num = tonumber(level) or 0, tonumber(num) or 0
			for i = 1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
				local b = _G["DropDownList"..level.."Button"..i.."Check"]
				if b then
					b[i == num and "Show" or "Hide"](b)
				end
			end
			UpdateLook(a1)
		end
		local function SetColor(a1)
			local dbc = db.colors[UIDROPDOWNMENU_MENU_VALUE]
			if not dbc then return end
			if a1 then
				local pv = ColorPickerFrame.previousValues
				dbc.r, dbc.g, dbc.b, dbc.a = pv.r, pv.g, pv.b, 1 - pv.opacity
			else
				dbc.r, dbc.g, dbc.b = ColorPickerFrame:GetColorRGB()
				dbc.a = 1 - OpacitySliderFrame:GetValue()
			end
			UpdateLook("colors")
		end
		local function AddButton(lvl, text, keepshown)
			info.text = text
			info.keepShownOnClick = keepshown
			UIDropDownMenu_AddButton(info, lvl)
			wipe(info)
		end
		local function AddToggle(lvl, text, value)
			info.arg1 = value
			info.func = Set
			if value == "perchar" then
				info.checked = CappingCharDB and true
			else
				info.checked = db[value]
			end
			info.isNotRadio = true
			AddButton(lvl, text, 1)
		end
		local function AddExecute(lvl, text, arg1, arg2)
			info.arg1 = arg1
			info.arg2 = arg2
			info.func = Exec
			info.notCheckable = 1
			AddButton(lvl, text, 1)
		end
		local function AddColor(lvl, text, value)
			local dbc = db.colors[value]
			if not dbc then return end
			info.hasColorSwatch = true
			info.hasOpacity = 1
			info.r, info.g, info.b, info.opacity = dbc.r, dbc.g, dbc.b, 1 - dbc.a
			info.swatchFunc, info.opacityFunc, info.cancelFunc = SetColor, SetColor, SetColor
			info.value = value
			info.notCheckable = 1
			info.func = UIDropDownMenuButton_OpenColorPicker
			AddButton(lvl, text, nil)
		end
		local function AddList(lvl, text, value)
			info.value = value
			info.hasArrow = true
			info.func = HideCheck
			info.notCheckable = 1
			AddButton(lvl, text, 1)
		end
		local function AddSelect(lvl, text, arg1, value)
			info.arg1 = arg1
			info.func = SetSelect
			info.value = value
			if tonumber(value) and tonumber(db[arg1] or "blah") then
				if floor(100 * tonumber(value)) == floor(100 * tonumber(db[arg1])) then
					info.checked = true
				end
			else
				info.checked = (db[arg1] == value)
			end
			AddButton(lvl, text, 1)
		end
		local function AddFakeSlider(lvl, value, minv, maxv, step, tbl)
			local cvalue = 0
			local dbv = db[value]
			if type(dbv) == "string" and tbl then
				for i, v in ipairs(tbl) do
					if dbv == v then
						cvalue = i
						break
					end
				end
			else
				cvalue = dbv or ((maxv - minv) / 2)
			end
			local adj = (offsetvalue == value and offsetcount) or 0
			local starti = max(minv, cvalue - (7 - adj) * step)
			local endi = min(maxv, cvalue + (8 + adj) * step)
			if starti == minv then
				endi = min(maxv, starti + 16 * step)
			elseif endi == maxv then
				starti = max(minv, endi - 16 * step)
			end
			if starti > minv then
				AddExecute(lvl, "--", "less", value)
			end
			if tbl then
				for i = starti, endi, step do
					AddSelect(lvl, tbl[i], value, tbl[i])
				end
			else
				local fstring = (step >= 1 and "%d") or (step >= 0.1 and "%.1f") or "%.2f"
				for i = starti, endi, step do
					AddSelect(lvl, format(fstring, i), value, i)
				end
			end
			if endi < maxv then
				AddExecute(lvl, "++", "more", value)
			end
		end
		CappingDD.initialize = function(this, lvl)
			if lvl == 1 then
				if type(barid) == "number" then
					local bname = bars[barid].name
					info.isTitle = true
					info.notCheckable = 1
					AddButton(lvl, bname)
					if bname == winter then
						AddExecute(lvl, L["Cancel Timer"], "canceltimer", barid)
					elseif not activeBars[bname] then
	
					else
						AddExecute(lvl, L["Send to BG"], "reportbg", barid)
						AddExecute(lvl, L["Send to SAY"], "reportsay", barid)
						AddExecute(lvl, L["Cancel Timer"], "canceltimer", barid)
					end
	
					info.isTitle = true
					info.notCheckable = 1
					AddButton(lvl, " ")
					AddExecute(lvl, _G.GAMEOPTIONS_MENU, "showoptions")
				else
					info.isTitle = true
					info.notCheckable = 1
					AddButton(lvl, "|cff5555ffCapping|r")
					AddList(lvl, _G.BATTLEFIELDS, "battlegrounds")
					AddList(lvl, L["Bar"], "bars")
					AddList(lvl, _G.BATTLEFIELD_MINIMAP, "bgmap")
					AddList(lvl, _G.OTHER, "other")
					AddExecute(lvl, L["Show/Hide Anchor"], "anchor")
				end
			elseif lvl == 2 then
				local sub = UIDROPDOWNMENU_MENU_VALUE
				if sub == "battlegrounds" then
					AddToggle(lvl, av, "av")
					AddToggle(lvl, " -"..L["Auto Quest Turnins"], "avquest")
					AddExecute(lvl, " -"..L["Request Sync"], "syncav")
					AddToggle(lvl, ab, "ab")
					AddToggle(lvl, eots, "eots")
					AddToggle(lvl, ioc, "ioc")
					AddToggle(lvl, wsg, "wsg")
					AddToggle(lvl, db.worldname1 or (_G.CHANNEL_CATEGORY_WORLD.." 1"), "world1")
					AddToggle(lvl, db.worldname2 or (_G.CHANNEL_CATEGORY_WORLD.." 2"), "world2")
					AddToggle(lvl, db.worldname3 or (_G.CHANNEL_CATEGORY_WORLD.." 3"), "world3")
				elseif sub == "bars" then
					AddList(lvl, L["Texture"], "texture")
					AddList(lvl, L["Width"], "width")
					AddList(lvl, L["Height"], "height")
					AddList(lvl, L["Border Width"], "inset")
					AddList(lvl, L["Spacing"], "spacing")
					AddList(lvl, _G.EMBLEM_SYMBOL or "Icon", "iconpos")
					AddList(lvl, L["Font"], "font")
					AddList(lvl, _G.FONT_SIZE, "fontsize")
					AddList(lvl, L["Time Position"], "timepos")
					AddList(lvl, _G.COLORS, "color")
					AddList(lvl, _G.BACKGROUND.." ".._G.OPACITY, "bgalpha")
					AddList(lvl, _G.OTHER, "more")
					AddExecute(lvl, L["Test"], "test")
				elseif sub == "bgmap" then
					AddToggle(lvl, (_G.DISABLE or "Disable").." "..(_G.ACHIEVEMENTFRAME_FILTER_ALL or "All"), "disablemap")
					AddToggle(lvl, L["Narrow Map Mode"], "narrow")
					AddToggle(lvl, L["Hide Border"], "hidemapborder")
					AddList(lvl, L["Map Scale"], "mapscale")
					AddExecute(lvl, _G.RESET or "Reset", "resetmap")
				elseif sub == "other" then
					AddToggle(lvl, L["Port Timer"], "port")
					AddToggle(lvl, L["Wait Timer"], "wait")
					AddExecute(lvl, L["Move Scoreboard"], "movesb")
					AddExecute(lvl, L["Move Capture Bar"], "movecb")
					AddExecute(lvl, L["Move Vehicle Seat"], "moveseat")
					AddToggle(lvl, L["Hide Capping Start Time"], "hidecaptime")
					AddToggle(lvl, L["Hide Blizzard Start Timer"], "hideblizztime")
					AddToggle(lvl, _G.CHARACTER.." ".._G.SAVE, "perchar")
					AddExecute(lvl, _G.RESET_TO_DEFAULT.." (".._G.SHIFT_KEY_TEXT..")", "resetall")
				end
			elseif lvl == 3 then
				local sub = UIDROPDOWNMENU_MENU_VALUE
				if sub == "texture" or sub == "font" then
					local t = media:List(sub == "texture" and "statusbar" or sub)
					AddFakeSlider(lvl, sub, 1, #t, 1, t)
				elseif sub == "more" then
					AddToggle(lvl, _G.OTHER.." "..L["Bar"], "altstyle")
					AddToggle(lvl, L["Fill Grow"], "fill")
					AddToggle(lvl, L["Fill Right"], "reverse")
					AddToggle(lvl, L["Flip Growth"], "mainup")
					AddToggle(lvl, L["Single Group"], "onegroup")
					AddToggle(lvl, _G.MAKE_UNINTERACTABLE or _G.LOCK, "lockbar")
				elseif sub == "width" then
					AddFakeSlider(lvl, sub, 20, 600, 2, nil)
				elseif sub == "height" then
					AddFakeSlider(lvl, sub, 2, 100, 1, nil)
				elseif sub == "inset" then
					AddFakeSlider(lvl, sub, 0, 8, 1, nil)
				elseif sub == "iconpos" then
					AddSelect(lvl, "<-", sub, "<-")
					AddSelect(lvl, "->", sub, "->")
					AddSelect(lvl, "X", sub, "X")
				elseif sub == "spacing" then
					AddFakeSlider(lvl, sub, 0, 10, 1, nil)
				elseif sub == "fontsize" then
					AddFakeSlider(lvl, sub, 4, 28, 1, nil)
				elseif sub == "timepos" then
					AddSelect(lvl, "<-", sub, "<-")
					AddSelect(lvl, "->", sub, "->")
				elseif sub == "color" then
					AddColor(lvl, _G.FACTION_ALLIANCE, "alliance")
					AddColor(lvl, _G.FACTION_HORDE, "horde")
					AddColor(lvl, _G.OTHER.."1", "info1")
					AddColor(lvl, _G.OTHER.."2", "info2")
					AddColor(lvl, L["Font"], "font")
					AddColor(lvl, "Spark", "spark")
				elseif sub == "bgalpha" then
					AddFakeSlider(lvl, sub, 0, 1, 0.1, nil)
				elseif sub == "mapscale" then
					AddFakeSlider(lvl, sub, 0.2, 5, 0.05, nil)
				end
			end
		end
	end -- end if not CappingDD then
	ToggleDropDownMenu(1, nil, CappingDD, "cursor")
end
