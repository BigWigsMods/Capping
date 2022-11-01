
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

do
	local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
	function mod:GOSSIP_SHOW()
		local alliance = self:GetGossipID(43063)
		local horde = self:GetGossipID(52320)
		if alliance or horde then
			local tbl = GetCurrencyInfo(944) -- Artifact Fragment
			if tbl and tbl.quantity > 0 and self:GetGossipNumOptions() == 3 then -- Have the currency and boss isn't already summoned
				self:SelectGossipID(alliance and 43063 or 52320)
				print(L.handIn)
			end
		end
	end
end

function mod:EnterZone()
	self:RegisterEvent("GOSSIP_SHOW")
	self:SetupHealthCheck("88178", L.hordeGuardian, "Horde Guardian", 236440, "colorAlliance") -- Jeron Emberfall -- Interface/Icons/achievement_character_bloodelf_male
	self:SetupHealthCheck("88224", L.allianceGuardian, "Alliance Guardian", 236447, "colorHorde") -- Rylai Crestfall -- Interface/Icons/Achievement_character_human_female
end

function mod:ExitZone()
	self:UnregisterEvent("GOSSIP_SHOW")
end

mod:RegisterZone(1191)
