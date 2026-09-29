
local mod, L, cap
do
	local _, core = ...
	mod, L, cap = core:NewMod()
end

function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
	local timeSeconds
	local num = msg:match("(%d+)")
	if num then num = tonumber(num) end

	if num == 30 or msg == L.arenaStart30s then
		timeSeconds = 30
	elseif num == 2 then
		timeSeconds = 120
	elseif num == 1 or msg == L.arenaStart60s then
		timeSeconds = 60
	elseif msg == L.arenaStart15s then
		timeSeconds = 15
	else
		return
	end

	self:StartBar(L.battleBegins, timeSeconds, 136106, "colorOther", nil, timeSeconds == 120 and timeSeconds or 60) -- 136106 = Interface/Icons/Spell_nature_timestop
end
mod:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

do -- estimated wait timer and port timer
	local GetBattlefieldStatus = GetBattlefieldStatus
	local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
	local GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited = GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited
	local ARENA = ARENA

	function mod:PLAYER_ENTERING_WORLD()
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	function mod:UPDATE_BATTLEFIELD_STATUS(queueId)
		local status, mapName, _, _, _, queueType, gameType = GetBattlefieldStatus(queueId)

		if queueType == "ARENASKIRMISH" then
			mapName = string.format("%s (%d)", ARENA, queueId) -- No size or name distinction given for casual arena 2v2/3v3, separate them manually. Messy :(
		end

		if status == "confirm" then -- BG has popped, time until cancelled
			self:StopBarByData("capping:queueid", queueId)
			local bar = self:StartBar(mapName, GetBattlefieldPortExpiration(queueId), 132327, "colorOther", true) -- 132327 = Interface/Icons/Ability_TownWatch
			bar:Set("capping:queueid", queueId)

			if cap.db.profile.useMasterForQueue then
				local _, id = PlaySound(8459, "Master", false) -- SOUNDKIT.PVP_THROUGH_QUEUE
				if id then
					StopSound(id-1) -- Should work most of the time to stop the blizz sound
				end
			end
		elseif status == "queued" and cap.db.profile.queueBars then -- Waiting for BG to pop
			if not mapName then -- Brawl queue after a ReloadUI() is nil cuz lul
				if gameType then
					mapName = gameType
				else
					return
				end
			end

			local esttime = GetBattlefieldEstimatedWaitTime(queueId) / 1000 -- 0 when queue is paused
			local waited = GetBattlefieldTimeWaited(queueId) / 1000
			local estremain = esttime - waited
			local bar = self:GetBarByData("capping:queueid", queueId)

			if estremain > 1 then -- Not a paused queue (0) and not a negative queue (in queue longer than estimated time).
				if not bar or estremain > bar.remaining+10 or estremain < bar.remaining-10 or bar:GetLabel() ~= mapName then -- Don't restart bars for subtle changes +/- 10s
					local icon
					for i = 1, GetNumBattlegroundTypes() do
						local name,_,_,_,_,_,_,_,_,bgIcon = GetBattlegroundInfo(i)
						if name == mapName then
							icon = bgIcon
							break
						end
					end
					self:StopBarByData("capping:queueid", queueId)
					local newBar = self:StartBar(mapName, estremain, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					newBar:Set("capping:queueid", queueId)
				end
			else -- Negative queue (in queue longer than estimated time) or 0 queue (paused)
				if not bar or bar.remaining ~= 1 then
					local icon
					for i = 1, GetNumBattlegroundTypes() do
						local name,_,_,_,_,_,_,_,_,bgIcon = GetBattlegroundInfo(i)
						if name == mapName then
							icon = bgIcon
							break
						end
					end
					self:StopBarByData("capping:queueid", queueId)
					local newBar = self:StartBar(mapName, 1, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					newBar:Pause()
					newBar.remaining = 1
					newBar:SetTimeVisibility(false)
					newBar:Set("capping:queueid", queueId)
				end
			end
		elseif status == "none" then -- Leaving queue
			self:StopBarByData("capping:queueid", queueId)
		elseif status == "active" then -- Entered Zone, stop all queue bars
			self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			self:StopBarContainingData("capping:queueid")
		end
	end
end
mod:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
