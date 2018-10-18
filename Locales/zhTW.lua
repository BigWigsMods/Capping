
if GetLocale() ~= "zhTW" then return end
local _, mod = ...
local L = mod.L

L.battleBegins = "開始"
L.finalScore = "估計最終比數: %d - %d"
L.flagRespawns = "旗幟已重置"

L.takenTheFlagTrigger = "^(.+)已經奪走了旗幟!"
L.hasTakenTheTrigger = "奪取了"
L.upgradeToTrigger = "升級成"
L.droppedTrigger = "丟掉了"
L.capturedTheTrigger = "佔據了"

--L.hordeGate = "Horde Gate"
--L.allianceGate = "Alliance Gate"
--L.hordeBoss = "Horde Boss"
--L.allianceBoss = "Alliance Boss"
--L.galvangar = "Galvangar"
--L.balinda = "Balinda Stonehearth"

--- Alliance IoC Workshop yells:
-- Gnomish Mechanic yells: I'm halfway there! Keep the Horde away from here.  They don't teach fighting in engineering school!
-- Gnomish Mechanic yells: It's broken already?! No worries. It's nothing I can't fix.
--- Horde IoC Workshop yells:
-- Goblin Mechanic yells: I'm about halfway done! Keep the Alliance away - fighting's not in my contract!
-- Goblin Mechanic yells: It's broken again?! I'll fix it... just don't expect the warranty to cover this.
--L.halfway = "halfway"
--L.broken = "broken"
