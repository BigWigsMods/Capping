
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo

local wallTextures = {}
local poiWallNames = { -- wall section locations
	[6048] = L.northWest, [6049] = L.northWest, [6050] = L.northWest, [6051] = L.northWest,
	[6047] = L.southWest, [6046] = L.southWest,
	[6045] = L.south, [6043] = L.south,
	[6042] = L.southEast, [6041] = L.southEast,
	[6040] = L.northEast, [6039] = L.northEast, [6038] = L.northEast, [6037] = L.northEast,
	[6034] = L.innerWest, [6035] = L.innerWest, [6036] = L.innerWest,
	[6033] = L.innerSouth, [6032] = L.innerSouth, [6031] = L.innerSouth,
	[6030] = L.innerEast, [6029] = L.innerEast, [6028] = L.innerEast,
	[6056] = L.southGate, [6027] = L.mainEntrance, -- front gate and fortress door
}
local baseTowerHealth, mainEntranceHealth, wallHealth, defenseTowerHealth = 130000, 91000, 301000, 81000
local westHp, midHp, eastHp = baseTowerHealth, baseTowerHealth, baseTowerHealth
local towers, onDemandTrackers = {}, {}
local towerNames = {
	["308062"] = L.westTower, -- Shadowsight Tower (West)
	["308013"] = L.southTower, -- Winter's Edge Tower (Mid)
	["307935"] = L.eastTower, -- Flamewatch Tower (East)
}

do
	local defensiveTowers = {
		["307877"] = L.northEastKeep,
		["307936"] = L.southEastKeep,
		["307878"] = L.northWestKeep,
		["307894"] = L.southWestKeep,
	}
	local objectWallNames = {
		["308077"] = L.northWest, -- 1
		["307922"] = L.northWest, -- 2
		["307937"] = L.northWest, -- 3
		["307907"] = L.northWest, -- 4
		["308035"] = L.southWest, -- 1
		["307897"] = L.southWest, -- 2
		["307898"] = L.south, -- 1
		["307893"] = L.southGate,
		["307899"] = L.south, -- 2
		["307879"] = L.southEast, -- 1
		["307896"] = L.southEast, -- 2
		["307927"] = L.northEast, -- 1
		["307919"] = L.northEast, -- 2
		["307867"] = L.northEast, -- 3
		["308083"] = L.northEast, -- 4
		["307963"] = L.innerWest, -- 1
		["308078"] = L.innerWest, -- 2
		["307908"] = L.innerWest, -- 3
		["307941"] = L.innerSouth, -- 1
		["307925"] = L.innerSouth, -- 2
		["307916"] = L.innerSouth, -- 3
		["307938"] = L.innerEast, -- 1
		["307840"] = L.innerEast, -- 2
		["307870"] = L.innerEast, -- 3
	}

	local function StartNewBar(self, name, english, icon)
		local tbl = GetAreaPOIInfo(1334, 6027) -- Main entrance POI
		local color = "colorAlliance"
		if tbl and tbl.textureIndex == 77 then -- If main entrance is horde texture
			color = "colorHorde"
		end
		local bar = self:StartBar(name, 100, icon, color, true) -- Interface/Icons/inv_essenceofwintergrasp
		bar:Pause()
		bar.candyBarBar:SetValue(100)
		bar.candyBarDuration:SetText("100%")
		bar:Set("capping:customchat", function(bar)
			if name ~= english then
				return english .."/".. name .." - ".. bar.candyBarDuration:GetText()
			else
				return name .." - ".. bar.candyBarDuration:GetText()
			end
		end)
		return bar
	end

	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	function mod:COMBAT_LOG_EVENT_UNFILTERED()
		local _, event, _, _, _, _, _, destGUID, _, _, _, _, _, _, amount = CombatLogGetCurrentEventInfo()
		if event == "SPELL_BUILDING_DAMAGE" then
			local _, _, _, _, _, strid = strsplit("-", destGUID)
			if towers[strid] then
				local newHp = towers[strid] - amount
				towers[strid] = newHp
				local bar = mod:GetBar(towerNames[strid])
				if bar then
					local hp = newHp / baseTowerHealth * 100
					if hp < 0.5 then
						bar:Stop()
					else
						bar.candyBarBar:SetValue(hp)
						bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
					end
				end
			elseif objectWallNames[strid] then
				if not onDemandTrackers[strid] then
					onDemandTrackers[strid] = wallHealth
				end
				local newHp = onDemandTrackers[strid] - amount
				onDemandTrackers[strid] = newHp
				local hp = newHp / wallHealth * 100
				if hp < 80 then
					local bar = mod:GetBar(objectWallNames[strid])
					if not bar then
						bar = StartNewBar(self, objectWallNames[strid], objectWallNames[strid], 134456)
					end
					if hp < 0.5 then
						bar:Stop()
					else
						local value = bar.candyBarBar:GetValue()
						if hp < value then
							bar.candyBarBar:SetValue(hp)
							bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
						end
					end
				end
			elseif defensiveTowers[strid] then
				if not onDemandTrackers[strid] then
					onDemandTrackers[strid] = defenseTowerHealth
				end
				local newHp = onDemandTrackers[strid] - amount
				onDemandTrackers[strid] = newHp
				local hp = newHp / defenseTowerHealth * 100
				if hp < 90 then
					local bar = mod:GetBar(defensiveTowers[strid])
					if not bar then
						bar = StartNewBar(self, defensiveTowers[strid], defensiveTowers[strid], 237021) -- Interface/Icons/inv_essenceofwintergrasp
					end
					if hp < 1.5 then
						bar:Stop()
					else
						bar.candyBarBar:SetValue(hp)
						bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
					end
				end
			elseif strid == "307964" then -- Main Entrance
				local bar = mod:GetBar(L.mainEntrance)
				if not bar then
					bar = StartNewBar(self, L.mainEntrance, "Main Entrance", 134957)
					onDemandTrackers[strid] = mainEntranceHealth
				end
				local newHp = onDemandTrackers[strid] - amount
				onDemandTrackers[strid] = newHp
				local hp = newHp / mainEntranceHealth * 100
				if hp < 0.5 then
					bar:Stop()
				else
					bar.candyBarBar:SetValue(hp)
					bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
				end
			end
		end
	end
end

do
	-- POI icon texture id: gateH, gateA, horizWallH, horizWallA, vertWallH, vertWallA
	local intactTextures = { [77] = true, [80] = true, [86] = true, [89] = true, [95] = true, [98] = true, }
	local damaged, destroyed, all = { }, { }, { }
	for k in next, intactTextures do
		damaged[k + 1] = true
		destroyed[k + 2] = true
		all[k], all[k + 1], all[k + 2] = true, true, true
	end

	function mod:AREA_POIS_UPDATED()
		local pois = GetAreaPOIForMap(1334) -- Wintergrasp
		for i = 1, #pois do
			local POI = pois[i]
			local tbl = GetAreaPOIInfo(1334, POI)
			local ti = wallTextures[POI]
			local textureIndex = tbl.textureIndex
			if tbl and ((ti and ti ~= textureIndex) or (not ti and poiWallNames[POI])) then
				if intactTextures[ti] and damaged[textureIndex] then -- intact before, damaged now
					local msg = format(L.damaged, poiWallNames[POI])
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", msg)
					print(msg)
				elseif damaged[ti] and destroyed[textureIndex] then -- damaged before, destroyed now
					local msg = format(L.destroyed, poiWallNames[POI])
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", msg)
					print(msg)
				end
				wallTextures[POI] = all[textureIndex] and textureIndex or ti
			end
		end
	end
end

local WGSyncRequest
do
	local towerNamesEnglish = {
		["308062"] = "West Tower", -- Shadowsight Tower (West)
		["308013"] = "South Tower", -- Winter's Edge Tower (Mid)
		["307935"] = "East Tower", -- Flamewatch Tower (East)
	}
	local function initTowerBars()
		mod:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		local color = "colorHorde"
		local tbl = GetAreaPOIInfo(1334, 6027) -- Main entrance POI
		if tbl and tbl.textureIndex == 77 then -- If main entrance is horde texture then towers are alliance
			color = "colorAlliance"
		end
		for towerId, towerName in next, towerNames do
			local bar = mod:StartBar(towerName, 100, 236351, color, true)
			bar:Pause()
			bar.candyBarBar:SetValue(100)
			bar.candyBarDuration:SetText("100%")
			bar:Set("capping:customchat", function(bar)
				if towerName ~= towerNamesEnglish[towerId] then
					return towerNamesEnglish[towerId] .. "/".. towerName .." - ".. bar.candyBarDuration:GetText()
				else
					return towerName .." - ".. bar.candyBarDuration:GetText()
				end
			end)
		end
	end

	local NewTicker = C_Timer.NewTicker
	local hereFromTheStart, hasData = true, true
	local stopTimer = nil
	local function allow() hereFromTheStart = false end
	local function stop() hereFromTheStart = true stopTimer = nil end
	function WGSyncRequest()
		for i = 1, 80 do
			local scoreTbl = GetScoreInfo(i)
			if scoreTbl and scoreTbl.damageDone and scoreTbl.damageDone ~= 0 then
				hereFromTheStart = true
				hasData = false
				mod:Timer(0.5, allow)
				stopTimer = NewTicker(3, stop, 1)
				SendAddonMessage("Capping", "twr", "INSTANCE_CHAT")
				return
			end
		end

		hereFromTheStart = true
		hasData = true
		initTowerBars()
	end

	local timer = nil
	local function SendWGTowers()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local msg = format(
				"308062:%d:308013:%d:307935:%d",
				towers["308062"], towers["308013"], towers["307935"] -- West, Mid, East
			)
			SendAddonMessage("Capping", msg, "INSTANCE_CHAT")
		end
	end

	local me = UnitName("player").. "-" ..GetRealmName()
	function mod:CHAT_MSG_ADDON(prefix, msg, channel, sender)
		if prefix == "Capping" and channel == "INSTANCE_CHAT" then
			if msg == "twr" and sender ~= me then -- gate request
				if hasData then -- Joined a late game, don't send data
					if timer then timer:Cancel() end
					timer = NewTicker(1, SendWGTowers, 1)
				elseif stopTimer then
					stopTimer:Cancel()
					stopTimer = NewTicker(3, stop, 1)
				end
			elseif not hereFromTheStart and sender ~= me then
				local west, westRawHp, mid, midRawHp, east, eastRawHp = strsplit(":", msg)
				local westHp, midHp, eastHp = tonumber(westRawHp), tonumber(midRawHp), tonumber(eastRawHp)
				if westHp and midHp and eastHp and -- Safety dance
				west == "308062" and mid == "308013" and east == "307935" then
					hereFromTheStart = true
					hasData = true
					initTowerBars()
					towers = {
						["308062"] = westHp, -- Shadowsight Tower (West)
						["308013"] = midHp, -- Winter's Edge Tower (Mid)
						["307935"] = eastHp, -- Flamewatch Tower (East)
					}

					for towerId, towerHp in next, towers do
						local bar = self:GetBar(towerNames[towerId])
						if bar then
							local hp = towerHp / baseTowerHealth * 100
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
end

do
	local RequestBattlefieldScoreData = RequestBattlefieldScoreData
	function mod:EnterZone()
		wallTextures = {}
		onDemandTrackers = {}
		local pois = GetAreaPOIForMap(1334) -- Wintergrasp
		for i = 1, #pois do
			local POI = pois[i]
			local tbl = GetAreaPOIInfo(1334, POI)
			if poiWallNames[POI] and tbl.textureIndex then
				wallTextures[POI] = tbl.textureIndex
			end
		end

		westHp, midHp, eastHp = baseTowerHealth, baseTowerHealth, baseTowerHealth
		towers = {
			["308062"] = baseTowerHealth, -- Shadowsight Tower (West)
			["308013"] = baseTowerHealth, -- Winter's Edge Tower (Mid)
			["307935"] = baseTowerHealth, -- Flamewatch Tower (East)
		}
		RequestBattlefieldScoreData()
		self:Timer(1, RequestBattlefieldScoreData)
		self:Timer(2, WGSyncRequest)
		C_ChatInfo.RegisterAddonMessagePrefix("Capping")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("AREA_POIS_UPDATED")
	end
end

function mod:ExitZone()
	self:UnregisterEvent("AREA_POIS_UPDATED")
	self:UnregisterEvent("CHAT_MSG_ADDON")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

mod:RegisterZone(2118)
