
local mod, isForever
do
	local _, core = ...
	mod = core:NewMod()
	isForever = core.isForever
end

do
	local poiEnglishNames = {
		-- Arathi Basin (map 2107)
		[6076] = "Gold Mine",
		[6077] = "Farm",
		[6078] = "Lumber Mill",
		[6079] = "Blacksmith",
		[6080] = "Stables",

		-- Arathi Basin Classic (map 529)
		[1612] = "Stables", -- Alliance conflict (WoW Forever) / dynamic (Retail)
		[1613] = "Stables", -- Horde conflict (WoW Forever)
		[1617] = "Blacksmith", -- Alliance conflict (WoW Forever)
		[1618] = "Blacksmith", -- Horde conflict (WoW Forever) / dynamic (Retail)
		[1622] = "Lumber Mill", -- Alliance conflict (WoW Forever)
		[1623] = "Lumber Mill", -- Horde conflict (WoW Forever) / dynamic (Retail)
		[1627] = "Gold Mine", -- Alliance conflict (WoW Forever)
		[1628] = "Gold Mine", -- Horde conflict (WoW Forever) / dynamic (Retail)
		[1632] = "Farm", -- Alliance conflict (WoW Forever) / dynamic (Retail)
		[1633] = "Farm", -- Horde conflict (WoW Forever)

		-- Arathi Basin Snowy PvP Brawl (map 1681)
		[5204] = "Blacksmith",
		[5205] = "Farm",
		[5206] = "Stables",
		[5207] = "Gold Mine",
		[5208] = "Lumber Mill",

		-- Arathi Basin Brawl Vs AI (map 2177)
		[5199] = "Lumber Mill",
		[5200] = "Stables",
		[5201] = "Gold Mine",
		[5202] = "Farm",
		[5203] = "Blacksmith",
	}
	function mod:EnterZone()
		self:StartFlagCaptures({30, 60}, nil, poiEnglishNames) -- 30 sec when solo RBG, 60 otherwise
		if isForever then
			self:StartScoreEstimatorWoWForeverArathiBasin() -- WoW Forever uses Classic per-team tick intervals
		else
			self:StartScoreEstimator()
		end
	end
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(2107) -- Arathi Basin
mod:RegisterZone(529) -- Arathi Basin Classic
mod:RegisterZone(1681) -- Arathi Basin Snowy PvP Brawl
mod:RegisterZone(2177) -- Arathi Basin Brawl Vs AI
