
local addonName, Capping = ...

local L = Capping.L
local _G = getfenv(0)

local pname
local floor = math.floor
local strmatch, strlower, pairs, format, tonumber = strmatch, strlower, pairs, format, tonumber
local UnitIsEnemy, UnitName, GetTime, SendAddonMessage = UnitIsEnemy, UnitName, GetTime, SendAddonMessage
local GetWorldStateUIInfo = GetWorldStateUIInfo
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

local SetupAssault, GetIconData, nodestates
do -- POI handling
	local GetNumMapLandmarks, GetMapLandmarkInfo = GetNumMapLandmarks, GetMapLandmarkInfo
	local ntime, skipkeep
	local poicons = { -- textures used on worldmap { al, ar, at, ab, hl, hr, ht, hb, neutral, ally, ally half, horde, horde half
		symbol = { 46, nil, nil, nil, 48, nil, nil, nil, },
		flag = { 43, nil, nil, nil, 44, nil, nil, nil, },
		graveyard = { 4, nil, nil, nil, 14, nil, nil, nil, 8, 15, 4, 13, 14, },
		tower = { 9, nil, nil, nil, 12, nil, nil, nil, 6, 11, 9, 10, 12, },
		farm = { 32, nil, nil, nil, 34, nil, nil, nil, 31, 33, 32, 35, 34, },
		blacksmith = { 27, nil, nil, nil, 29, nil, nil, nil, 26, 28, 27, 30, 29, },
		mine = { 17, nil, nil, nil, 19, nil, nil, nil, 16, 18, 17, 20, 19, },
		stables = { 37, nil, nil, nil, 39, nil, nil, nil, 36, 38, 37, 40, 39, },
		lumbermill = { 22, nil, nil, nil, 24, nil, nil, nil, 21, 23, 22, 25, 24, },
		workshop = { 137, nil, nil, nil, 139, nil, nil, nil, 135, 136, 137, 138, 139, },
		hangar = { 142, nil, nil, nil, 144, nil, nil, nil, 140, 141, 142, 143, 144, },
		docks = { 147, nil, nil, nil, 149, nil, nil, nil, 145, 146, 147, 148, 149, },
		refinery = { 152, nil, nil, nil, 154, nil, nil, nil, 150, 151, 152, 153, 154, },
		path = { "Interface\\Minimap\\POIIcons", },
	}
	local GetPOITextureCoords = _G.GetPOITextureCoords
	for k, v in pairs(poicons) do
		if k ~= "path" then
			if k ~= "tower" then
				v[1], v[2], v[3], v[4] = GetPOITextureCoords(v[1])
				v[5], v[6], v[7], v[8] = GetPOITextureCoords(v[5])
			else
				v[2], v[1], v[3], v[4] = GetPOITextureCoords(v[1])
				v[6], v[5], v[7], v[8] = GetPOITextureCoords(v[5])
			end
		end
	end
	-- Easy world map icon checker
	--local m = UIParent:CreateTexture(nil, "OVERLAY")
	--m:SetTexture("Interface\\Minimap\\POIIcons")
	--m:SetPoint("CENTER")
	--m:SetWidth(512)
	--m:SetHeight(700)

	local path = poicons.path
	Capping.iconpath = path
	GetIconData = function(faction, name)
		local t = name and poicons[name] or poicons.symbol
		if faction == "horde" then
			path[2], path[3], path[4], path[5] = t[5], t[6], t[7], t[8]
		else
			path[2], path[3], path[4], path[5] = t[1], t[2], t[3], t[4]
		end
		return path
	end
	local function getnodetype(tindex)
		for k, v in pairs(poicons) do
			if v[9] and (not skipkeep or k ~= "tower") and (tindex == v[9] or tindex == v[10] or tindex == v[11] or tindex == v[12] or tindex == v[13]) then
				return k..tindex
			end
		end
		return "none"
	end
	SetupAssault = function(bgcaptime, nokeep)
		ntime = bgcaptime -- cap time
		skipkeep = nokeep -- workaround for IoC keep
		nodestates = { }
		for i = 1, GetNumMapLandmarks() do
			local name, _, ti = GetMapLandmarkInfo(i)
			nodestates[name] = getnodetype(ti)
			--print("Creating base:", name, ti, nodestates[name])
		end
		Capping:RegisterTempEvent("WORLD_MAP_UPDATE")
	end
	-----------------------------------
	function Capping:WORLD_MAP_UPDATE()
	-----------------------------------
		for i = 1, GetNumMapLandmarks() do
			local name, _, ti = GetMapLandmarkInfo(i)
			if name then
				local ns = nodestates[name]
				if not ns then
				--	print("New base?", name, ti, ti and getnodetype(ti) or "NOPE")
				--	nodestates[name] = getnodetype(ti)
				elseif ns ~= "none" then
					local nodetype, prevstate = strmatch(ns, "(%a+)(%d+)")
					if tonumber(prevstate) ~= ti then
						if ti == poicons[nodetype][11] then
							self:StartBar(name, ntime, GetIconData("alliance", nodetype), "alliance")
							if nodetype == "workshop" then -- reset siege engine timer
								self:StopBar((GetSpellInfo(56661)))
							end
						elseif ti == poicons[nodetype][13] then
							self:StartBar(name, ntime, GetIconData("horde", nodetype), "horde")
							if nodetype == "workshop" then -- reset siege engine timer
								self:StopBar((GetSpellInfo(56661)))
							end
						else
							self:StopBar(name)
						end
						--print("Updating node:", name, "from:", nodestates[name], "to:", nodetype..ti)
						nodestates[name] = nodetype..ti
					end
				end
			end
		end
	end
	function Capping:TestNode(ntype, faction)
		self:StartBar("Test", 20, GetIconData(faction, ntype), faction)
	end
end

-----------------------------------------------------------
function Capping:CreateCarrierButton(name, postclick) -- create common secure button
-----------------------------------------------------------
	self.CarrierOnEnter = self.CarrierOnEnter or function(this)
		if not this.car then return end
		local c = self.db.colors[strlower(this.faction)] or self.db.colors.info1
		this:SetBackdropColor(c.r, c.g, c.b, 0.4)
	end
	self.CarrierOnLeave = self.CarrierOnLeave or function(this)
		this:SetBackdropColor(0, 0, 0, 0)
	end
	local b = CreateFrame("Button", name, UIParent, "SecureUnitButtonTemplate")
	b:SetWidth(200)
	b:SetHeight(20)
	b:RegisterForClicks("AnyUp")
	b:SetBackdrop(self.backdrop)
	b:SetBackdropColor(0, 0, 0, 0)
	b:SetScript("PostClick", postclick)
	b:SetScript("OnEnter", self.CarrierOnEnter)
	b:SetScript("OnLeave", self.CarrierOnLeave)
	return b
end

-- initialize or update a final score estimation bar (AB and EotS uses this)
local NewEstimator
do
	local ascore, atime, abases, hscore, htime, hbases, updatetime, currentbg, prevText
	NewEstimator = function(bg) -- resets estimator and sets new battleground
		if not Capping.UPDATE_WORLD_STATES then
			local f2 = L["Final: %d - %d"]
			local lookup = {
				[1] = { [0] = 0, [1] = 0.8333, [2] = 1.1111, [3] = 1.6667, [4] = 3.3333, [5] = 30, }, -- ab -- 1=2, 2=3, 3=4
				[2] = { [0] = 0, [1] = 0.5, [2] = 1, [3] = 2.5, [4] = 5, }, -- eots
				[3] = { [0] = 0, [1] = 1.1111, [2] = 3.3333, [3] = 30, }, -- gilneas
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
			function Capping:UPDATE_WORLD_STATES()
			--------------------------------------
				local _, zType = GetInstanceInfo()
				if zType ~= "pvp" then return end

				local currenttime = GetTime()

				local _, _, _, scoreStringA = GetWorldStateUIInfo(currentbg == 2 and 3 or 2) -- 2/3 for AB and Gil, 3/4 for EotS
				local base, score, smax = strmatch(scoreStringA, "[^%d]+(%d+)[^%d]+(%d+)/(%d+)") -- Bases: %d  Resources: %d/%d
				local ABases, AScore, MaxScore = tonumber(base), tonumber(score), tonumber(smax) or 2000
				local _, _, _, scoreStringH = GetWorldStateUIInfo(currentbg == 2 and 4 or 3) -- 2/3 for AB and Gil, 3/4 for EotS

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
				updatetime = nil

				local apps, hpps = lookup[currentbg][abases], lookup[currentbg][hbases]
				-- timeTilFinal = ((remainingScore) / scorePerSec) - (timeSinceLastUpdate)
				local ATime = ((MaxScore - ascore) / (apps > 0 and apps or 0.000001)) - (currenttime - atime)
				local HTime = ((MaxScore - hscore) / (hpps > 0 and hpps or 0.000001)) - (currenttime - htime)

				if HTime < ATime then -- Horde is winning
					local newText = getlscore(HTime, apps, ascore, MaxScore)
					if newText ~= prevText then
						self:StopBar(prevText)
						self:StartBar(newText, HTime, GetIconData("horde", "symbol"), "horde")
						prevText = newText
					end
				else -- Alliance is winning
					local newText = getlscore(ATime, hpps, hscore, MaxScore, true)
					if newText ~= prevText then
						self:StopBar(prevText)
						self:StartBar(newText, ATime, GetIconData("alliance", "symbol"), "alliance")
						prevText = newText
					end
				end
			end
		end
		currentbg, updatetime, ascore, atime, abases, hscore, htime, hbases, prevText = bg, nil, 0, 0, 0, 0, 0, 0, ""
		Capping:RegisterTempEvent("UPDATE_WORLD_STATES")
	end
end

do
	------------------------------------------------ Arathi Basin -----------------------------------------------------
	local function ArathiBasin()
		SetupAssault(60)
		NewEstimator(1)
	end
	Capping:AddBG(529, ArathiBasin)
end

do
	------------------------------------------------ Deepwind Gorge -----------------------------------------------------
	local function DeepwindGorge()
		SetupAssault(61)
		--NewEstimator(1)
	end
	Capping:AddBG(1105, DeepwindGorge)
end

do
	------------------------------------------------ Gilneas -----------------------------------------------------
	local function TheBattleForGilneas()
		SetupAssault(60)
		NewEstimator(3)
	end
	Capping:AddBG(761, TheBattleForGilneas)
end

do
	------------------------------------------------ Alterac Valley ---------------------------------------------------
	local function AlteracValley(self)
		if not self.AVAssaults then
			pname = pname or UnitName("player")

			function Capping:GOSSIP_SHOW()
				if self.db.avquest then
					local target = UnitGUID("target")
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
			end
			function Capping:QUEST_PROGRESS()
				if self.db.avquest then
					self:GOSSIP_SHOW()
					if IsQuestCompletable() then
						CompleteQuest()
					end
				end
			end
			function Capping:QUEST_COMPLETE()
				if self.db.avquest then
					GetQuestReward(0)
				end
			end

			------------------------------------------------------
			--function Capping:AVSync(prefix, message, chan, sender)
			------------------------------------------------------
			--	if prefix ~= "cap" or sender == pname then return end
			--	if message == "r" then
			--		for value, color in pairs(Capping.activebars) do
			--			local f = Capping:GetBar(value)
			--			if f and f:IsShown() then
			--				SendAddonMessage("cap", format("%s@%d@%d@%s", value, f.duration, f.duration - f.remaining, color), "WHISPER", sender)
			--			end
			--		end
			--	else
			--		local name, duration, elapsed, color = strmatch(message, "^(.+)@(%d+)@(%d+)@(%a+)$")
			--		local f = self:GetBar(name)
			--		if name and elapsed and (not f or not f:IsShown()) then
			--			local icon
			--			if name == L["Ivus begins moving"] then
			--				icon = "Interface\\Icons\\Spell_Nature_NaturesBlessing"
			--			elseif name == L["Lokholar begins moving"] then
			--				icon = "Interface\\Icons\\Spell_Frost_Glacier"
			--			else
			--				icon = GetIconData(color, strmatch(nodestates[name] or "symbol0", "(%a+)(%d+)") or "symbol")
			--			end
			--			duration = tonumber(duration) or 245
			--			self:StartBar(name, duration - (tonumber(elapsed) or 245), icon, color or "info2")
			--		end
			--	end
			--end
			---------------------------
			--function Capping:SyncAV()
			---------------------------
			--	SendAddonMessage("cap", "r", "INSTANCE_CHAT")
			--end
		end

		SetupAssault(245)
		self:RegisterTempEvent("GOSSIP_SHOW")
		self:RegisterTempEvent("QUEST_PROGRESS")
		self:RegisterTempEvent("QUEST_COMPLETE")

		--self:RegisterTempEvent("CHAT_MSG_ADDON", "AVSync")
		--self:SyncAV()
	end
	Capping:AddBG(30, AlteracValley)
end

do
	------------------------------------------------ Eye of the Storm -------------------------------------------------
	local ef, ResetCarrier
	local function EyeOfTheStorm(self)
		if not ef then
			local eficon, eftext, carrier, cclass
			-- handles secure stuff
			local function SetEotSCarrierAttribute()
				ef:SetFrameStrata("HIGH")
				ef:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame1:GetRight() - 14, AlwaysUpFrame1:GetBottom() + 8.5)
				if UnitExists("arena1") then
					SecureUnitButton_OnLoad(ef, "arena1")
				elseif UnitExists("arena2") then
					SecureUnitButton_OnLoad(ef, "arena2")
				end
				UnregisterUnitWatch(ef)
			end
			-- resets carrier display
			ResetCarrier = function(captured)
				carrier, ef.faction, ef.car = nil, nil, nil
				eftext:SetText("")
				eficon:Hide()
				if captured then
					self:StartBar(L["Flag respawns"], 21, GetIconData(strlower(UnitFactionGroup("player")), "flag"), "info2")
				end
				self:CheckCombat(SetEotSCarrierAttribute)
			end
			local function CarrierOnClick(this)
				if IsControlKeyDown() and carrier then
					SendChatMessage(format(L["%s's flag carrier: %s (%s)"], this.faction, carrier, cclass), "INSTANCE_CHAT")
				end
			end
			-- parse battleground messages
			local function EotSFlag(a1, faction)
				local name = strmatch(a1, L["^(.+) has taken the flag!"])
				if name then
					if name == "L'Alliance" then -- frFR
						ResetCarrier(true)
					else
						cclass = GetClassByName(name, faction)
						carrier, ef.car = name, true
						ef.faction = (faction == 0 and _G.FACTION_HORDE) or _G.FACTION_ALLIANCE
						eftext:SetFormattedText("|cff%s%s|r", classcolor[cclass or "PRIEST"] or classcolor.PRIEST, carrier or "")
						eficon:SetTexture((faction == 0 and "Interface\\WorldStateFrame\\HordeFlag") or "Interface\\WorldStateFrame\\AllianceFlag")
						eficon:Show()
						self:CheckCombat(SetEotSCarrierAttribute)
					end
				elseif strmatch(a1, L["dropped"]) then
					ResetCarrier()
				elseif strmatch(a1, L["captured the"]) or strmatch(a1, taken) then
					ResetCarrier(true)
				end
			end
			--------------------------------
			function Capping:HFlagUpdate(a1)
			--------------------------------
				EotSFlag(a1, 0)
			end
			--------------------------------
			function Capping:AFlagUpdate(a1)
			--------------------------------
				EotSFlag(a1, 1)
			end

			ef = self:CreateCarrierButton("CappingEotSFrame", CarrierOnClick)
			eficon = ef:CreateTexture(nil, "ARTWORK") -- flag icon
			eficon:SetPoint("TOPLEFT", ef, "TOPLEFT", 0, 1)
			eficon:SetPoint("BOTTOMRIGHT", ef, "BOTTOMLEFT", 20, -1)

			eftext = self:CreateText(ef, 13, "LEFT", eficon, 22, 0, ef, 0, 0) -- carrier text
			ef.text = eftext

			self:AddFrameToHide(ef) -- add to the tohide list to hide when bg is over
		end

		ef:Show()
		ResetCarrier()

		-- setup for final score estimation (2 for EotS)
		NewEstimator(2)
		SetupAssault(60) -- In RBG the four points have flags that need to be assaulted, like AB
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "HFlagUpdate")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "AFlagUpdate")
	end
	Capping:AddBG(566, EyeOfTheStorm)
end

do
	------------------------------------------------ Isle of Conquest --------------------------------------
	local function IsleOfConquest(self)
		if not self.HIoCAssault then
			pname = pname or UnitName("player")
			local siege = GetSpellInfo(56661)
			local damaged, _, siegeicon = GetSpellInfo(67323)
			local nodes = { L["Alliance Keep"], L["Horde Keep"], }
			local function IoCAssault(text, faction)
				text = strlower(text)
				for _, value in ipairs(nodes) do
					if strmatch(text, strlower(value)) then
						if strmatch(text, assaulted) then
							return self:StartBar(value, 62, GetIconData(faction, "tower"), faction)
						elseif strmatch(text, defended) or strmatch(text, taken) or strmatch(text, claimed) then
							return self:StopBar(value)
						end
					end
				end
			end
			--------------------------------
			function Capping:HIoCAssault(a1)
			--------------------------------
				IoCAssault(a1, "horde")
			end
			--------------------------------
			function Capping:AIoCAssault(a1)
			--------------------------------
				IoCAssault(a1, "alliance")
			end
			---------------------------------------------------------
			--function Capping:IoCSync(event, prefix, message, chan, sender) -- only sync for siege engine timer
			---------------------------------------------------------
			--	if sender == pname then return end
			--	if prefix == "cap" then
			--		local f = self:GetBar(siege)
			--		if (not f or not f:IsShown()) and message then
			--			local faction, remain = strmatch(message, "(%a)(%d+)")
			--			faction = (faction == "a" and "alliance") or (faction == "h" and "horde")
			--			remain = (remain == "1" and 183) or (remain == "2" and 92) or tonumber(remain or 0) or 0
			--			if faction and remain > 0 then
			--				self:StartBar(siege, remain, siegeicon, faction)
			--			end
			--		end
			--	elseif prefix == "DBMv4-Mod" then
			--		local isle, _, remain, faction = strsplit("\t", message)
			--		if isle == "IsleofConquest" then
			--			remain = (remain == "SEStart" and 183) or (remain == "SEHalfway" and 92) or nil
			--			if remain and faction then
			--				self:StartBar(siege, remain, siegeicon, strlower(faction))
			--			end
			--		end
			--	end
			--end
			------------------------------------
			function Capping:SiegeEngine(a1, a2)
			------------------------------------
				if a1 and a2 then -- check npc yells
					if strmatch(a1, L["seaforium bombs"]) or strmatch(a1, L["It's broken"]) then
						local faction = (strmatch(a2, L["Goblin"]) and "horde") or "alliance"
						self:StartBar(siege, 183, siegeicon, faction)
						--SendAddonMessage("cap", faction == "alliance" and "a1" or "h1", "INSTANCE_CHAT")
					elseif strmatch(a1, L["halfway"]) then
						local faction = (strmatch(a2, L["Goblin"]) and "horde") or "alliance"
						self:StartBar(siege, 92, siegeicon, faction)
						--SendAddonMessage("cap", faction == "alliance" and "a2" or "h2", "INSTANCE_CHAT")
					end
				end
			end
		end
		SetupAssault(61, true)
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "HIoCAssault")
		self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "AIoCAssault")
		self:RegisterTempEvent("CHAT_MSG_MONSTER_YELL", "SiegeEngine")
		--self:RegisterTempEvent("CHAT_MSG_ADDON", "IoCSync")
	end
	Capping:AddBG(628, IsleOfConquest)
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
			local function SetWSGCarrierAttribute()
				if not af:GetAttribute("unit") or not hf:GetAttribute("unit") then
					if acarrier == "arena1" or hcarrier == "arena2" then
						SecureUnitButton_OnLoad(af, "arena1")
						SecureUnitButton_OnLoad(hf, "arena2")
					elseif acarrier or hcarrier then
						SecureUnitButton_OnLoad(af, "arena2")
						SecureUnitButton_OnLoad(hf, "arena1")
					end
					UnregisterUnitWatch(af)
					UnregisterUnitWatch(hf)
				end
				af:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame1:GetRight() + 38, AlwaysUpFrame1:GetTop())
				hf:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame2:GetRight() + 38, AlwaysUpFrame2:GetTop())
			end
			local function SetCarrier(faction, carrier, class, u) -- setup carrier frames
				if faction == "Horde" then
					hcarrier, hclass, hf.car = carrier, class, carrier
					hftext:SetFormattedText("|cff%s%s|r", classcolor[class or "PRIEST"] or classcolor.PRIEST, carrier or "")
					local hhealth_before = hhealth
					hhealth = min(floor(100 * UnitHealth(u)/UnitHealthMax(u)), 100)
					hftexthp:SetFormattedText("|cff%s%d%%|r", (hhealth < hhealth_before and "ff2222") or "dddddd", hhealth)
					hcarrier = u
					hftext.unit = u
					return hhealth
				elseif faction == "Alliance" then
					acarrier, aclass, af.car = carrier, class, carrier
					aftext:SetFormattedText("|cff%s%s|r", classcolor[class or "PRIEST"] or classcolor.PRIEST, carrier or "")
					ahealth = 0
					aftexthp:SetText((carrier and unknownhp) or "")
					local ahealth_before = ahealth
					ahealth = min(floor(100 * UnitHealth(u)/UnitHealthMax(u)), 100)
					aftexthp:SetFormattedText("|cff%s%d%%|r", (ahealth < ahealth_before and "ff2222") or "dddddd", ahealth)
					acarrier = u
					aftext.unit = u
					return ahealth
				elseif aftext.unit == faction then
					aftext:SetText("")
					aftexthp:SetText("")
					acarrier, aclass, af.car = "", "", nil
				elseif hftext.unit == faction then
					hftext:SetText("")
					hftexthp:SetText("")
					hcarrier, hclass, hf.car = "", "", nil
				end
				Capping:CheckCombat(SetWSGCarrierAttribute)
			end
			local function CarrierOnClick(this) -- sends basic carrier info to battleground chat

			end
			local function CreateWSGFrame() -- create all frames
				local function CreateCarrierFrame(faction) -- create carriers' frames
					local b = self:CreateCarrierButton("CappingTarget"..faction, CarrierOnClick)
					local text = self:CreateText(b, 14, "LEFT", b, 29, 0, b, 0, 0)
					local texthp = self:CreateText(b, 10, "RIGHT", b, -4, 0, b, 28 - b:GetWidth(), 0)
					b.faction = (faction == "Alliance" and _G.FACTION_ALLIANCE) or _G.FACTION_HORDE
					b.text = text
					self:AddFrameToHide(b)
					return b, text, texthp
				end
				af, aftext, aftexthp = CreateCarrierFrame("Alliance")
				hf, hftext, hftexthp = CreateCarrierFrame("Horde")

				af:SetScript("OnUpdate", function(this, a1)
					elap = elap + a1
					if elap > 0.25 then -- health check and display
						elap, togunit = 0, not togunit
						if togunit then
							if UnitExists("arena1") then
								local faction = UnitFactionGroup("arena1")
								local name = GetUnitName("arena1", true)
								local health = UnitHealth("arena1")
								local _, class = UnitClass("arena1")
								SetCarrier(faction, name, class, "arena1")
							else
								SetCarrier("arena1")
							end
						else
							if UnitExists("arena2") then
								local faction = UnitFactionGroup("arena2")
								local name = GetUnitName("arena2", true)
								local health = UnitHealth("arena2")
								local _, class = UnitClass("arena2")
								SetCarrier(faction, name, class, "arena2")
							else
								SetCarrier("arena2")
							end
						end
					end
				end)
				CreateCarrierFrame, CreateWSGFrame = nil, nil
			end
			self.WSGBulk = function() -- stuff to do at the beginning of every wsg, but after combat
				af:Show()
				hf:Show()
				SetCarrier()

				self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_HORDE", "WSGFlagCarrier")
				self:RegisterTempEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "WSGFlagCarrier")
				self:RegisterTempEvent("WORLD_STATE_UI_TIMER_UPDATE", "WSGEnd")
				prevtime = nil
				self:WSGEnd()
			end
			--------------------------------------------
			function Capping:WSGFlagCarrier(a1) -- carrier detection and setup
			--------------------------------------------
				if strmatch(a1, L["captured the"]) then -- flag was captured, reset all carriers
					SetCarrier()
					self:StartBar(L["Flag respawns"], 12, GetIconData(wsgicon, "flag"), "info2")
				end
			end
			-------------------------
			function Capping:WSGEnd() -- timer for last 5 minutes of WSG
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
							self:StartBar(text, remaining, "Interface\\Icons\\INV_Misc_Rune_07", "info2")
						end
						prevtime = remaining
					end
				end
			end

			playerfaction = UnitFactionGroup("player")
			wsgicon = strlower(playerfaction)
			self:CheckCombat(CreateWSGFrame)
		end

		self:CheckCombat(self.WSGBulk)
	end
	Capping:AddBG(489, WarsongGulch)
	Capping:AddBG(726, WarsongGulch) -- Twin Peaks
end

do
	------------------------------------------------ Wintergrasp ------------------------------------------
	local wallid, walls = nil, nil
	local function Wintergrasp(self)
		if not self.WinterAssault then
			wallid = { -- wall section locations
				["4308_1733"] = "NW ", ["4311_1940"] = "NW ", ["4481_2197"] = "NW ", ["4619_2206"] = "NW ",
				["4689_2324"] = "SW ", ["4689_2523"] = "SW ", ["4861_2795"] = "S ",
				["5144_2788"] = "S ", ["5314_2527"] = "SE ", ["5316_2320"] = "SE ",
				["5391_2202"] = "NE ", ["5530_2204"] = "NE ", ["5709_1946"] = "NE ", ["5708_1733"] = "NE ",
				["4770_1664"] = "Inner W ", ["4773_1882"] = "Inner W ", ["4772_2098"] = "Inner W ",
				["4860_2205"] = "Inner S ", ["5004_2197"] = "Inner S ", ["5144_2200"] = "Inner S ",
				["5235_2090"] = "Inner E ", ["5237_1880"] = "Inner E ", ["5232_1675"] = "Inner E ",
				["5001_2793"] = "", ["5000_1623"] = "", -- front gate and fortress door
			}

			-- POI icon texture id
			local intact = { [77] = true, [80] = true, [86] = true, [89] = true, [95] = true, [98] = true, }
			local damaged, destroyed, all = { }, { }, { }
			for k, v in pairs(intact) do
				damaged[k + 1] = true
				destroyed[k + 2] = true
				all[k], all[k + 1], all[k + 2] = true, true, true
			end
			function Capping:WinterAssault() -- scans POI landmarks for changes in wall textures
				for i = 1, GetNumMapLandmarks(), 1 do
					local name, _, textureIndex, x, y = GetMapLandmarkInfo(i)
					local tindex = floor(x * 10000).."_"..floor(y * 10000)
					local ti = walls[tindex]
					if (ti and ti ~= textureIndex) or (not ti and wallid[tindex]) then
						if intact[ti] and damaged[textureIndex] then -- intact before, damaged now
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[tindex], name, _G.ACTION_ENVIRONMENTAL_DAMAGE))
						elseif damaged[ti] and destroyed[textureIndex] then -- damaged before, destroyed now
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", format("%s%s %s!", wallid[tindex], name, _G.ACTION_UNIT_DESTROYED))
						end
						walls[tindex] = all[textureIndex] and textureIndex or ti
					end
				end
			end
		end
		walls = { }
		for i = 1, GetNumMapLandmarks(), 1 do
			local _, _, textureIndex, x, y = GetMapLandmarkInfo(i)
			local tindex = floor(x * 10000).."_"..floor(y * 10000)
			if wallid[tindex] then
				walls[tindex] = textureIndex
			end
		end
		self:RegisterTempEvent("WORLD_MAP_UPDATE", "WinterAssault")
	end
	Capping:AddBG("LakeWintergrasp", Wintergrasp) -- 571, but used for the entirety of Northrend
end

do
	------------------------------------------------ Ashran ------------------------------------------
	local function Ashran(self)
		if not self.AshranControl then
			function Capping:AshranControl(msg, ...)
				--print(msg, ...)
				--Ashran Herald yells: The Horde controls the Market Graveyard for 15 minutes!
				local faction, point, timeString = strmatch(msg, "The (.+) controls the (.+) for (%d+) minutes!")
				local timeLeft = tonumber(timeString)
				faction = faction == "Horde" and "horde" or "alliance"
				if faction and point and timeLeft then
					self:StartBar(point, timeLeft*60, GetIconData(faction, "graveyard"), faction)
				end
			end
		end
		if not self.AshranEvents then
			function Capping:AshranEvents(msg, ...)
				local idString = strmatch(msg, "spell:(%d+)")
				local id = tonumber(idString)
				--print(msg:gsub("|", "||"), ...)
				if id and id ~= 168506 then -- 168506 = Ancient Artifact
					local name, _, icon = GetSpellInfo(id)
					self:StartBar(name, 180, icon, "info2")
				end
			end
		end
		if not self.AshranTimeLeft then
			function Capping:AshranTimeLeft()
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
								self:StartBar(text, remaining, "Interface\\Icons\\achievement_zone_ashran", "info2")
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
	Capping:AddBG("Ashran", Ashran) -- 1191, but takes a few seconds after ZONE_CHANGED_NEW_AREA (walking in) until it's at this (correct) value
end

do
	------------------------------------------------ Arena ------------------------------------------
	local function Arena(self)
		if not self.ArenaTimers then
			function Capping:ArenaTimers()
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
								self:StartBar(spell, 93, icon, "info2")
								local text = gsub(_G.TIME_REMAINING, ":", "")
								self:StartBar(text, remaining, nil, "info2")
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
	end
	Capping:AddBG(559, Arena) -- Nagrand Arena
	Capping:AddBG(562, Arena) -- Blade's Edge Arena
	Capping:AddBG(572, Arena) -- Ruins of Lordaeron
	Capping:AddBG(617, Arena) -- Dalaran Sewers
	Capping:AddBG(980, Arena) -- Tol'Viron Arena
	Capping:AddBG(1134, Arena) -- The Tiger's Peak
end

