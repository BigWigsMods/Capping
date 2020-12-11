
local mod, L, cap
do
	local _, core = ...
	mod, L, cap = core:NewMod()
end

--[[
Timer.lua line 2
TIMER_TYPE_PVP = 1;
TIMER_TYPE_CHALLENGE_MODE = 2;
TIMER_TYPE_PLAYER_COUNTDOWN = 3;
]]
function mod:START_TIMER(timerType, timeSeconds)
	if timerType == 3 then return end

	for i = 1, #TimerTracker.timerList do
		TimerTracker.timerList[i].bar:Hide() -- Hide the Blizz start timer
	end

	local bar = self:GetBar(L.battleBegins)
	if not bar or timeSeconds > bar.remaining+1 or timeSeconds < bar.remaining-1 then -- Don't restart bars for subtle changes +/- 1s
		self:StartBar(L.battleBegins, timeSeconds, 618859, "colorOther") -- 618859 = Interface/Icons/achievement_challengemode_platinum
	end
end
mod:RegisterEvent("START_TIMER")

do -- estimated wait timer and port timer
	local GetBattlefieldStatus = GetBattlefieldStatus
	local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
	local GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited = GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited
	local ARENA = ARENA
	local queueBars = {}

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
			local bar = queueBars[queueId]
			if bar and bar:Get("capping:queueid") then
				bar:Stop()
			end

			bar = self:StartBar(mapName, GetBattlefieldPortExpiration(queueId), 132327, "colorOther", true) -- 132327 = Interface/Icons/Ability_TownWatch
			bar:Set("capping:queueid", queueId)
			queueBars[queueId] = bar

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
			local bar = queueBars[queueId]
			if bar and not bar:Get("capping:queueid") then
				bar = nil
			end

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
					if bar then
						bar:Stop()
					end
					bar = self:StartBar(mapName, estremain, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					bar:Set("capping:queueid", queueId)
					queueBars[queueId] = bar
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
					if bar then
						bar:Stop()
					end
					bar = self:StartBar(mapName, 1, icon or 134400, "colorQueue", true) -- Question mark icon for random battleground (134400) Interface/Icons/INV_Misc_QuestionMark
					bar:Pause()
					bar.remaining = 1
					bar:SetTimeVisibility(false)
					bar:Set("capping:queueid", queueId)
					queueBars[queueId] = bar
				end
			end
		elseif status == "none" then -- Leaving queue
			local bar = queueBars[queueId]
			if bar and bar:Get("capping:queueid") then
				bar:Stop()
			end
			queueBars[queueId] = nil
		elseif status == "active" then -- Entered Zone, stop all queue bars
			self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			for id, bar in next, queueBars do
				if bar:Get("capping:queueid") then
					bar:Stop()
				end
				queueBars[id] = nil
			end
		end
	end
end
mod:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
