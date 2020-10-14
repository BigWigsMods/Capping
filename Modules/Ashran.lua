
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

local hasPrinted = false
do
	local UnitGUID, GetCurrencyInfo, GetNumGossipOptions, strsplit = UnitGUID, C_CurrencyInfo.GetCurrencyInfo, C_GossipInfo.GetNumOptions(), strsplit
	local tonumber, SelectGossipOption = tonumber, C_GossipInfo.SelectOption
	function mod:GOSSIP_SHOW()
		local target = UnitGUID("npc")
		if target then
			local _, _, _, _, _, id = strsplit("-", target)
			local mobId = tonumber(id)
			if mobId == 81870 or mobId == 83830 then -- Anenga (Alliance) / Kalgan (Horde)
				local tbl = GetCurrencyInfo(944) -- Artifact Fragment
				if tbl and tbl.quantity > 0 and GetNumGossipOptions() == 3 then -- Have the currency and boss isn't already summoned
					SelectGossipOption(1)
					if not hasPrinted then
						hasPrinted = true
						print(L.handIn)
					end
				end
			end
		end
	end
end

function mod:EnterZone()
	hasPrinted = false
	self:RegisterEvent("GOSSIP_SHOW")
end

function mod:ExitZone()
	self:UnregisterEvent("GOSSIP_SHOW")
end

mod:RegisterZone(1191)
