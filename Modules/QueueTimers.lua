
local mod, L, cap
do
	local _, core = ...
	mod, L, cap = core:NewMod("QueueTimers")
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
mod:RegisterEvent("START_TIMER")

do -- estimated wait timer and port timer
	local GetBattlefieldStatus = GetBattlefieldStatus
	local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
	local GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited = GetBattlefieldEstimatedWaitTime, GetBattlefieldTimeWaited
	local ARENA = ARENA
	local queueBars = {}

	local function cleanupQueue()
		for id, bar in next, queueBars do
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
				queueBars[queueId] = bar
			end

			if cap.db.profile.useMasterForQueue then
				local _, id = PlaySound(8459, "Master", false) -- SOUNDKIT.PVP_THROUGH_QUEUE
				if id then
					StopSound(id-1) -- Should work most of the time to stop the blizz sound
				end
			end
		elseif status == "queued" and map and cap.db.profile.queueBars then -- Waiting for BG to pop
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
			queueBars[queueId] = bar
		elseif status == "none" then -- Leaving queue
			cleanupQueue()
		end
	end
end
mod:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
