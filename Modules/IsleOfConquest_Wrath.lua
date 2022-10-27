
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

local SendAddonMessage = C_ChatInfo.SendAddonMessage
local baseGateHealth = 2400000
local lowestAllianceHp, lowestHordeHp = baseGateHealth, baseGateHealth
local hordeGates, allianceGates = {}, {}
local hordeGateBar, allianceGateBar = nil, nil
local englishNames = {
	["195494"] = "Horde Gate (Front)/",
	["195495"] = "Horde Gate (West)/",
	["195496"] = "Horde Gate (East)/",
	["195698"] = "Alliance Gate (Front)/",
	["195699"] = "Alliance Gate (West)/",
	["195700"] = "Alliance Gate (East)/",
}

do
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	function mod:COMBAT_LOG_EVENT_UNFILTERED()
		local _, event, _, _, _, _, _, destGUID, _, _, _, _, _, _, amount = CombatLogGetCurrentEventInfo()
		if event == "SPELL_BUILDING_DAMAGE" then
			local _, _, _, _, _, strid = strsplit("-", destGUID)
			if hordeGates[strid] then
				local newHp = hordeGates[strid] - amount
				hordeGates[strid] = newHp
				if newHp < lowestHordeHp then
					lowestHordeHp = newHp
					local bar = hordeGateBar
					if bar then
						local hp = newHp / baseGateHealth * 100
						if hp < 0.5 then
							bar:Stop()
						else
							bar.candyBarBar:SetValue(hp)
							bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							local gate = strid == "195494" and L.front or strid == "195495" and L.west or L.east
							bar.candyBarLabel:SetFormattedText(L.gatePosition, L.hordeGate, gate)
							bar:Set("capping:englishprint", englishNames[strid])
						end
					end
				end
			elseif allianceGates[strid] then
				local newHp = allianceGates[strid] - amount
				allianceGates[strid] = newHp
				if newHp < lowestAllianceHp then
					lowestAllianceHp = newHp
					local bar = allianceGateBar
					if bar then
						local hp = newHp / baseGateHealth * 100
						if hp < 0.5 then
							bar:Stop()
						else
							bar.candyBarBar:SetValue(hp)
							bar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							local gate = strid == "195698" and L.front or strid == "195699" and L.west or L.east
							bar.candyBarLabel:SetFormattedText(L.gatePosition, L.allianceGate, gate)
							bar:Set("capping:englishprint", englishNames[strid])
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
end

local function initGateBars()
	mod:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	local aBar = mod:StartBar(L.allianceGate, 100, 132362, "colorHorde", true) -- Interface/Icons/ability_warrior_shieldwall
	aBar:Pause()
	aBar.candyBarBar:SetValue(100)
	aBar.candyBarDuration:SetText("100%")
	aBar:Set("capping:englishprint", "Alliance Gate/")
	aBar:Set("capping:customchat", function(bar)
		if L.allianceGate ~= "Alliance Gate" then
			return bar:Get("capping:englishprint") .. bar.candyBarLabel:GetText() .." - ".. bar.candyBarDuration:GetText()
		else
			return bar.candyBarLabel:GetText() .." - ".. bar.candyBarDuration:GetText()
		end
	end)
	local hBar = mod:StartBar(L.hordeGate, 100, 132362, "colorAlliance", true) -- Interface/Icons/ability_warrior_shieldwall
	hBar:Pause()
	hBar.candyBarBar:SetValue(100)
	hBar.candyBarDuration:SetText("100%")
	hBar:Set("capping:englishprint", "Horde Gate/")
	hBar:Set("capping:customchat", function(bar)
		if L.hordeGate ~= "Horde Gate" then
			return bar:Get("capping:englishprint") .. bar.candyBarLabel:GetText() .." - ".. bar.candyBarDuration:GetText()
		else
			return bar.candyBarLabel:GetText() .." - ".. bar.candyBarDuration:GetText()
		end
	end)
	allianceGateBar, hordeGateBar = aBar, hBar
end

local IoCSyncRequest
do
	local timer = nil
	local NewTicker = C_Timer.NewTicker
	local function SendIoCGates()
		timer = nil
		if IsInGroup(2) then -- We've not just ragequit
			local msg = string.format(
				"195494:%d:195495:%d:195496:%d:195698:%d:195699:%d:195700:%d",
				hordeGates["195494"], hordeGates["195495"], hordeGates["195496"],
				allianceGates["195698"], allianceGates["195699"], allianceGates["195700"]
			)
			SendAddonMessage("Capping", msg, "INSTANCE_CHAT")
		end
	end

	local hereFromTheStart, hasData = true, true
	local stopTimer = nil
	local function allow() hereFromTheStart = false end
	local function stop() hereFromTheStart = true stopTimer = nil end
	--local GetScoreInfo = C_PvP.GetScoreInfo
	function IoCSyncRequest()
		for i = 1, 80 do
			local _, _, _, _, _, _, _, _, _, _, damageDone = GetBattlefieldScore(i)
			if damageDone and damageDone ~= 0 then
				hereFromTheStart = true
				hasData = false
				mod:Timer(0.5, allow)
				stopTimer = NewTicker(3, stop, 1)
				SendAddonMessage("Capping", "gr", "INSTANCE_CHAT")
				return
			end
		end

		hereFromTheStart = true
		hasData = true
		initGateBars()
	end

	local me = UnitName("player").. "-" ..GetRealmName()
	local GetAreaPOIForMap = C_AreaPoiInfo.GetAreaPOIForMap
	local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
	function mod:CHAT_MSG_ADDON(prefix, msg, channel, sender)
		if prefix == "Capping" and channel == "INSTANCE_CHAT" then
			if msg == "gr" and sender ~= me then -- gate request
				if hasData then -- Joined a late game, don't send data
					if timer then timer:Cancel() end
					timer = NewTicker(1, SendIoCGates, 1)
				elseif stopTimer then
					stopTimer:Cancel()
					stopTimer = NewTicker(3, stop, 1)
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

					if hordeGateBar then
						local hp = lowestHordeHp / baseGateHealth * 100
						if hp < 1 then
							hordeGateBar:Stop()
						else
							hordeGateBar.candyBarBar:SetValue(hp)
							hordeGateBar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							if lowestHordeHp ~= baseGateHealth then
								local gate = lowestHordeHp == hGate1 and h1 or lowestHordeHp == hGate2 and h2 or h3
								hordeGateBar.candyBarLabel:SetFormattedText(L.gatePosition, L.hordeGate, gate == h1 and L.front or gate == h2 and L.west or L.east)
								hordeGateBar:Set("capping:englishprint", englishNames[gate])
							end
						end
					end
					if allianceGateBar then
						local hp = lowestAllianceHp / baseGateHealth * 100
						if hp < 1 then
							allianceGateBar:Stop()
						else
							allianceGateBar.candyBarBar:SetValue(hp)
							allianceGateBar.candyBarDuration:SetFormattedText("%.1f%%", hp)
							if lowestAllianceHp ~= baseGateHealth then
								local gate = lowestAllianceHp == aGate1 and a1 or lowestAllianceHp == aGate2 and a2 or a3
								allianceGateBar.candyBarLabel:SetFormattedText(L.gatePosition, L.allianceGate, gate == a1 and L.front or gate == a2 and L.west or L.east)
								allianceGateBar:Set("capping:englishprint", englishNames[gate])
							end
						end
					end
				end
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:find(L.broken, nil, true) then
		SendAddonMessage("Capping", "rb", "INSTANCE_CHAT")
	elseif msg:find(L.halfway) then -- Need pattern matching for ruRU
		SendAddonMessage("Capping", "rbh", "INSTANCE_CHAT")
	end
end

do
	local RequestBattlefieldScoreData = RequestBattlefieldScoreData
	function mod:EnterZone()
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
		self:StartFlagCaptures(61, 169)
		self:SetupHealthCheck("34922", L.hordeBoss, "Horde Boss", 236452, "colorAlliance") -- Overlord Agmar -- Interface/Icons/Achievement_Character_Orc_Male
		self:SetupHealthCheck("34924", L.allianceBoss, "Alliance Boss", 236448, "colorHorde") -- Halford Wyrmbane -- Interface/Icons/Achievement_Character_Human_Male
		C_ChatInfo.RegisterAddonMessagePrefix("Capping")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		RequestBattlefieldScoreData()
		self:Timer(1, function() RequestBattlefieldScoreData() end)
		self:Timer(2, IoCSyncRequest)
	end
end

function mod:ExitZone()
	self:UnregisterEvent("CHAT_MSG_ADDON")
	self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:StopFlagCaptures()
end

mod:RegisterZone(628)
